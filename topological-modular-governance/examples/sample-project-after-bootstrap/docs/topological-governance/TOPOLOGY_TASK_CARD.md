# Topology Task Card

```text
work_mode: refactor
reason: preserve behavior while routing sample backend routes through parent facade
allowed_scope: docs/topological-governance, src/backend

parent_node: sample.backend
affected_child_nodes: sample.backend.routes
changed_edges: routes enter through sample.backend facade
public_methods_or_ports: none
state_or_side_effects: none

full_tree_paths: src/backend
module_tree_nodes: sample.backend
legacy_paths: none

gates: manual: sample route smoke passed
exit_gate: topology closeout can be written with result closed
rollback: restore previous route registration through sample backend facade
```
