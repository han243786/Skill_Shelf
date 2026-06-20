# Topology Task Card

Use this before starting a non-trivial task.

```text
work_mode:
reason:
allowed_scope:
north_star_alignment:
growth_vector:
governance_heat:
required_depth:
heat_reason:

parent_node:
affected_child_nodes:
changed_edges:
public_methods_or_ports:
state_or_side_effects:
interface_freeze:
local_invariants:

full_tree_paths:
module_tree_nodes:
legacy_paths:

gates:
exit_gate:
rollback:
stop_if:
```

## Mode Choices

| Mode | Use When |
| --- | --- |
| `refactor` | behavior should stay equivalent |
| `advance` | new capability, route, schema, event, API, UI surface, or module is added |
| `aspect_polish` | a horizontal slice is isolated, forked, optimized, and cut over |
| `doc_debt_cleanup` | stale paths or old docs are repaired without feature work |

## Heat Choices

| Heat | Minimum Depth | Use When |
| --- | --- | --- |
| `G0` | `Light` | leaf-only work with no interface, state, persistence, security, or runtime semantic change |
| `G1` | `Light` | private module-internal cleanup |
| `G2` | `Standard` | public surface, parent-child relation, file movement, or module edge changes |
| `G3` | `Standard` | user-visible entry, capability, route, schema, event, command, or UI surface changes |
| `G4` | `Precision` | runtime, state machine, persistence, security, external IO, money, or trading semantics |
| `G5` | `Precision` | release closeout, failed handoff, unknown regression, or repeated architecture error |

## Quick Closeout

```text
topology_closeout:
  mode:
  parent:
  north_star_alignment:
  convergence_evidence:
  governance_heat:
  required_depth:
  nodes_changed:
  edges_changed:
  public_surface:
  local_invariants:
  interface_freeze:
  full_tree:
  module_tree:
  gates:
  evidence:
  old_paths:
  result:
  next:
```
