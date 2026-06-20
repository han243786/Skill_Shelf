# Full Feature Tree

```yaml
feature_tree_version: sample-v1
north_star: docs/topological-governance/NORTH_STAR.md
root_capabilities:
  - sample backend route facade
active_growth_paths:
  - sample.backend.routes
protected_behaviors:
  - sample route smoke stays passing
known_gaps:
  - sample.backend.state not filled yet
feature_nodes:
  - id: sample.backend.routes
    parent: sample.backend
    status: active
    user_value: sample route behavior enters through parent facade
    main_paths:
      - src/backend
    public_surface:
      - sample backend route facade
    tests_or_smoke:
      - manual: sample route smoke passed
    north_star_alignment: route growth preserves parent facade
growth_edges:
  - from: sample.backend.routes
    to: sample.backend.state
    reason: next growth clarifies backend state ownership
    evidence: next cursor action
```
