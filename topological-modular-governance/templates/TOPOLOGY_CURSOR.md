# Topology Cursor

The cursor is the single current coordinate for agent handoff. It prevents the next agent from reconstructing state from chat history.

Machine-readable source:

```text
CURRENT_CURSOR.yaml
```

Required fields:

```yaml
cursor_id:
status: active | blocked | closed | superseded
work_mode_stack:
  - mode: refactor | advance | aspect_polish | doc_debt_cleanup
    step:
topology_slice:
  parent_node:
  child_nodes:
    - 
  changed_edges:
    - none
allowed_workset:
  editable_files:
    - 
  readonly_files:
    - 
forbidden_operations:
  - sibling_direct_dependency_without_release_transition_exception
gates:
  - 
closeout_required: true
next_action:
handoff_notes:
```

## Rules

1. A task cannot start if `parent_node` is empty.
2. A task cannot edit outside `allowed_workset.editable_files` without updating the cursor.
3. A mode jump must push a new entry into `work_mode_stack` and declare a return condition in `handoff_notes`.
4. `status: closed` requires a topology closeout and a ledger row.
5. `status: blocked` requires `next_action`.
