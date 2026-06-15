# Topology Module Node

```text
node: sample.backend
parent: sample
status: active
purpose: sample backend parent facade

inputs:
- sample request

outputs:
- sample response

public_surface:
- none

state_owner:
- none

side_effects:
- none

children:
- sample.backend.routes

allowed_edges:
- sample.backend.routes -> sample.backend facade

forbidden_edges:
- sample.backend.routes -> sample.backend.state direct private call

full_tree_paths:
- src/backend

tests_or_gates:
- manual: sample route smoke passed

closeout_rule:
- close only when parent facade and topology closeout agree
```
