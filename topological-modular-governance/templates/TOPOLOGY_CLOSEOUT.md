# Topology Closeout

Use this at the end of every topology-aware task.

```text
topology_closeout:
  mode:
  parent:
  nodes_changed:
  edges_changed:
  public_surface:
  state_or_side_effects:
  full_tree:
  module_tree:
  contracts:
  tests_or_smoke:
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
  topology_scope_respected:
  no_new_doc_debt:
  lightweight_not_abused:
```
