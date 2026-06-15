# Topology Map

拓扑图不是画得越复杂越好，而是要让开发者快速定位：哪个节点、哪条边、哪个父级、哪个验证门。

## 1. 从物理地图开始

先建立全量树，回答：

- 项目有哪些源码目录？
- 哪些是 active 文件？
- 哪些是测试、脚本、文档、生成物、缓存、归档？
- 哪些文件是入口，哪些只是叶子实现？

全量树只管“有什么”，不要把所有治理规则塞进去。

## 2. 再建立逻辑拓扑

模块树回答：

- 父模块是谁？
- 子模块是谁？
- 这个模块的输入是什么？
- 输出是什么？
- 关键 public 方法是什么？
- 状态、锁、持久化、外部 IO 由谁拥有？
- 子模块之间是否存在不允许的横向连接？
- 测试或 smoke 证据在哪里？

推荐节点格式：

```text
node:
parent:
purpose:
inputs:
outputs:
public_surface:
state_owner:
side_effects:
children:
allowed_edges:
forbidden_edges:
tests_or_gates:
status:
```

## 3. 分层原则

常见层级：

```text
global root
  -> domain / bounded context
    -> parent module
      -> child module
        -> leaf module
```

不要为了显得规范而无限细分。叶子是否继续拆，取决于收益和成本。

## 4. 叶子停止规则

建议停止继续细分的信号：

1. 叶子已经有清楚输入输出。
2. public surface 很小，owner 明确。
3. 内部没有独立状态机、锁、持久化或外部协议。
4. 继续拆会增加父子转发和文档成本，却不能显著提升测试、复用或理解。
5. 下一个开发者已经能在 1-2 次搜索内定位它。

建议继续细分的信号：

1. 一个叶子内部仍有多个独立 owner。
2. 同时管理状态、协议、IO、校验、转换等多类职责。
3. 测试失败时无法快速定位是哪一段逻辑。
4. public 方法过多，且被不同调用方当成不同能力使用。
5. 继续拆能显著减少冲突、提升复用或降低风险。

## 5. 双树关系

| 树 | 作用 | 不该做什么 |
| --- | --- | --- |
| 全量树 | 文件和能力物理定位 | 不重复写模块治理细则 |
| 模块树 | 白箱网络和父子通信 | 不伪造代码里不存在的模块 |

大树不等于坏树。如果搜索、路径反查和门禁仍然稳定，文件体量本身不是拆分理由。

## 6. 常用查询

```powershell
rg -n "module.node.name" markdown
rg -n "src/path/to/file" markdown
rg -n "public_method_name" markdown src tests
rg -n "legacy_path|old_entry|deprecated" markdown src tests
```

如果这些查询仍然能快速定位，说明拓扑地图可用。
