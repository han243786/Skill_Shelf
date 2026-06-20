# Topology Task Card

```text
work_mode: refactor
reason: preserve behavior while routing sample backend routes through parent facade
allowed_scope: docs/topological-governance, src/backend
north_star_alignment: route growth preserves sample backend parent facade
growth_vector: sample.backend.routes closed; next growth is sample.backend.state
governance_heat: G2
required_depth: Standard
heat_reason: parent-child route facade edge is being declared and checked

parent_node: sample.backend
affected_child_nodes: sample.backend.routes
changed_edges: routes enter through sample.backend facade
public_methods_or_ports: none
state_or_side_effects: none
interface_freeze: api unchanged; no capability/event/persistence/ui route change
local_invariants: docs/topological-governance/LOCAL_INVARIANTS.md

full_tree_paths: src/backend
module_tree_nodes: sample.backend
legacy_paths: none

gates: manual: sample route smoke passed
exit_gate: topology closeout can be written with result closed
rollback: restore previous route registration through sample backend facade
stop_if: route facade work requires new public API or sibling direct dependency
```
