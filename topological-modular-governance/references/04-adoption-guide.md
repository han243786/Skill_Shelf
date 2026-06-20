# Adoption Guide

把拓扑式模块化治理接入已有项目时，不要一上来追求完美。先让项目变得可见，再逐步让规则变硬。

## 1. 接入顺序

推荐五步：

```text
盘点现实 -> 写北极星 -> 建功能树和拓扑树 -> 接 QPCursor/热度/局部护栏 -> 接 closeout
```

### 第一步：盘点现实

列出：

- 入口文件
- 顶层模块
- 最大文件
- public API / route / schema / event
- 状态、锁、持久化、外部 IO
- 测试入口
- 文档入口
- 构建和发布命令

### 第二步：写北极星

先写最终状态，而不是铺里程碑：

- 最终达成时系统是什么样。
- 哪些行为必须被保护。
- 当前离目标最近的下一段生长是什么。
- 哪些未知会随着推进变清楚。

### 第三步：建功能树和拓扑树

先做粗粒度：

- 功能树记录能力、用户价值、保护行为和真实路径。
- 拓扑树记录顶层父模块、主要子模块和通信边。

不要一开始就把每个小函数都登记成节点。

### 第四步：定父子边

先写硬规则：

```text
开发态禁止子模块横向直连。
跨子模块通信必须经父级、契约、adapter、事件或登记接口。
发布版本性能过渡只能由开发者明确启动。
```

### 第五步：接工作模式

每次任务先判定：

- 重构模式
- 推进模式
- 切面打磨模式
- 文档债清理

这样可以防止所有任务都混成“继续”。

### 第六步：接 QPCursor、热度和局部不变量

先让每个任务都能声明：

- 当前 QPCursor
- 北极星对齐
- 生长向量
- G0-G5 治理热度
- Light / Standard / Precision 强度
- 当前父模块的局部不变量
- interface freeze
- allowed workset
- evidence

### 第七步：接 closeout

先人工 closeout，再逐步脚本化：

- north star alignment
- full feature tree sync
- module topology tree sync
- old path check
- targeted tests
- smoke
- API/schema check

## 2. 轻量接入

适合中型项目或早期团队：

```text
PROJECT_MAP
MODULE_BOUNDARIES
WORK_MODE_CARD
CLOSEOUT_CARD
```

只要求每轮能回答节点、边、模式和验证即可。

## 3. 高风险接入

适合高风险项目：

```text
North Star
Full Feature Tree
Module Topology Tree
QPCursor
Governance Heat
Local Invariants
Closeout Ledger
```

旧式重型治理包可以作为历史参考，但不再是默认入口。默认入口是北极星、功能树、拓扑树和 QPCursor。

## 4. 与模块化重构衔接

拓扑治理负责回答：

```text
哪里能动？
动哪条边？
谁是父级？
怎么证明拓扑没有坏？
```

模块化重构负责执行：

```text
怎么抽？
怎么整理？
怎么保持行为等价？
怎么关闭叶子？
```

因此推荐：

```text
topological-modular-governance
  -> 确定父级、节点、边、模式、closeout

modular-refactor
  -> 执行具体抽离、整理、重构
```

## 5. 常见误区

| 误区 | 后果 | 修正 |
| --- | --- | --- |
| 把拓扑治理当成文件树 | 只知道文件，不知道 owner 和通信边 | 建模块树白箱节点 |
| 所有任务都叫继续 | 递归状态污染 | 每轮先判定工作模式 |
| 小改动滥用轻量卡 | 接口、状态、旧路径被偷改 | 命中升档触发器就升档 |
| 大树一大就拆 | 增加索引成本和漂移 | 只在定位效率或门禁可靠性受损时拆 |
| AI 主动提发布过渡 | 过早引入横向连接复杂度 | 只能开发者明确启动 |

## 6. 第一次落地的验收标准

第一次落地不要求完整自动化，但至少要做到：

1. 有项目物理地图。
2. 有顶层模块拓扑。
3. 有父子通信硬规则。
4. 有工作模式入口卡。
5. 有北极星、功能树、拓扑树。
6. 有 QPCursor、治理热度和局部防回退护栏。
7. 有 closeout 卡。
8. 有旧路径债处理原则。
9. 有“什么时候不拆大树”的规则。
