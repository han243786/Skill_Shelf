# Local Invariants

```yaml
module: sample.backend
scope:
  user_function_facet: sample.backend.routes
  full_feature_tree: src/backend
  module_tree: sample.backend.routes
  leaf: src/backend/README.md
public_surface:
  - sample backend route facade
allowed_edges:
  - sample.backend -> sample.backend.routes
forbidden_edges:
  - sample.backend.routes -> sample.backend.state direct private call
local_invariants:
  - routes must enter through sample.backend facade
north_star_refs:
  - route growth preserves parent facade
heat_escalation:
  - new public route requires G3
  - state owner change requires G4
stop_if:
  - a child route needs direct state-module access
  - the sample route facade needs a new public API
gates:
  - manual: sample route smoke passed
```
