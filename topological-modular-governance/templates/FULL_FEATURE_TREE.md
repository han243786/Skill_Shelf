# Full Feature Tree

The full feature tree is the feature-facing full tree. It records what the product can do, where the facts live, and which growth paths are active.

```yaml
feature_tree_version:
north_star:
root_capabilities:
  -
active_growth_paths:
  -
protected_behaviors:
  -
known_gaps:
  -
feature_nodes:
  - id:
    parent:
    status: candidate | active | protected | deprecated | retired
    user_value:
    main_paths:
      -
    public_surface:
      -
    tests_or_smoke:
      -
    north_star_alignment:
growth_edges:
  - from:
    to:
    reason:
    evidence:
```

## Rules

1. The feature tree answers what user-facing or product-facing capability exists.
2. It is not a milestone list.
3. Each active feature node must point to real paths, public surfaces, or explicit evidence.
4. A new module should explain which feature tree node it grows.
5. Closeout must confirm whether the feature tree changed or stayed valid.
