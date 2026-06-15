# Work Mode Router

Every non-trivial task must choose one mode before implementation.

## 1. Mode Table

| Mode | Use When | Required Proof |
| --- | --- | --- |
| `refactor` | Existing behavior should stay equivalent while structure changes | equivalence baseline, parent facade, tests |
| `advance` | New capability, API, route, schema, UI surface, event, or module is added | new port, acceptance, failure behavior, docs |
| `aspect_polish` | A horizontal slice is isolated, forked, optimized, and cut over | affected ports, mirror topology, independent run, cutover proof |
| `doc_debt_cleanup` | Stale paths, stale index, or old references are cleaned | path confirmation, replacement/archive, docs gate |

## 2. Task Entry Card

```text
work_mode:
reason:
allowed_scope:
topology_slice:
exit_gate:
```

## 3. Upgrade Triggers

Lightweight work must upgrade when it touches:

- public API, route, schema, event, command, capability, or UI surface
- state, locks, persistence, transaction, permission, auth, or security boundary
- module parent-child relation or public owner
- old code, old contract, old test, old current-state document, or old path deletion
- more than one parent module
- test semantics rather than only test coverage or wording
- work that cannot be rolled back in one clear sentence

## 4. Local Mode Jump

If a task temporarily needs another mode:

```text
jump_from:
jump_to:
reason:
return_condition:
allowed_scope:
```
