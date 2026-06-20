# North Star

North Star is the final-state premise for directional growth. It replaces milestone planning as the default way to orient development.

```yaml
north_star:
  final_state:
  success_shape:
  user_value:
  non_goals:
    -
current_position:
  known_good:
    -
  known_gap:
    -
  uncertainty:
    -
growth_direction:
  next_growth:
  why_this_moves_toward_final_state:
  expected_clarity_gain:
anti_regression:
  protected_behaviors:
    -
  protected_interfaces:
    -
  protected_tree_paths:
    -
convergence_evidence:
  feature_tree:
  module_tree:
  tests_or_smoke:
  manual_checks:
clarity_log:
  -
```

## Rules

1. Do not create milestones as default planning units.
2. A task is valid when it moves the project measurably toward `final_state`.
3. The North Star may become clearer as the project approaches it, but clarity changes must be recorded in `clarity_log`.
4. A growth step must not regress protected behavior, protected interfaces, feature tree facts, or topology tree facts.
5. Deferred work is not technical debt unless it contradicts the North Star or blocks convergence evidence.
