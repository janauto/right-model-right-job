#!/bin/bash
# right-model-right-job · Plan模式入口门（可选安装）
#
# UserPromptSubmit hook：检测到会话处于 Plan 模式时，在该会话第一条 Plan 模式
# 消息里注入提醒，强制主控先执行 G0（是否启用编排流程）弹窗，再做任何规划。
# 让"进 Plan 模式就弹窗"成为机制保证，而不是靠模型自觉遵守 CLAUDE.md。
#
# 安装（见 README「快速开始」第 4 步）：
#   mkdir -p ~/.claude/hooks && cp hooks/plan-gate.sh ~/.claude/hooks/rmrj-plan-gate.sh
#   然后在 ~/.claude/settings.json 的 hooks.UserPromptSubmit 中登记本脚本。
#
# 行为说明：
# - 仅在 permission_mode == "plan" 时生效，其余情况静默退出（exit 0）。
# - 每个会话只注入一次（用 session_id 做标记文件），不会反复打扰。
# - 老版本 Claude Code 的 hook 输入若无 permission_mode 字段，脚本静默退出，无副作用。

input=$(cat)

get_field() {
  printf '%s' "$input" | sed -n 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1
}

mode=$(get_field permission_mode)
[ "$mode" = "plan" ] || exit 0

session=$(get_field session_id)
[ -n "$session" ] || exit 0

flag="${TMPDIR:-/tmp}/rmrj-g0-${session}"
[ -f "$flag" ] && exit 0
touch "$flag"

cat <<'EOF'
<多Agent编排提醒>
当前处于Plan模式。若本项目CLAUDE.md含"多Agent编排规则"且 ORCHESTRATION 不为 off：
在做任何规划、写任何文档之前，第一个动作必须是执行 G0 门——用 AskUserQuestion 弹窗
询问用户"是否启用多Agent编排流程"，随后按 G1（规划模型确认）→ P1（需求调研）→
G2（需求文档终审）→ P2（开发编排）的顺序走完五阶段，禁止跳门。
</多Agent编排提醒>
EOF
exit 0
