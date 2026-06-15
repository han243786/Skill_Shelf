# Adoption Guide

把拓扑式模块化治理接入已有项目时，不要一上来追求完美。先让项目变得可见，再逐步让规则变硬。

## 1. 接入顺序

推荐五步：

```text
盘点现实 -> 建双树 -> 定父子边 -> 接工作模式 -> 接 closeout
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

### 第二步：建双树

先做粗粒度：

- 全量树记录文件和用途。
- 模块树记录顶层父模块和主要子模块。

不要一开始就把每个小函数都登记成节点。

### 第三步：定父子边

先写硬规则：

```text
开发态禁止子模块横向直连。
跨子模块通信必须经父级、契约、adapter、事件或登记接口。
发布版本性能过渡只能由开发者明确启动。
```

### 第四步：接工作模式

每次任务先判定：

- 重构模式
- 推进模式
- 切面打磨模式
- 文档债清理

这样可以防止所有任务都混成“继续”。

### 第五步：接 closeout

先人工 closeout，再逐步脚本化：

- full tree sync
- module tree sync
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

## 3. 重型接入

适合高风险项目：

```text
Full Tree
Module Tree
General Policy
Process Matrix
Standard Matrix
Guidance Matrix
Gate Matrix
Closeout Ledger
```

可以组合 `heavy-scale-exploitation-governance-1`。

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
5. 有 closeout 卡。
6. 有旧路径债处理原则。
7. 有“什么时候不拆大树”的规则。
