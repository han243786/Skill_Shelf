# Local Invariants

Local invariants project the North Star, full feature tree, and module topology tree into one module, edge, facet, or gate. They are local anti-regression guardrails, not a replacement for the North Star.

## 1. Binding Targets

Bind local invariants to at least one of:

- module tree node
- parent-child edge
- user function facet
- public surface
- capability or support state
- runtime state machine
- gate script

## 2. Required Shape

```yaml
module:
scope:
  user_function_facet:
  full_feature_tree:
  module_tree:
  leaf:
public_surface:
  -
allowed_edges:
  -
forbidden_edges:
  -
local_invariants:
  -
north_star_refs:
  -
heat_escalation:
  -
stop_if:
  -
gates:
  -
```

## 3. What Belongs Here

Good local invariants:

- "This module must not bypass the parent facade."
- "This public route is frozen unless governance heat is at least G3."
- "This state owner cannot be changed without G4."
- "This UI surface must use backend capability as source of truth."

Weak local invariants:

- "Keep code clean."
- "Do not break things."
- "Follow best practices."

If a rule cannot name a North Star clause, module, edge, public surface, heat trigger, or gate, rewrite it.

## 4. Cursor Relationship

`CURRENT_CURSOR.yaml` must point to the local invariants source for the active module. If the cursor enters a different parent module, update the local invariants binding before editing.

## 5. Closeout Relationship

Closeout must say whether local invariants were loaded, whether any invariant changed, and which gate or manual check proves compliance.
