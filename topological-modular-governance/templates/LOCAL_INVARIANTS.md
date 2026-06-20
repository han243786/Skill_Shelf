# Local Invariants

Local invariants are local anti-regression guardrails derived from the North Star, full feature tree, and module topology tree. They bind protection to a real node, edge, facet, or gate without becoming a replacement for the North Star.

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

## Rules

1. Load local invariants before editing a module.
2. Bind every invariant to a module, edge, facet, public surface, or gate.
3. Use `north_star_refs` to point at final-state or convergence clauses; do not create broad process policy here.
4. Put scope-expansion triggers in `stop_if`.
5. If a rule cannot be bound to a module or gate, mark it as weak policy and rewrite it later.

## Minimum Useful Invariants

- Which user function facet owns this module.
- Which full tree and module tree nodes represent it.
- Which public surface is frozen.
- Which edges are allowed and forbidden.
- Which changes force G2, G3, G4, or G5.
- Which gates prove closeout.
