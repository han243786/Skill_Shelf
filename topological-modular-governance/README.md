# Topological Modular Governance

这是一套给大型项目使用的拓扑式模块化治理方案。它把项目看成一张可审计的白箱网络：模块是节点，父子通信是边，全量树是物理地图，模块树是逻辑拓扑，三种开发模式加一种维护模式共同定义网络变更入口。

## 一句话说明

不要只问“这个文件在哪里”，而要问“这个节点归谁、通过哪条边通信、这次变更会改变哪一段拓扑”。

## 它解决什么问题

大型项目失控时，表面看是文件太多、函数太长、文档太乱；本质往往是拓扑失控：

1. 模块没有清楚的父级。
2. 子模块横向乱连，改一个点牵动一片。
3. public 方法没有 owner，谁都能碰。
4. 旧代码、新代码、文档、测试指向不同事实。
5. AI 只能按文件猜测，不知道自己正在改哪条结构边。
6. 重构、推进、切面打磨混成一个“继续”，导致治理状态污染。

拓扑式模块化治理的目标，是让每次变更都能被放回一张清楚的网络图里。

## 适合什么场景

- 十万行级或更大项目。
- 多语言、多前端、多后端、多 crate/package/workspace 项目。
- 已经存在明显模块纠缠、旧新路径并存、重构周期很长的项目。
- 需要 AI 长时间接力开发，但又担心幻觉、越界、回退和治理漂移。
- 需要同时管理代码、模块树、全量树、契约、测试、文档和 closeout 的项目。

## 不适合什么场景

- 小脚本、小 demo、一次性工具。
- 只有几个文件、没有长期扩张压力的项目。
- 只是想快速抽一个函数，不需要项目级治理。
- 团队还没有准备接受“父子通信优先于局部性能捷径”的开发纪律。

## 通俗类比

你可以把项目想成一张网络：

```text
全局根
  -> 顶层父模块
    -> 中间路由模块
      -> 子模块
        -> 叶子模块
```

叶子模块不是不能通信，而是不能随便私拉横线。开发态默认走父级、契约、adapter、事件或登记接口。这样会牺牲一点局部速度，但能换来长期可扩张、可审计、可接力。

只有开发者明确宣布进入发布版本性能过渡时，才允许提出少量横向连接、旁路缓存或热路径直连方案。AI 不得主动诱导进入这个阶段。

## 最短使用路径

### 1. 先只读盘点项目

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\Skill_Shelf\topological-modular-governance\scripts\inventory-topology.ps1 -ProjectRoot D:\your-project
```

如果想保存盘点草稿：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\Skill_Shelf\topological-modular-governance\scripts\inventory-topology.ps1 -ProjectRoot D:\your-project -OutputPath docs\topological-governance\TOPOLOGY_INVENTORY.md
```

### 2. 再安装治理骨架

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\Skill_Shelf\topological-modular-governance\scripts\bootstrap-topological-governance.ps1 -ProjectRoot D:\your-project
```

默认写入：

```text
docs\topological-governance\
tools\check-topological-governance.ps1
tools\inventory-topology.ps1
```

已有文件不会被覆盖，除非显式加 `-Force`。

### 3. 检查骨架是否完整

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\your-project\tools\check-topological-governance.ps1 -ProjectRoot D:\your-project
```

### 4. 把启动提示词交给 AI

打开目标项目里的：

```text
docs\topological-governance\AI_START_PROMPT.md
```

把里面的提示词交给 coding agent，让它按拓扑式治理执行。

## 最短 AI 口令

如果暂时不安装脚手架，也可以直接使用这段口令：

```text
使用 topological-modular-governance。
先把项目当成一张模块拓扑图，不要直接按文件推进。
先判定工作模式：重构模式、推进模式、切面打磨模式，或文档债清理。
定位本轮影响的父模块、子模块、public 方法、接口、测试、文档和治理资产。
开发态禁止子模块横向直连；所有跨子模块通信先走父级、契约、adapter、事件或登记接口。
每次 closeout 证明拓扑一致：模块树、全量树、代码路径、测试、契约和旧路径状态一致。
```

## 四种工作入口

| 模式 | 拓扑含义 | 典型动作 |
| --- | --- | --- |
| 重构模式 | 调整既有节点和边，不改变外部行为 | 抽离模块、整理父级 facade、关闭旧路径 |
| 推进模式 | 新增节点、端口或能力 | 新 route、新 schema、新 UI surface、新 capability |
| 切面打磨模式 | 复制一段影响范围，优化镜像拓扑，再裁剪旧拓扑 | UI 切面、体验切面、契约切面、文档切面 |
| 文档债清理 | 修复旧路径、旧索引或旧说明，不做功能开发 | path confirmation、archive/retire、docs gate |

前三种是开发模式，`doc_debt_cleanup` 是维护模式。四者共同组成工作入口。

## 文件夹内容

- `SKILL.md`: 给 AI/Agent 使用的执行入口。
- `references/00-operating-model.md`: 拓扑式模块化治理的核心模型。
- `references/01-topology-map.md`: 如何建立模块拓扑图。
- `references/02-work-mode-router.md`: 三种开发模式加一种维护模式如何路由。
- `references/03-closeout-and-gates.md`: 拓扑一致性 closeout 和门禁。
- `references/04-adoption-guide.md`: 如何接入既有项目。
- `references/05-sample-walkthrough.md`: 从只读盘点到 closeout 的完整示例。
- `references/06-productization-checklist.md`: 判断这个包是否达到产品化可用的检查表。
- `references/07-paper-topological-modular-governance.md`: 拓扑式模块化治理的严谨方法论文。
- `templates/TOPOLOGY_MODULE_NODE.md`: 白箱节点模板。
- `templates/TOPOLOGY_TASK_CARD.md`: 任务入口卡模板。
- `templates/PROJECT_TOPOLOGY.md`: 项目级拓扑总图模板。
- `templates/WORK_MODE_ROUTER.md`: 工作模式路由模板。
- `templates/TOPOLOGY_CLOSEOUT.md`: 拓扑 closeout 模板。
- `templates/AI_START_PROMPT.md`: 可直接交给 AI 的启动提示词。
- `scripts/bootstrap-topological-governance.ps1`: 将模板和脚本安装到目标项目。
- `scripts/check-topological-governance.ps1`: 检查目标项目的拓扑治理骨架，`-Strict` 检查已填字段、父节点、真实路径和 closeout 证据。
- `scripts/inventory-topology.ps1`: 只读盘点目标项目的拓扑候选信息。
- `scripts/check-topology-cursor.ps1`: 检查唯一当前游标。
- `scripts/check-topology-ledger.ps1`: 检查 closeout ledger。
- `scripts/check-forbidden-sibling-edges.ps1`: 检查 release-transition 例外授权。
- `schemas/`: 机器可读协议 schema。
- `examples/`: CI、ledger 和已填充 sample project。

## 与相邻包的区别

| 包 | 重点 |
| --- | --- |
| `heavy-scale-exploitation-governance-1` | 建立完整重型治理体系，包含 GP、矩阵、全量树、模块树和门禁 |
| `modular-refactor` | 具体执行模块抽离、整理和等价重构 |
| `topological-modular-governance` | 把项目治理抽象为网络拓扑，规定节点、边、工作模式和一致性 closeout |

推荐组合：

```text
heavy-scale-exploitation-governance-1
  -> 建治理地基

topological-modular-governance
  -> 把治理组织成模块网络拓扑

modular-refactor
  -> 在拓扑边界内执行具体抽离
```

## 产品化能力等级

这个包默认达到 `L3 Product-Like`：

| 等级 | 含义 | 当前状态 |
| --- | --- | --- |
| L1 Method | 有清晰概念和规则 | 已具备 |
| L2 Package | 有 README、SKILL、references、templates | 已具备 |
| L3 Product-Like | 有 bootstrap、check、inventory、prompt、walkthrough | 已具备 |
| L4 Operational | 接入具体项目 CI、真实门禁、项目级双树和案例证据 | 需要在目标项目内落地 |

## 成功标准

一套拓扑式治理真正生效时，开发者应该能快速回答：

1. 这个需求会改哪一个父模块？
2. 会影响哪些子节点和 public 方法？
3. 有没有改边、改端口、改状态、改契约？
4. 这次属于重构、推进、切面打磨，还是文档债？
5. 新旧拓扑怎么共存、切换和裁剪？
6. closeout 后模块树、全量树、代码、测试、文档是否仍指向同一个事实？
