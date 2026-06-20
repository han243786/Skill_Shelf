# Topology Module Node

```text
node: sample.backend
parent: sample
status: active
purpose: sample backend parent facade
governance_heat_floor: G2

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

local_invariants:
- routes must enter through sample.backend facade

policy_refs:
- parent-child communication rule

heat_escalation:
- new public route requires G3

stop_if:
- a child route needs direct state-module access

full_tree_paths:
- src/backend

tests_or_gates:
- manual: sample route smoke passed

closeout_rule:
- close only when parent facade and topology closeout agree
```
