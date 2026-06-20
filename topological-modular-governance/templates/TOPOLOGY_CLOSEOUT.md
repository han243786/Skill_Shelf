# Topology Closeout

Use this at the end of every topology-aware task.

```text
topology_closeout:
  mode:
  parent:
  cursor_id:
  north_star_alignment:
  convergence_evidence:
  governance_heat:
  required_depth:
  nodes_changed:
  edges_changed:
  public_surface:
  state_or_side_effects:
  local_invariants:
  interface_freeze:
  full_tree:
  module_tree:
  contracts:
  tests_or_smoke:
  evidence:
  old_paths:
  result:
  next:
```

## Result Rules

`result` must be one of:

- `closed`
- `closed_with_debt`
- `blocked`
- `needs_mode_jump`

## Minimum Quality Line

```text
quality_speed_guard:
  mode_entry_checked:
  north_star_alignment_checked:
  heat_checked:
  local_invariants_loaded:
  topology_scope_respected:
  no_new_doc_debt:
  lightweight_not_abused:
  qpcursor_updated:
```
