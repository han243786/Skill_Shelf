# QPCursor Protocol

QPCursor is the handoff contract for topology governance. It is stricter than a task note: another agent should be able to continue from it without reading chat history.

Machine-readable source:

```text
CURRENT_CURSOR.yaml
```

Required fields:

```yaml
cursor_version:
cursor_id:
status: draft | claimed | reading_context | executing | evidence_pending | gate_pending | handoff_ready | closed | blocked
repo_baseline:
  branch:
  commit:
  growth_position:
mode_stack:
  - mode: refactor | advance | aspect_polish | doc_debt_cleanup
    step:
north_star:
  source:
  alignment:
growth_vector:
  current_position:
  next_growth:
  convergence_signal:
scope:
  user_function_facet:
  full_feature_tree:
  module_tree:
  leaf:
topology_slice:
  parent_node:
  child_nodes:
    -
  changed_edges:
    -
governance_heat: G0 | G1 | G2 | G3 | G4 | G5
required_depth: Light | Standard | Precision
heat_reason:
local_invariants:
  module:
  source:
interface_freeze:
  api:
  capability:
  event_schema:
  persistence_schema:
  ui_route:
anti_regression:
  protected_behaviors:
    -
  protected_interfaces:
    -
  protected_tree_paths:
    -
allowed_workset:
  editable_files:
    -
  readonly_files:
    -
  sync_after_change:
    -
forbidden_operations:
  -
gates:
  -
closeout_required: true
next_action:
done_when:
stop_if:
  -
evidence:
  required_commands:
    -
  manual_checks:
    -
  completed:
    -
  pending_risks:
    -
handoff_notes:
```

## Heat To Depth

| Heat | Minimum depth |
| --- | --- |
| G0-G1 | Light |
| G2-G3 | Standard |
| G4-G5 | Precision |

Governance depth may be stronger than the minimum, but it must not be weaker.

## Stop Rules

Stop and update the cursor before acting if:

1. A needed file is outside `allowed_workset.editable_files`.
2. The task changes API, capability, event schema, persistence schema, route, auth, security, state, lock, or runtime semantics without the correct heat level.
3. The task needs a sibling direct dependency without an approved release-transition exception.
4. Evidence cannot be tied to a real command, file, smoke test, manual check, or explicit risk.
5. The step cannot explain how it grows toward the North Star.
