# Topology Task Card

Use this before starting a non-trivial task.

```text
work_mode:
reason:
allowed_scope:

parent_node:
affected_child_nodes:
changed_edges:
public_methods_or_ports:
state_or_side_effects:

full_tree_paths:
module_tree_nodes:
legacy_paths:

gates:
exit_gate:
rollback:
```

## Mode Choices

| Mode | Use When |
| --- | --- |
| `refactor` | behavior should stay equivalent |
| `advance` | new capability, route, schema, event, API, UI surface, or module is added |
| `aspect_polish` | a horizontal slice is isolated, forked, optimized, and cut over |
| `doc_debt_cleanup` | stale paths or old docs are repaired without feature work |

## Quick Closeout

```text
topology_closeout:
  mode:
  parent:
  nodes_changed:
  edges_changed:
  public_surface:
  full_tree:
  module_tree:
  gates:
  old_paths:
  result:
  next:
```
