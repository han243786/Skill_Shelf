---
name: modular-refactor
description: Plan, execute, audit, or harden behavior-preserving modular refactors for any codebase size or tech stack. Use when Codex needs module extraction, large-file decomposition, dependency untangling, parent-child boundary preservation, white-box module trees, equivalence baselines, same-parent child parallel waves, Rust workspace extraction, or AI-assisted refactor workflows where behavior must remain stable.
---

# Modular Refactor

Use this skill to refactor codebases into clean, parent-mediated modules without losing behavior. It scales from small helper extraction to heavy multi-module refactors by selecting the right execution mode.

## Use For

- Module extraction and file decomposition.
- Untangling dependencies without changing behavior.
- Building module trees, white-box nodes, equivalence baselines, and closeouts.
- Same-parent child parallel waves where independence is proven.
- Rust crate, Cargo workspace, facade, `mod`, `pub use`, visibility, and targeted cargo-gate refactors.
- Refactor planning, execution, audit, or rescue after a refactor drifted.

## Do Not Use For

- Project-wide governance systems, policy matrices, or release-process design; use a governance package.
- Feature expansion disguised as refactor.
- Public API breaking changes without an explicit migration decision.
- Release-transition performance shortcuts unless the user explicitly declares release-version performance optimization.
- Moving state, IO, locks, persistence, auth, protocol, migration, or concurrency logic as if it were a light helper.

## Load Order

1. Read `references/protocol.md` when the task involves actual refactor planning, execution, or audit.
2. Read `references/rust-local-protocol.md` when the target is a Rust crate, Cargo workspace, Rust backend, Rust runtime, compiler/lowering crate, or Rust module extraction.
3. Read `references/templates.md` when producing a module tree, baseline, wave manifest, closeout, or user-facing proposal.
4. Keep this `SKILL.md` as the quick execution contract.

## Non-Negotiable Rules

- Start with read-only mapping before edits unless the user gives a narrow direct change.
- Choose one parent boundary per cycle; do not mix unrelated parents.
- Declare parent module, child leaves, write sets, public methods, state ownership, side effects, and equivalence gates before extraction.
- Preserve parent-child communication through the parent facade or parent-owned helper surface.
- Do not introduce sibling-to-sibling links during development.
- Keep shared helpers parent-owned until stable ownership is proven.
- Preserve public surface unless a separate migration is approved.
- Run a behavior-preservation gate after extraction.
- If hallucination risk is high, reduce scope and add a smaller baseline before editing.

## Default Workflow

1. Map top modules, largest files, dependency directions, public surfaces, state owners, side effects, and tests.
2. Choose one parent boundary.
3. Build a white-box node for the parent: input, output, owner, public methods, children, dependencies, state, side effects, tests, and exclusions.
4. Select child leaves using the split rules in `references/protocol.md`.
5. Pick execution mode: `light`, `standard`, or `heavy`.
6. Freeze an equivalence baseline before moving code.
7. Extract leaf code into child modules while the parent facade preserves the old public surface.
8. Run gates and compare behavior.
9. Close the leaf or decide whether it deserves deeper recursive splitting.
10. Close the parent only after meaningful residual children are closed, explicitly deferred, or out of scope.

## Speed Modes

| Mode | Use When | Required Proof |
| --- | --- | --- |
| light | pure helpers, constants, DTOs, compact validation, no state | compile/lint or targeted test |
| standard | normal business logic, routes, projections, adapters | targeted test plus relevant smoke/check |
| heavy | state, locks, DB, external IO, public API, protocol, migrations, auth, concurrency | broad tests, smoke, compatibility proof, risk record |

## Same-Parent Parallel Waves

Allow same-parent child parallel waves only when:

- all children share one frozen parent queue,
- every child has an independent white-box node,
- write sets are declared,
- there is no shared mutable state,
- there is no sibling dependency,
- parent facade edits are merged by one coordinator,
- each child has a child-specific gate.

If a child fails or shows hidden coupling, remove that child from the wave and continue only if the remaining children still satisfy independence.

## Required Outputs

For a planning turn, produce:

- parent boundary
- child queue
- execution mode
- equivalence gates
- wave eligibility
- exclusions
- first concrete next step

For an execution turn, produce:

- files changed
- public surface preserved or migration noted
- state and side-effect impact
- gates run
- behavior-preservation result
- closeout result
- next recursive cursor

## Validation

When modifying this package or using it on a codebase:

- Run the smallest sufficient gate after each leaf extraction.
- Run broader gates at parent closeout.
- For Rust, use the cargo gate ladder in `references/rust-local-protocol.md`.
- If working inside `D:\Skill_Shelf`, run `powershell -NoProfile -ExecutionPolicy Bypass -File D:\Skill_Shelf\SKILL_SHELF_STANDARD.ps1 -Strict`.
