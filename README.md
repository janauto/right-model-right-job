# 多Agent编排配置包

规划驱动、按需组装、验证严格、可回收的动态多Agent系统。基于Claude Code subagents实现。

## 安装

1. 把 `CLAUDE.md` 的内容追加到你项目的 `CLAUDE.md`（没有就直接复制过去）。
2. 把 `.claude/agents/` 下的3个文件放进项目的 `.claude/agents/`（想跨项目复用就放 `~/.claude/agents/`）。
3. 用Plan模式发起复杂任务，主控会按规则自动编排。

## 决策记录

| 决策点 | 结论 | 依据 |
|---|---|---|
| 拆分策略 | 条件拆分，默认0子Agent，上限5 | 多Agent耗token 3~15倍；约79%多Agent失败源于规格与协调，单Agent中不存在（MAST） |
| 拆分方向 | 沿上下文边界，禁止按工种拆 | planner/coder/reviewer拆分实测"协调token超过实际工作token"（Anthropic 2026） |
| 主控角色 | 纯经理：plan/decompose/synthesize/终验 | 用户决策 |
| 并行 | 研究类默认并行≤3；编码类需契约+worktree | 拆分收益只在读密集/广度优先任务兑现（+90.2%）；编码是写密集强依赖 |
| 临时角色 | 动态prompt为主，≥2次复用才沉淀文件 | agent description常驻主提示，注册有持续成本 |
| 通信 | 回传≤300 token+落盘；交接用路径+短摘要 | 自由回传是主控上下文膨胀的最大来源 |
| QA | 独立Opus QA黑盒验收 + 主控读报告抽查 | 黑盒验证子Agent是唯一被证实跨域稳定有效的模式 |
| 合并 | QA机械合并，语义冲突弹回不修 | 保证每行业务代码都被独立验收；QA不能自写自测 |
| 修复回路 | 重派同角色新实例×2，超限弹窗问用户 | 子Agent上下文返回即销毁，"退回原作者"实为重派 |
| Codex双跑 | 仅不可逆决策 | 跨家族验证+7个百分点但成本×2；同家族误差相关r=0.67，跨家族r=0.53 |
| 计费 | 订阅为主，API溢出 | 用户决策 |
| 生命周期 | 单会话，无持久化状态层 | 用户决策；若未来出现跨天项目，再补任务账本 |

## 升级路径（跑起来之后观察）

- 语义冲突弹回频繁 → 病根在plan期接口契约不够死，先修契约模板；仍频繁再单设Sonnet集成Agent。
- 编码并行合并成本持续高于省下的时间 → 编码退回全串行。
- 出现跨会话长项目 → 在 `.work/` 加PLAN.md任务账本。

## 证据来源

- [Anthropic: multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)
- [Anthropic: when and how to build multi-agent](https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them)
- [Cognition: Don't Build Multi-Agents](https://cognition.ai/blog/dont-build-multi-agents)
- [MAST: Why Do Multi-Agent LLM Systems Fail? (arXiv:2503.13657)](https://arxiv.org/abs/2503.13657)
- [Claude Code subagents文档](https://code.claude.com/docs/en/sub-agents)
- [LLMs Cannot Self-Correct Reasoning Yet (arXiv:2310.01798)](https://arxiv.org/abs/2310.01798)
- [Nine Judges, Two Effective Votes (arXiv:2605.29800)](https://arxiv.org/html/2605.29800)
