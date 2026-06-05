# Modular Refactor Templates

## Parent Baseline Template

```markdown
# Parent Baseline

Parent: `<module.path>`
Mode: light | standard | heavy
Reason:

## White-Box Node

Input:
Output:
Owner:
Public methods:
State:
Side effects:
Parent facade:
Children:
Dependencies:
Excluded scope:

## Current Behavior

- API / commands / routes:
- Error messages:
- Ordering requirements:
- Persistence or external IO:
- Tests or smoke:

## Child Queue

| Child | Owns | Excludes | Mode | Gate |
| --- | --- | --- | --- | --- |
| `<child>` |  |  |  |  |

## Equivalence Gates

- 

## Next Cursor

Next step:
Next child:
```

## Single Leaf Baseline Template

```markdown
# Leaf Baseline

Leaf: `<module.path.child>`
Parent: `<module.path>`
Mode:

## Owns

- 

## Does Not Own

- 

## Public Surface

- 

## Inputs and Outputs

Input:
Output:

## State and Side Effects

State:
Side effects:

## Extraction Plan

1. 
2. 
3. 

## Equivalence Gates

- 

## Stop/Split Criteria

Stop if:
Split if:
```

## Same-Parent Parallel Wave Manifest

```markdown
# Same-Parent Parallel Wave

Parent: `<module.path>`
Wave id:
Coordinator:
Mode:

## Eligibility

- Same frozen parent: yes/no
- Independent white-box nodes: yes/no
- No sibling dependency: yes/no
- No shared mutable state: yes/no
- Parent facade lock required: yes/no

## Children

| Child | Owns | Write set | Shared helper owner | Gate | Risk |
| --- | --- | --- | --- | --- | --- |
| `<child.a>` |  |  | parent |  |  |
| `<child.b>` |  |  | parent |  |  |

## Parent Facade Lock

Only the coordinator may merge parent facade edits:

- parent file:
- re-export surface:
- call order:
- diagnostics/order constraints:

## Failure Rule

If one child fails, remove it from the wave. Continue only if the remaining children still have independent write sets and gates.

## Closeout Plan

1. Prepare child files.
2. Merge parent facade.
3. Run shared gate.
4. Close each child.
5. Update recursive cursor.
```

## Leaf Closeout Template

```markdown
# Leaf Closeout

Leaf:
Parent:
Mode:
Result: stop_split | continue_split | deferred

## What Changed

- 

## Behavior Preserved

- 

## Gates Run

- command:
- result:

## Split Decision

Public surface:
State ownership:
Side effects:
Dependency direction:
Change cadence:
Independent testability:
Size/cognitive load:
Shared helper pressure:
Release shortcut: not allowed unless explicitly declared

Decision:

## Next Cursor

Next parent:
Next child:
Next phase:
```

## Prompt: Read-Only Mapping

```text
Use the modular-refactor protocol.
This turn is read-only.
Map the repository by top modules, large files, public surfaces, state owners, side effects, and dependency directions.
Recommend the next parent boundary and explain which parts are light, standard, or heavy.
Do not edit files.
```

## Prompt: Standard Extraction

```text
Use the modular-refactor protocol.
Select the current parent boundary.
Freeze the leaf equivalence baseline, then extract only that leaf.
Preserve the parent facade and parent-child communication.
Run the smallest sufficient gate and produce a closeout with split decision.
```

## Prompt: Same-Parent Parallel Wave

```text
Use the modular-refactor protocol.
Build a same-parent parallel wave manifest for the selected parent.
Only include child leaves with independent white-box nodes, declared write sets, no sibling dependency, and no shared mutable state.
Child files may be prepared in parallel, but parent facade merge must be serial through one coordinator.
Produce gates and failure rules before editing.
```

## Prompt: Heavy Module

```text
Use the modular-refactor protocol in heavy mode.
The module may involve state, locks, persistence, public API, protocol, external IO, auth, migration, or concurrency.
Do not batch unless independence is proven.
Create a detailed baseline and risk record before extraction.
Run broad enough gates to prove equivalence.
```

## Prompt: Rust Local Workspace

```text
Use the modular-refactor protocol and read references/rust-local-protocol.md.
Scan the Cargo workspace, crate facades, largest .rs files, mod/pub use tree, public exports, state owners, and IO boundaries.
Choose one crate or parent module boundary.
Preserve public exports through the parent facade.
Prefer DTO/error/pure helper/validation/mapping extraction before runtime state, IO, locks, async lifecycle, or public protocol changes.
Select light, standard, or heavy mode and name the exact cargo gates.
Produce the next recursive cursor.
```

## Rust Leaf Closeout Template

```markdown
# Rust Leaf Closeout

Leaf:
Parent:
Crate:
Mode:
Result: stop_split | continue_split | deferred

## Moved Rust Items

- structs/enums:
- traits:
- functions:
- impl blocks:
- constants:
- tests:

## Visibility

- preserved public exports:
- new `pub(super)`:
- new `pub(crate)`:
- widened visibility, if any:

## Parent Facade

- `mod` changes:
- `pub use` changes:
- parent-owned helpers:
- sibling dependency check:

## Behavior Proof

- cargo gate:
- targeted tests:
- API/schema/protocol proof:

## Split Decision

- public surface:
- state/IO:
- dependency direction:
- testability:
- size/cognitive load:
- decision:
```
