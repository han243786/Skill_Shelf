# Modular Refactor Protocol

## Purpose

This protocol turns modular refactors into a repeatable governance loop. It is language-agnostic and works for Rust, TypeScript, Python, Java, Go, C#, C++, frontend apps, backend services, monorepos, protocol crates, data pipelines, and mixed stacks.

The goal is not just to split files. The goal is to make the project globally modular, easy to extend, easy to verify, and resistant to uncontrolled regression.

## Core Model

Use three matrices:

1. Process Matrix: how work moves from proposal to baseline, extraction, verification, closeout, and recursion.
2. Specification Matrix: hard engineering rules, including parent-child communication, public method ownership, state ownership, API compatibility, and release-transition restrictions.
3. Guidance Matrix: full tree, module tree, white-box nodes, current cursor, residual queues, and milestone records.

Every module is a white-box node:

```text
module
  input
  output
  owner
  public methods
  child modules
  parent facade
  dependencies
  state
  side effects
  tests or gates
  excluded scope
```

## Parent-Child Rule

Development mode uses parent-mediated communication.

Allowed:

```text
parent -> child
child -> parent-owned helper
external caller -> parent facade -> child
```

Forbidden during development:

```text
child A -> child B
child A -> child B internal helper
child A mutates child B state
```

The only exception is release transition. A release-transition shortcut may be proposed only after the developer explicitly says the project is entering release-version performance optimization. The AI must not proactively suggest release transition.

## Recursive Loop

Use this loop for every parent:

1. Parent baseline plan
2. Parent residual judgment
3. Child baseline plan
4. Child extraction
5. Child single-leaf closeout
6. Child split decision
7. Recurse into child if needed
8. Return to parent residual judgment
9. Parent closeout

Never close a parent just because the easy children are done. Close it only when meaningful residuals are closed, deferred with owner and reason, or explicitly out of scope.

## Extract, Organize, Refactor

Use three phases:

1. Extract: move behavior into modules with minimum semantic change.
2. Organize: clean boundaries, names, public surfaces, helper ownership, and module tree.
3. Refactor: improve internals after equivalence is protected.

Do not merge these phases for heavy modules. For light modules they may be compressed if gates are clear.

## Split Decision Rules

Trigger these rules at every single-leaf closeout and parent residual judgment.

### 1. Public Surface Rule

Split if one leaf owns multiple unrelated public APIs, commands, routes, DTO families, schema sections, or exported methods.

Stop splitting if the public surface is compact and serves one coherent use case.

### 2. State Ownership Rule

Split or heavy-guard if different parts own different mutable state, locks, caches, database writes, file writes, network sessions, timers, background tasks, or process lifecycle.

Stop splitting if the leaf is stateless or has one clear state owner.

### 3. Side Effect Rule

Split when read-only logic, mutation logic, persistence, external IO, and event emission are mixed.

Keep together only when the side effects form one atomic workflow and separating them would hide the transaction boundary.

### 4. Dependency Direction Rule

Split when a child wants to depend on a sibling. Move the shared dependency upward into a parent-owned helper or open a new parent-level child.

Stop splitting if all dependencies flow through the parent and there is no sibling pressure.

### 5. Change-Cadence Rule

Split if subparts are likely to change for different reasons, by different developers, or on different release schedules.

Stop splitting if changes naturally happen together.

### 6. Equivalence-Test Rule

Split if a subpart can be tested or smoke-checked independently.

Do not split if no meaningful independent baseline can be created without inventing fragile mocks.

### 7. Size and Cognitive Load Rule

Size alone is not enough, but it is a signal.

Suggested thresholds:

- under 150 lines: usually light, likely stop unless it hides state or public APIs
- 150 to 500 lines: standard judgment
- 500 to 1500 lines: likely split by semantic families
- above 1500 lines: define a parent plan before editing
- above 3000 lines: start with parent segmentation, not direct leaf extraction

### 8. Shared Helper Rule

Do not create a child named `shared` too early. Keep shared helpers parent-owned until child ownership becomes obvious.

Open a helper child only when:

- at least two closed children use it through the parent
- the helper has stable input/output
- it does not create sibling-to-sibling coupling

### 9. Release Shortcut Rule

Do not create direct sibling links for performance during development. If the developer explicitly declares release transition, propose the shortcut as a separate design with risk, measurement, and rollback plan.

## Execution Modes

| Mode | Use When | Required Proof | Speed Policy |
| --- | --- | --- | --- |
| Light | pure helpers, small DTOs, compact validation, no state | compile/lint or targeted test | may use compressed baseline and closeout |
| Standard | normal business logic, routes, projections, adapters | targeted test plus relevant smoke/check | full baseline, extraction, closeout |
| Heavy | state, locks, DB, external IO, public API, protocol, migrations, auth, concurrency | broad tests, smoke, API/schema compatibility, manual risk record | no batching unless independence is proven |

## Acceleration Protocols

### Smart Pre-Commit

Run the smallest gate that proves the touched boundary first. Run broader gates at parent closeout or high-risk points.

### Lightweight Two-Step

For light leaves, merge baseline and extraction planning into one short record, then close out after gates.

### Homogeneous Leaf Batching

Batch leaves that have the same shape and no hidden coupling, such as DTO enum families, route wrappers, simple validators, schema fragments, or generated-like adapters.

### Same-Parent Parallel Children

Use this for high speed without destroying structure.

Eligibility:

- all children belong to the same frozen parent
- every child has its own white-box node
- write sets are declared
- no shared mutable state
- no sibling direct dependency
- parent facade edit is coordinated by one owner
- each child has a child-specific gate

Workflow:

1. Freeze parent baseline.
2. Build a wave manifest.
3. Prepare child modules independently.
4. Merge parent facade once.
5. Run shared parent gate.
6. Close each child separately.
7. Remove failed children from the wave.

Disqualifiers:

- multiple children need conflicting edits to one parent block
- children share lock or transaction state
- child A must call child B
- public API ordering or diagnostics must be preserved but not yet mapped
- test evidence cannot isolate children

### Recursive Governance Generator

For long projects, maintain a machine-readable cursor:

```text
current_parent
current_step
current_phase
closed_children
open_residuals
next_recommended_child
allowed_speedups
last_verified_gate
last_checkpoint
```

This prevents a one-off user question from being mixed into the recursive loop.

## Baseline Requirements

Before extraction, capture:

- current public API
- key public methods
- input and output shapes
- important error messages
- ordering requirements
- state ownership
- side effects
- tests/smoke commands
- excluded scope

For UI work, include screenshots or interaction smoke when behavior is visible.

For services, include API contract, request/response shape, status codes, event names, and persistence effects.

For libraries, include exported types, functions, trait/interface boundaries, and compatibility expectations.

## Large File Strategy

For files above 1500 lines:

1. Do not start by moving random functions.
2. Segment the file into semantic regions.
3. Identify parent-owned helpers.
4. Extract DTOs and pure helpers first.
5. Extract validation and mapping families next.
6. Extract stateful flows last.
7. Preserve public facade until the parent closeout proves equivalence.

For files above 3000 lines, create a parent segmentation milestone before extraction.

## Quality Gates

Pick gates by risk:

- compile/typecheck
- formatter
- lint
- unit tests
- targeted integration tests
- API contract checks
- snapshot comparison
- smoke run
- browser smoke for frontend
- migration dry run
- concurrency or lifecycle smoke
- manual baseline record when tests are intentionally absent

Never rely only on "it compiles" for state, IO, API, auth, persistence, or protocol work.

## Hallucination Controls

Use these controls when AI may lose track:

- read before editing
- cite files and line areas in baseline
- use small parent scopes
- declare exclusions
- compare before/after public surface
- keep helper ownership explicit
- run gates immediately after extraction
- close out every leaf
- update cursor after each verified step

## Any-Tech-Stack Mapping

Rust:

- parent facade: `mod`, `pub use`, crate public exports
- child leaf: module file
- gates: `cargo fmt`, `cargo check`, targeted tests
- for detailed local Rust workspace execution, read `references/rust-local-protocol.md`

TypeScript/JavaScript:

- parent facade: barrel export, route index, service registry
- child leaf: module/component/service file
- gates: typecheck, lint, test, browser smoke

Python:

- parent facade: package `__init__`, service module, router
- child leaf: module or package
- gates: pytest, mypy/ruff if available, API smoke

Java/C#:

- parent facade: package/namespace service, interface, controller
- child leaf: class or package
- gates: compile, unit/integration tests, contract tests

Go:

- parent facade: package boundary
- child leaf: file or package
- gates: `go test`, `go vet`, API smoke

Frontend:

- parent facade: feature shell, route, store boundary
- child leaf: component, hook, model, adapter
- gates: build, unit tests, interaction smoke, screenshot check

## Decision Priority

When speed and quality conflict, choose in this order:

1. behavior preservation
2. public API compatibility
3. parent-child structure
4. clear state ownership
5. testability
6. speed
7. cosmetic cleanup
