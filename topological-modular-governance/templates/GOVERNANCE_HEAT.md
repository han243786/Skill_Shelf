# Governance Heat

Governance heat chooses the minimum sufficient governance depth. It prevents heavy machinery from running all the time while still forcing high-risk work into stronger evidence.

```yaml
governance_heat:
required_depth:
heat_reason:
upgrade_triggers:
  -
```

## Heat Matrix

| Heat | Minimum Depth |
| --- | --- |
| G0-G1 | Light |
| G2-G3 | Standard |
| G4-G5 | Precision |

| Heat | Name | Typical Work | Minimum Governance |
| --- | --- | --- | --- |
| G0 | Leaf low heat | one file, no interface, no state, no persistence, no security, no runtime semantic change | QPCursor summary, topology path, local check |
| G1 | Module low-medium heat | private helper split, private method move, module-internal cleanup | module node check, public/private declaration, local regression |
| G2 | Module boundary heat | public method, parent-child relation, new file, module rename, module edge change | QPCursor, interface freeze, local invariants, affected-module regression |
| G3 | Capability heat | user-visible entry, new capability, capability status, supported/deferred/unsupported meaning | capability/source-of-truth registration, support matrix, regression protection |
| G4 | Architecture heat | runtime semantics, state machine, persistence schema, security boundary, trading or money path | Precision QPCursor, staged plan, compatibility bridge, architecture regression |
| G5 | Release or unknown risk heat | release closeout, multi-agent handoff, unexplained regression, repeated architecture error | full closeout, evidence audit, release checks, handoff proof |

## Upgrade Rules

Heat can only move upward during a task unless evidence proves a lower heat is correct before implementation.

At least G2 is required when the task:

- adds, moves, or renames files
- changes public surface
- changes module parent-child relation
- changes module communication edge
- crosses more than one parent module

At least G3 is required when the task changes a user-visible entry, capability source, capability display state, route, schema, event, command, or UI surface.

At least G4 is required when the task changes runtime semantics, state machine behavior, persistence schema, credentials, auth, security, external IO, or money/trading paths.

G5 is required when a handoff fails, a regression is hard to locate, module tree edges are unregistered, full tree checks fail, or a release closeout is in scope.
