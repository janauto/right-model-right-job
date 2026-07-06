<div align="center">

# right-model-right-job

### 好钢用在刀刃上 · 为正确的任务选择正确的模型

**别把什么都丢给最大的模型，也别让 Agent 背着你做决定。**
一套规划驱动、按需组装、验证严格、可回收的动态多 Agent 编排配置——
最强模型只做规划，便宜模型负责执行，独立 QA 黑盒把关；
三道确认门（是否启用 → 用什么模型规划 → 需求文档终审）让每个关键决定都过你的手。基于 Claude Code subagents 实现。

<p>
  <img alt="Built for Claude Code" src="https://img.shields.io/badge/Built_for-Claude_Code-d97757">
  <img alt="类型：配置包·零依赖" src="https://img.shields.io/badge/%E7%B1%BB%E5%9E%8B-%E9%85%8D%E7%BD%AE%E5%8C%85%C2%B7%E9%9B%B6%E4%BE%9D%E8%B5%96-3fb950">
  <img alt="Subagents ×4" src="https://img.shields.io/badge/Subagents-%C3%974-6e56cf">
  <img alt="确认门 ×3" src="https://img.shields.io/badge/%E7%A1%AE%E8%AE%A4%E9%97%A8-%C3%973-f0b429">
  <img alt="最近更新" src="https://img.shields.io/github/last-commit/janauto/right-model-right-job/main?label=%E6%9C%80%E8%BF%91%E6%9B%B4%E6%96%B0&color=555">
</p>

<p>
  <a href="#为什么需要它">为什么</a> ·
  <a href="#核心理念好钢用在刀刃上">核心理念</a> ·
  <a href="#编排流程">编排流程</a> ·
  <a href="#快速开始">快速开始</a> ·
  <a href="#决策记录">决策记录</a> ·
  <a href="#证据来源">证据来源</a>
</p>

</div>

---

## 为什么需要它

多 Agent 系统很贵，也很容易失败。同一个任务，多 Agent 要多烧 3～15 倍的 token。更麻烦的是失败率：约 79% 的多 Agent 失败并非来自模型能力不足，而是**规格没写清、Agent 之间协调出错**——这两类问题在单 Agent 里根本不存在（见 MAST 论文）。

所以这套配置的默认动作是**不拆**。只有当拆分真正划算时才拆，而且沿上下文边界拆，绝不按工种拆。它把一个朴素的常识落成了可执行的规则：**好钢用在刀刃上**——最强的模型只用来规划和把关，具体的活交给更便宜、更快的模型，最后由一个独立裁判黑盒验收。

> [!IMPORTANT]
> **四条不可逾越的红线**
> 1. **默认 0 子 Agent。** 拆分需要给出理由，不拆才是常态。
> 2. **沿上下文边界拆，禁止按工种拆。** 不做 planner / coder / reviewer 式流水线——实测中它的协调开销会超过实际干活的开销。
> 3. **QA 是独立裁判。** 只做黑盒验收，永不自写自测。这是唯一被证实能跨领域稳定生效的模式。
> 4. **需求文档未经你终审确认，一个开发 Agent 都不许派。** G2 门在任何档位下都不可跳过。

---

## 核心理念：好钢用在刀刃上

系统由四类角色构成，每一类只做自己最擅长的那一件事，用对应档位的模型：

| 角色 | 模型 | 只负责 | 定义文件 |
|---|---|---|---|
| **主控**（主线程） | 最强 / 主控模型 | 规划、拆分、汇总、终验——不写业务代码 | 你项目的 `CLAUDE.md` |
| **deep-reasoner** | Opus | 架构设计、算法难题、根因分析 | `.claude/agents/deep-reasoner.md` |
| **researcher** | Sonnet | 需求调研：联网搜索、方案对比、竞品与文档检索 | `.claude/agents/researcher.md` |
| **fast-worker** | Sonnet | 样板代码、批量修改、常规实现、代码库检索 | `.claude/agents/fast-worker.md` |
| **qa** | Opus | 黑盒验收 + 机械合并——永不写业务代码 | `.claude/agents/qa.md` |
| **临时角色** | general-purpose + 现写 prompt | 一次性任务；同一角色复用满 2 次才沉淀成文件 | 主控动态生成 |

**仓库结构**——五个 Markdown 文件 + 一个可选 hook 脚本，零运行时依赖：

```
right-model-right-job/
├── CLAUDE.md                 # 编排规则（含三道确认门），并入你项目的 CLAUDE.md
├── .claude/agents/
│   ├── deep-reasoner.md      # Opus   · 重推理
│   ├── researcher.md         # Sonnet · 需求调研（联网搜索）
│   ├── fast-worker.md        # Sonnet · 机械执行
│   └── qa.md                 # Opus   · 黑盒验收 + 机械合并
└── hooks/
    └── plan-gate.sh          # 可选 · 进 Plan 模式自动触发 G0 弹窗的机制保证
```

---

## 编排流程

从进入 Plan 模式，到主控汇总交付，全程五阶段三道门。主控自己从不写业务代码，只做规划、拆分、汇总和终验；**每道门都是 AskUserQuestion 弹窗，你不点头，流程不往下走**：

- **G0 · 启用确认**——进 Plan 模式后的第一个动作就是问你"是否采用编排流程"，不再靠模型自己判断该不该启用。
- **G1 · 规划模型确认**——写任何编排/需求文档之前，先问你用什么模型规划（默认推荐最强模型）。你口语化指定过的模型会解析后写进选项里让你显式确认，不搞"未反对即生效"。
- **P1 · 需求调研**——需求有未知点时派 researcher（联网搜索）/ fast-worker（代码库探索）补齐，只读并行 ≤ 3。
- **G2 · 需求文档终审**——调研汇总成 `REQUIREMENTS.md`（目标 / 范围 / 接口契约 / 总任务表 / 验收标准）交你终审。**这是任何档位都不可跳过的门：你不确认，一个开发 Agent 都不会派出。**
- **P2 · 开发编排**——严格按已确认的需求文档拆分、并行、QA 验收。

```mermaid
flowchart TD
    Start(["Plan 模式 · 项目级任务"]) --> G0{{"G0 · 启用确认弹窗<br/>是否采用编排流程？"}}
    G0 -->|"否"| Off["主控直跑<br/>编排规则不生效"]
    G0 -->|"是"| G1{{"G1 · 规划模型确认弹窗<br/>默认最强模型"}}
    G1 --> P1["P1 · 需求调研<br/>researcher / fast-worker<br/>只读并行 ≤ 3"]
    P1 --> G2{{"G2 · 需求文档终审弹窗<br/>REQUIREMENTS.md"}}
    G2 -->|"修改 / 补充调研"| P1
    G2 -->|"用户确认"| Plan["P2 · 主控拆分决策<br/>默认 0 子 Agent"]

    Plan -->|"不满足拆分条件"| Solo["主控派单个 Agent<br/>一次做完"]
    Plan -->|"满足任一：独立可契约 /<br/>检索噪音大 / 需黑盒验收"| Pool

    subgraph Pool ["按上下文边界拆分 · 上限 5 · 禁按工种拆"]
        direction LR
        DR["deep-reasoner · Opus<br/>架构 / 算法 / 根因"]
        FW["fast-worker · Sonnet<br/>样板 / 批量 / 检索"]
    end

    Solo --> QA["qa · Opus<br/>黑盒验收 + 机械合并"]
    Pool --> QA

    QA --> Conflict{"语义冲突？"}
    Conflict -->|"是 = 验收失败"| Repair["修复回路<br/>重派同角色新实例"]
    Repair -->|"重试 ≤ 2 次"| QA
    Repair -->|"超限"| Ask["AskUserQuestion<br/>交用户三选一"]
    Conflict -->|"否 · 全部通过"| Done["主控：汇总 + 终验<br/>读 qa-report + 抽查"]
```

几个贯穿全流程的约束：

- **并行分两轨。** 研究/检索类（只读）默认并行，宽度 ≤ 3；编码类（写入）要并行必须同时满足三条——接口契约已定死、列出禁改的公共文件、每个 Agent 独立 git worktree。任何两个并行 Agent 都不得写同一个文件。
- **通信压到最短。** 子 Agent 的详细产出一律落盘到 `.work/<任务名>/`，回传主控 ≤ 300 token（结论 + 产物路径 + 风险标记）。自由回传是主控上下文膨胀的最大来源。
- **QA 只认结果。** 输入只有三样：验收标准、测试用例、产物路径，不看执行过程（保持黑盒）。语义冲突判为验收失败，QA 不修，弹回修复回路。

---

## 快速开始

### 前置条件

| 前置 | 要求 |
|---|---|
| Claude Code | 支持 subagents 的版本（能识别 `.claude/agents/` 目录） |
| 模型访问 | 可调用 Opus 与 Sonnet（订阅或 API 均可） |
| 依赖 | 无。纯 Markdown 配置，零运行时依赖 |

### 安装

以下命令都在**你运行 `git clone` 的那个目录**里执行——克隆完不要 `cd` 进仓库，否则第 2、3 步的相对路径会失效。

```bash
# 1. 克隆本仓库
git clone https://github.com/janauto/right-model-right-job.git

# 2. 安装四个 subagent 到用户级目录（所有项目都能复用）
mkdir -p ~/.claude/agents
cp right-model-right-job/.claude/agents/*.md ~/.claude/agents/

# 3. 把编排规则并入你自己的项目（~/你的项目 换成实际路径，该目录需已存在）
#    用 >> 追加，别用 >——单个 > 会覆盖、清空你已有的 CLAUDE.md！
#    项目原本没有 CLAUDE.md 时，>> 会自动新建这个文件（但不会新建目录）。
cat right-model-right-job/CLAUDE.md >> ~/你的项目/CLAUDE.md

# 4.（可选，强烈推荐）安装 Plan 模式入口门 hook——
#    让"一进 Plan 模式就弹 G0 确认窗"成为机制保证，而不是靠模型自觉。
mkdir -p ~/.claude/hooks
cp right-model-right-job/hooks/plan-gate.sh ~/.claude/hooks/rmrj-plan-gate.sh
chmod +x ~/.claude/hooks/rmrj-plan-gate.sh
```

第 4 步复制完脚本后，还需在 `~/.claude/settings.json` 的 `hooks.UserPromptSubmit` 里登记（没有该文件/该字段就照抄整段；已有其他 hook 就把对象追加进数组）：

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "bash ~/.claude/hooks/rmrj-plan-gate.sh", "timeout": 10 }
        ]
      }
    ]
  }
}
```

> [!TIP]
> 只想在单个项目里用、不跨项目复用？把第 2 步的 `~/.claude/agents/` 换成 `~/你的项目/.claude/agents/` 即可。
> 不装第 4 步的 hook 也能用：CLAUDE.md 里的 G0 规则仍会引导模型弹窗，只是少了机制层面的兜底。

### 冒烟测试

安装完先在终端跑两条命令确认文件到位：

```bash
# A. 四个 subagent 就位——应打印四个文件路径、无报错
ls ~/.claude/agents/deep-reasoner.md ~/.claude/agents/researcher.md ~/.claude/agents/fast-worker.md ~/.claude/agents/qa.md

# B. 编排规则已并入项目——应打印 “# 多Agent编排规则”（把路径换成你第 3 步的目标）
grep -m1 "多Agent编排规则" ~/你的项目/CLAUDE.md

# C.（装了第 4 步才需要）hook 脚本本身工作正常——应打印〈多Agent编排提醒〉
echo '{"session_id":"smoke","permission_mode":"plan"}' | bash ~/.claude/hooks/rmrj-plan-gate.sh; rm -f "${TMPDIR:-/tmp}/rmrj-g0-smoke"
```

再进 Claude Code 里做两步功能确认（这两步需要交互式会话，命令行测不了）：

1. 运行 `/agents`，列表中应能看到 `deep-reasoner`、`researcher`、`fast-worker`、`qa` 四个 agent。
2. 进入 **Plan 模式**发起一个项目级任务。第一个动作应该是 G0 弹窗问你「是否启用多Agent编排流程」；选启用后会依次经过 G1 模型确认、（按需）P1 调研、G2 需求文档终审。看到 G0 弹窗，就说明编排规则已生效。

### 切换编排档位

`CLAUDE.md` 顶部有一行开关，改这一行即可换档：

```
ORCHESTRATION: ask
```

| 档位 | 行为 |
|---|---|
| `ask`（默认） | 走完整五阶段，G0 / G1 / G2 三道门每道都弹窗确认 |
| `auto` | 跳过 G0 与 G1（进 Plan 模式即启用、默认最强模型规划）；**G2 需求文档终审保留，不可跳过** |
| `off` | 永不调用 subagent，全部由主控直跑 |

---

## 决策记录

每一条规则背后都有取舍，这里是完整的决策账本：

| 决策点 | 结论 | 依据 |
|---|---|---|
| 确认门 | G0 启用 / G1 模型 / G2 需求终审三道弹窗；G2 任何档位不可跳过 | MAST：约 79% 多 Agent 失败源于规格不清与协调出错——需求文档先经人终审，正是把「规格」这半边失败源掐死在派发之前 |
| 入口触发 | CLAUDE.md 规则引导 + 可选 UserPromptSubmit hook 机制兜底 | 纯 prompt 触发依赖模型自觉，实测会漏；hook 注入是确定性行为 |
| 拆分策略 | 条件拆分，默认 0 子 Agent，上限 5 | 多 Agent 耗 token 3～15 倍；约 79% 多 Agent 失败源于规格与协调，单 Agent 中不存在（MAST） |
| 拆分方向 | 沿上下文边界，禁止按工种拆 | planner/coder/reviewer 拆分实测「协调 token 超过实际工作 token」（Anthropic 2026） |
| 主控角色 | 纯经理：plan / decompose / synthesize / 终验 | 用户决策 |
| 并行 | 研究类默认并行 ≤ 3；编码类需契约 + worktree | 拆分收益只在读密集 / 广度优先任务兑现（+90.2%）；编码是写密集强依赖 |
| 临时角色 | 动态 prompt 为主，≥ 2 次复用才沉淀文件 | agent description 常驻主提示，注册有持续成本 |
| 通信 | 回传 ≤ 300 token + 落盘；交接用路径 + 短摘要 | 自由回传是主控上下文膨胀的最大来源 |
| QA | 独立 Opus QA 黑盒验收 + 主控读报告抽查 | 黑盒验证子 Agent 是唯一被证实跨域稳定有效的模式 |
| 合并 | QA 机械合并，语义冲突弹回不修 | 保证每行业务代码都被独立验收；QA 不能自写自测 |
| 修复回路 | 重派同角色新实例 ×2，超限弹窗问用户 | 子 Agent 上下文返回即销毁，「退回原作者」实为重派 |
| Codex 双跑 | 仅不可逆决策 | 跨家族验证 +7 个百分点但成本 ×2；同家族误差相关 r=0.67，跨家族 r=0.53 |
| 计费 | 订阅为主，API 溢出 | 用户决策 |
| 生命周期 | 单会话，无持久化状态层 | 用户决策；若未来出现跨天项目，再补任务账本 |

---

## 升级路径（跑起来之后观察）

- **语义冲突弹回频繁** → 病根在 plan 期接口契约不够死，先修契约模板；仍频繁再单设 Sonnet 集成 Agent。
- **编码并行合并成本持续高于省下的时间** → 编码退回全串行。
- **出现跨会话长项目** → 在 `.work/` 加 `PLAN.md` 任务账本。

---

## 证据来源

- [Anthropic: Multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)
- [Anthropic: Building multi-agent systems — when and how](https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them)
- [Cognition: Don't Build Multi-Agents](https://cognition.ai/blog/dont-build-multi-agents)
- [MAST: Why Do Multi-Agent LLM Systems Fail? (arXiv:2503.13657)](https://arxiv.org/abs/2503.13657)
- [Claude Code subagents 文档](https://code.claude.com/docs/en/sub-agents)
- [LLMs Cannot Self-Correct Reasoning Yet (arXiv:2310.01798)](https://arxiv.org/abs/2310.01798)
- [Nine Judges, Two Effective Votes (arXiv:2605.29800)](https://arxiv.org/html/2605.29800)

---

<div align="center">
<sub>规划驱动 · 按需组装 · 验证严格 · 可回收 —— 让每个 token 花在刀口上。</sub>
</div>
