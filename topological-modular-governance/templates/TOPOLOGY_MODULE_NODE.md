# Topology Module Node

```text
node:
parent:
status:
purpose:

inputs:
- 

outputs:
- 

public_surface:
- 

state_owner:
- 

side_effects:
- 

children:
- 

allowed_edges:
- 

forbidden_edges:
- 

full_tree_paths:
- 

tests_or_gates:
- 

closeout_rule:
- 
```

## Notes

- Keep the node white-box enough for another developer to continue.
- Do not list a child that does not exist in code or planned work.
- Public surface means functions, APIs, events, schemas, commands, routes, or UI surfaces that other modules depend on.
- Forbidden edges are as important as allowed edges.
