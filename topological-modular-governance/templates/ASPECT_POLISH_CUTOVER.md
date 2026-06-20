# Aspect Polish Cutover

Use this when `work_mode = aspect_polish`.

```yaml
aspect_polish_cutover:
  source_slice:
  mirror_slice:
  frozen_interfaces:
    - 
  shared_state: none
  migration_needed: false
  dual_run_required: false
  feature_flag: none
  old_path_retirement: none
  rollback_plan:
  cutover_gate:
  cutover_result: pending
```

## Required Decisions

| Field | Meaning |
| --- | --- |
| `source_slice` | Old topology slice being mirrored |
| `mirror_slice` | New isolated topology slice |
| `frozen_interfaces` | Public surfaces that must not change during optimization |
| `shared_state` | `none`, `read_only`, `shared_write`, or migration description |
| `migration_needed` | Whether state or persistence migration is required |
| `dual_run_required` | Whether old and new paths must run side-by-side before cutover |
| `feature_flag` | Flag or switch used for controlled cutover |
| `old_path_retirement` | `none`, `retire_after_gate`, `archive`, or `manual_followup` |
| `rollback_plan` | One clear rollback route |
| `cutover_gate` | Test, smoke, manual validation, or CI gate |

## Hard Rules

1. Do not cut over while the mirror cannot run independently.
2. Do not retire old paths until `cutover_gate` passes.
3. Shared writable state forces at least G4 / Precision.
4. Missing rollback blocks cutover.
