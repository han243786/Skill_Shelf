# Skill Shelf

`D:\Skill_Shelf` 是本机可复用技能、治理体系和工程方法包的统一货架。

这里的每个子目录都应该是一个独立可读、可复制、可被 AI 或开发者直接使用的能力包。顶层只负责导航和管理，不承载具体项目逻辑。

## 当前目录

| 包 | 用途 | 适合场景 |
| --- | --- | --- |
| [`light-scale-exploitation-governance-1`](./light-scale-exploitation-governance-1/README.md) | 中小型项目轻治理体系 | 个人项目、小团队、半途轻量接入、避免文档和流程过重 |
| [`heavy-scale-exploitation-governance-1`](./heavy-scale-exploitation-governance-1/README.md) | 重型项目开发治理体系 | 多模块、多技术栈、高风险发布、需要 GP/矩阵/模块树/门禁/closeout 的项目 |
| [`modular-refactor`](./modular-refactor/README.md) | 模块化重构协议 | 任意规模代码库的模块抽离、依赖解缠、父子边界治理、等价基线验证 |
| [`topological-modular-governance`](./topological-modular-governance/README.md) | 拓扑式模块化治理 | 把大型项目当成白箱模块网络治理，管理节点、父子边、工作模式、旧新拓扑切换和一致性 closeout |

## 怎么选择

| 需求 | 优先使用 |
| --- | --- |
| 想给小项目加一点秩序，但不想变重 | `light-scale-exploitation-governance-1` |
| 项目已经很大，经常因为结构混乱返工 | `heavy-scale-exploitation-governance-1` |
| 当前目标是拆文件、拆模块、整理依赖 | `modular-refactor` |
| 想把模块树、全量树、工作模式和 closeout 组织成网络拓扑 | `topological-modular-governance` |
| 小项目未来可能变大 | 先用轻治理，再按升级信号迁移到重治理 |
| 重构过程中需要治理配合 | `modular-refactor` + 对应规模的治理包 |

## 推荐组合

### 小项目

```text
light-scale-exploitation-governance-1
  -> PROJECT_MAP
  -> GENERAL_POLICY
  -> CHANGE_FLOW
```

### 中型项目

```text
light-scale-exploitation-governance-1
  -> PROJECT_MAP
  -> MODULE_BOUNDARIES
  -> CHANGE_FLOW

modular-refactor
  -> 针对核心模块做受控抽离
```

### 重型项目

```text
heavy-scale-exploitation-governance-1
  -> 全量树
  -> 模块树
  -> General Policy
  -> 超级规范化
  -> 门禁与 closeout

topological-modular-governance
  -> 把全量树和模块树组织成白箱网络拓扑
  -> 先判定工作模式，再改变节点或边

modular-refactor
  -> 在模块树边界内执行递归重构
```

## 通用使用方式

每个包至少应该有：

- `README.md`: 给人看的入口。
- `SKILL.md`: 给 AI/Agent 使用的执行说明。
- `references/`: 按需加载的详细方法。

如果包需要落地到项目中，还可以有：

- `templates/`: 可复制到目标项目的模板。
- `scripts/`: 可执行脚本。

## 管理规范

统一管理规则见：

[`SKILL_SHELF_STANDARD.md`](./SKILL_SHELF_STANDARD.md)

可执行检查脚本：

[`SKILL_SHELF_STANDARD.ps1`](./SKILL_SHELF_STANDARD.ps1)

修改任何子包前，先看管理规范；改名、拆分、废弃、合并包时，必须同步更新本 README。
