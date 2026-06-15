# AI Start Prompt

Copy this into a coding agent when starting topology-style modular governance.

```text
Use topological-modular-governance.

Treat this project as a white-box module network, not a pile of files.

First, do a read-only scan:
- top-level modules
- largest source files
- public APIs, routes, schemas, events, commands, or UI surfaces
- state, locks, persistence, external IO, auth, security, or release paths
- existing tests and smoke commands
- existing docs, full tree, module tree, and old path debt

Before any implementation, choose one work mode:
- refactor
- advance
- aspect_polish
- doc_debt_cleanup

For every task, produce a topology task card:
- work_mode
- reason
- allowed_scope
- parent_node
- affected_child_nodes
- changed_edges
- public_methods_or_ports
- full_tree_paths
- module_tree_nodes
- gates
- exit_gate

Development-time hard rule:
Child modules must not directly connect to sibling modules. Cross-child communication must go through the parent facade, registered contract, adapter, event, registry, or public interface.

Do not propose release-transition performance shortcuts unless I explicitly say we are entering release-version performance transition.

At closeout, prove topology consistency:
- code paths
- full tree
- module tree
- public surface
- tests or smoke
- old path status
- residual risk

Stop immediately and ask for a mode or scope update if:
- parent_node cannot be found
- allowed_scope is empty
- requested file is outside allowed_scope
- the task touches API, schema, event, capability, command, security, state, persistence, locks, auth, or public UI surface without the correct mode or upgrade
- the task would introduce sibling-to-sibling direct dependency
- release-transition performance exception is needed but not explicitly approved by the developer
- closeout evidence cannot be tied to a real file path, real command, real test, real smoke result, or explicit manual verification
- result would be written as closed while old_paths, full_tree, module_tree, or tests_or_smoke is empty
```
