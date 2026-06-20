# Topology Cursor

The topology cursor is now QPCursor-compatible. It keeps the original topology slice discipline and adds governance heat, local invariants, interface freeze, evidence, and stop rules.

Machine-readable source:

```text
CURRENT_CURSOR.yaml
```

Protocol reference:

```text
QPCURSOR.md
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
    - none
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
  - sibling_direct_dependency_without_release_transition_exception
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

## Rules

1. A task cannot start if `parent_node` is empty.
2. A task cannot edit outside `allowed_workset.editable_files` without updating the cursor.
3. A mode jump must push a new entry into `mode_stack` and declare a return condition in `handoff_notes`.
4. `status: closed` requires a topology closeout and a ledger row.
5. `status: blocked` requires `next_action`.
6. `governance_heat` must be present before implementation.
7. G2-G3 work requires `Standard`; G4-G5 work requires `Precision`.
8. Local invariants must be loaded before editing a module.
9. Interface freeze must say `none` explicitly when no public surface is frozen.
10. Evidence must name real commands, real manual checks, completed evidence, and pending risks.
11. Each cursor must explain how the next action grows toward `NORTH_STAR.md`.
