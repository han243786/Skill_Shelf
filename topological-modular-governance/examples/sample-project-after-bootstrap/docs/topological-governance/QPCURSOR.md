# QPCursor Protocol

This sample uses `CURRENT_CURSOR.yaml` as the machine-readable QPCursor.

Required fields are demonstrated by `CURSOR-0001`:

- cursor_version
- cursor_id
- status
- repo_baseline
- mode_stack
- north_star
- growth_vector
- scope
- topology_slice
- governance_heat
- required_depth
- heat_reason
- local_invariants
- interface_freeze
- anti_regression
- allowed_workset
- forbidden_operations
- gates
- closeout_required
- next_action
- done_when
- stop_if
- evidence

For this sample, `G2` maps to `Standard` because the task declares a parent-child route facade edge.
