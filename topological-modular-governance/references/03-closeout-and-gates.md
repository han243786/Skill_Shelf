# Closeout And Gates

拓扑式治理的 closeout，不是“我改完了”，而是“网络仍然一致”。

## 1. 拓扑一致性 closeout

每次 closeout 至少回答：

```text
work_mode:
cursor_id:
governance_heat:
required_depth:
changed_nodes:
changed_edges:
public_surface:
local_invariants:
parent_child_rule:
full_tree_sync:
module_tree_sync:
tests_or_smoke:
evidence:
legacy_paths:
residual_risk:
next_cursor:
```

## 2. 常见门禁

| 门禁 | 证明什么 |
| --- | --- |
| 格式 / lint | 基础代码质量没有退 |
| 单元测试 | 叶子行为没有退 |
| 集成测试 / smoke | 父级边界仍能跑通 |
| 北极星对齐检查 | 本轮结果仍朝最终状态收敛，没有把新缺口伪装成完成态 |
| 功能树/全量树检查 | active 文件、能力事实和文档地图一致 |
| 模块树/拓扑树检查 | 逻辑节点、public owner、父子边没有漂移 |
| 旧路径检查 | 文档没有继续指向已不存在的旧事实 |
| API / schema 检查 | 外部契约没有隐式破坏 |
| Cursor 拓扑检查 | 当前游标的 `parent_node` 必须存在于项目拓扑图 |
| Ledger 检查 | 运行态 closeout 必须留下非空 ledger 记录 |
| Release-transition 例外检查 | 横向直连必须有开发者授权、性能证据、review/expiry 和 rollback |
| QPCursor governance 检查 | 北极星、功能树、拓扑树、热度、局部不变量、强度映射和 evidence 必须完整 |

## 3. AI 幻觉发现点

把以下内容作为高风险信号：

- AI 引用的文件不存在。
- AI 声称的 public 方法搜不到。
- AI 说“无影响”，但工作模式影响了节点或边。
- AI 说“只是文档”，但实际改了接口、状态、路径或模块 owner。
- AI 让子模块直接调用 sibling。
- AI 在 cursor 中写入不存在的 parent node。
- AI 把空 closeout 当成完成态。
- AI 用 `bot`、`trust me` 或空泛说明伪造 release-transition 例外。
- AI 把用户一次性问题混进长期递归状态。

处理方式：

1. 停止扩大范围。
2. 回到拓扑卡。
3. 只读核对真实文件、真实节点、真实边。
4. 缩小 workset 后再继续。

## 4. 冷文档与热资产

不是所有文档都应该高频维护。

| 类型 | 处理方式 |
| --- | --- |
| 热资产 | 北极星、功能树/全量树、模块树/拓扑树、当前契约、工作模式路由、局部防回退护栏 |
| 冷文档 | 历史路线、旧状态总表、长篇背景手册 |
| 旧路径债 | 单独批次清理，不混入功能推进 |

大文件不是问题；低效定位才是问题。

允许保留大树，只要：

- 搜索定位快。
- 路径反查可靠。
- 门禁稳定。
- 新人能通过结构化标题或关键词找到入口。

## 5. Closeout 模板

```text
topology_closeout:
  mode:
  north_star_alignment:
  growth_vector:
  parent:
  nodes_changed:
  edges_changed:
  public_surface:
  old_paths:
  full_tree:
  module_tree:
  gates:
  result:
  next:
```

## 6. 失败时怎么收缩

如果 closeout 失败，不要立刻开更大范围。

优先顺序：

1. 判断是代码失败、测试失败、地图失败还是模式失败。
2. 若是模式失败，回到 work-mode router。
3. 若是地图失败，转文档债清理。
4. 若是代码失败，缩小到当前父节点。
5. 若是边界失败，恢复父子通信规则。
