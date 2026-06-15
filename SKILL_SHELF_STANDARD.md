# Skill Shelf 统一管理规范

本规范用于管理 `D:\Skill_Shelf` 下的所有技能包、治理包和工程方法包。

目标是让这个目录长期保持可读、可找、可复用、可迁移，而不是变成一堆一次性提示词和旧文档。

可执行检查脚本见同目录：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\Skill_Shelf\SKILL_SHELF_STANDARD.ps1
```

## 1. 基本原则

1. 一个子目录只解决一类稳定问题。
2. 包名必须表达用途，不表达临时项目名。
3. 顶层 README 负责导航，子包 README 负责使用。
4. 规则、模板、脚本要分层存放，避免混在一个长文档里。
5. 能直接落地的包必须给出最短使用路径。
6. 任何改名都必须同步修改 `SKILL.md`、README、模板提示词和顶层索引。
7. 不把某个项目的特殊经验伪装成通用规则；特殊经验应放在 case/source/reference 中。

## 2. 命名规范

目录名统一使用：

```text
lowercase-kebab-case
```

允许：

- `modular-refactor`
- `light-scale-exploitation-governance-1`
- `heavy-scale-exploitation-governance-1`

不建议：

- `MySkill`
- `new_skill`
- `临时治理方案`
- `v2-final-final`

版本后缀只在确实存在不兼容路线时使用，例如 `-1`。普通文案修正、模板增强和脚本补充不需要改目录名。

## 3. 子包标准结构

### 最小结构

```text
package-name/
  README.md
  SKILL.md
```

### 推荐结构

```text
package-name/
  README.md
  SKILL.md
  references/
  templates/
  scripts/
  schemas/
  examples/
```

### 各目录职责

| 路径 | 职责 |
| --- | --- |
| `README.md` | 面向人类的用途、适用场景、最短使用路径 |
| `SKILL.md` | 面向 AI/Agent 的触发说明、工作流、读取顺序 |
| `references/` | 详细方法、协议、案例、长说明 |
| `templates/` | 可复制到目标项目的模板 |
| `scripts/` | 可执行脚本，必须能独立说明参数和安全边界 |
| `schemas/` | 机器可读协议、JSON Schema、枚举和校验契约 |
| `examples/` | 已填充样例、CI 样例、ledger 样例和 walkthrough 产物 |

## 4. README 要求

每个子包的 README 至少包含：

- 一句话说明。
- 适合什么场景。
- 不适合什么场景，若容易误用。
- 最短使用路径。
- 文件夹内容。
- 与相邻包的区别。

顶层 README 至少包含：

- 当前包列表。
- 每个包的用途。
- 选择建议。
- 管理规范入口。

## 5. SKILL.md 要求

`SKILL.md` 应该短而可执行，至少包含：

- 技能名称或标题。
- 适用场景。
- 读取顺序。
- 默认工作流。
- 禁止事项。
- 预期输出。

如果使用 YAML frontmatter，`name` 必须与目录名一致。若某个包明确不需要 YAML frontmatter，可以只保留 Markdown 标题和正文，但目录 README 必须仍然清楚说明用途。

## 6. References 要求

`references/` 用来承载详细内容，不要把所有知识都塞进 `SKILL.md`。

推荐拆分方式：

| 类型 | 文件例子 |
| --- | --- |
| 运行模型 | `00-operating-model.md` |
| 通用规则 | `01-policy.md` |
| 具体协议 | `protocol.md` |
| 技术栈特化 | `rust-local-protocol.md` |
| 案例来源 | `case-source/` 或 `source/` |

引用项目原始材料时，必须标明它是案例库，不是通用规则。

## 7. Templates 要求

模板应当：

- 可以直接复制到目标项目。
- 保留清晰的 TODO。
- 不绑定单一项目名。
- 不包含已经过期的版本号或路径。
- 不把高风险规则默认写成所有项目必需。

模板文件名使用大写语义名或小写语义名均可，但同一包内要统一。

## 8. Scripts 要求

脚本必须满足：

- 默认不覆盖已有文件，除非提供 `-Force`。
- 支持明确的 `-ProjectRoot` 或等价目标路径。
- 对递归删除、移动、覆盖等操作保持保守。
- 输出清楚说明写入、跳过、失败。
- 可在临时目录中验证。

脚本不应：

- 默认修改系统环境。
- 默认安装全局依赖。
- 默认删除目标项目内容。
- 默认扫描第三方依赖、缓存、构建产物。

## 9. 更新流程

修改一个包时按这个顺序：

1. 读该包 `README.md` 和 `SKILL.md`。
2. 搜索旧名称、旧路径、旧语义。
3. 修改核心说明。
4. 同步模板和脚本中的提示词。
5. 如果包名、用途或适用边界变化，更新顶层 `README.md`。
6. 做最小验证。

推荐搜索：

```powershell
rg -n "old-name|旧名称|旧语义" D:\Skill_Shelf\package-name
```

## 10. 改名流程

改名必须完成：

1. 确认新目录不存在。
2. 修改 `SKILL.md` 中的名称。
3. 修改 README 标题和说明。
4. 修改 references/templates/scripts 中的旧名引用。
5. 移动目录。
6. 搜索确认旧名无残留。
7. 更新顶层 README。

验证示例：

```powershell
Test-Path D:\Skill_Shelf\old-name
Test-Path D:\Skill_Shelf\new-name
rg -n "old-name|Old Name" D:\Skill_Shelf\new-name
```

## 11. 新增包流程

新增包前先问：

- 这个问题是否已经被现有包覆盖？
- 它是独立能力，还是现有包的 reference/template/script？
- 是否需要模板或脚本，还是只需要方法说明？
- 是否会和轻治理、重治理、模块化重构产生边界重叠？

新增后必须：

- 写子包 README。
- 写 SKILL.md。
- 如有脚本，做临时目录验证。
- 更新顶层 README。

## 12. 废弃与合并

不要直接删除仍可能被引用的包。推荐流程：

1. 在 README 顶部标记 `Deprecated`。
2. 指向替代包。
3. 保留一段迁移说明。
4. 确认没有外部引用后再删除。

合并包时，保留语义更清楚的目录名，另一个包先转为迁移说明。

## 13. 轻重分层规则

当前目录有三类基础能力：

| 层级 | 包 | 边界 |
| --- | --- | --- |
| 轻治理 | `light-scale-exploitation-governance-1` | 中小项目，少文件、低仪式感、快速接入 |
| 重治理 | `heavy-scale-exploitation-governance-1` | 重型项目，矩阵、模块树、门禁、closeout |
| 模块重构 | `modular-refactor` | 任意规模的模块抽离和等价保护 |

不要把轻治理扩展成重治理的复制品。轻治理如果开始需要三矩阵、全量树、closeout 常态化，应升级到重治理。

不要把 `modular-refactor` 写成治理包。它负责怎么拆模块；治理包负责怎么管项目。

## 14. 最小验收清单

每次修改 Skill_Shelf 后至少检查：

- 顶层 README 是否仍然列出全部可用包。
- 新旧目录名是否一致。
- `SKILL.md` 名称是否与目录语义一致。
- 子包 README 是否有最短使用路径。
- 脚本是否没有危险默认行为。
- 搜索旧名无残留。

常用命令：

```powershell
Get-ChildItem -Force D:\Skill_Shelf
rg -n "old-name|旧名称" D:\Skill_Shelf
```

## 15. 科学论证检查模型

“万无一失”不能靠口头保证，只能靠可复验的不变量和明确的人工边界共同逼近。

### 15.1 可由脚本证明的不变量

`SKILL_SHELF_STANDARD.ps1` 必须至少检查：

| 不变量 | 证明方式 |
| --- | --- |
| 顶层入口存在 | `README.md`、`SKILL_SHELF_STANDARD.md`、`SKILL_SHELF_STANDARD.ps1` 均存在 |
| 顶层索引完整 | 顶层 README 链接每个实际子包，且不存在指向缺失子包的旧链接 |
| 子包命名稳定 | 所有一级子目录都是 lowercase-kebab-case |
| 子包最小结构完整 | 每个子包都有非空 `README.md` 与 `SKILL.md` |
| Skill 名称一致 | 使用 YAML frontmatter 的 `SKILL.md` 中 `name` 必须等于目录名 |
| Skill 元数据完整 | 使用 YAML frontmatter 时必须有非空 `name` 与 `description` |
| 顶层旧规范清理 | 不允许遗留 `MANAGEMENT.md` |
| 改名无旧名残留 | 不允许残留已废弃包名，例如历史旧目录名 |
| 主动脚本可解析 | 顶层与各子包 `scripts/*.ps1` 必须通过 PowerShell AST 语法解析 |
| 主动脚本默认保守 | 主动脚本不得出现未说明的破坏性默认行为关键词 |
| 顶层文件边界稳定 | 顶层只保留 README、规范 md、规范 ps 和子包目录 |

### 15.2 只能由人工判断的边界

脚本不能证明：

- 一个技能包的知识是否足够优秀。
- 模板是否覆盖了所有未来项目。
- 某个项目经验是否应该上升为通用规则。
- 文档措辞是否在所有上下文中都不会误导。
- 重构或治理方法是否适合某个具体业务场景。

这些必须通过真实使用、案例回放、代码审查和用户反馈持续修正。

### 15.3 完成判定

一次 Skill Shelf 修改只有同时满足以下条件，才算通过：

1. `SKILL_SHELF_STANDARD.ps1` 返回 0。
2. 严格模式 `SKILL_SHELF_STANDARD.ps1 -Strict` 没有 ERROR。
3. 至少做一次反向验证，确认脚本能识别故意破坏的结构。
4. 人工抽查 README、SKILL、references、templates、scripts 的职责没有混乱。
5. 顶层 README 与实际目录完全一致。
