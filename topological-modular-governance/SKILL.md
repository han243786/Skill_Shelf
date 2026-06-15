---
name: topological-modular-governance
description: Design, apply, audit, or explain topology-style modular governance for large codebases. Use when Codex needs to treat a project as an auditable module network with nodes, parent-child edges, full trees, module trees, work-mode routing, topology-aware closeout, and AI hallucination guardrails.
---

# Topological Modular Governance

Use this skill when a project needs to be governed as a module topology instead of a loose set of files. The core rule is: every meaningful change must identify the node it touches, the edge it changes, and the parent boundary that owns the connection.

## Use For

- Large or expanding projects that need module-network governance.
- Designing or auditing module trees, full trees, parent-child communication rules, public method ownership, and topology-aware closeout.
- Separating refactor mode, advance mode, aspect-polish mode, and document-debt cleanup.
- Preventing AI-assisted development from drifting across module boundaries.
- Explaining topological governance to developers or stakeholders in plain language.
- Combining governance packages with modular refactor execution.

## Do Not Use For

- Small one-off tasks where a simple README or checklist is enough.
- Pure code movement without governance design; use `modular-refactor`.
- Full heavy-governance bootstrapping without topology emphasis; use `heavy-scale-exploitation-governance-1`.
- Release-version performance shortcuts unless the user explicitly declares release transition.
- Justifying extra ceremony for tiny changes that do not affect nodes, edges, contracts, state, persistence, or public surfaces.

## Load Order

1. Read `references/00-operating-model.md` for the core concept and invariants.
2. Read `references/01-topology-map.md` when creating or auditing module/full trees.
3. Read `references/02-work-mode-router.md` when deciding whether the task is refactor, advance, aspect polish, or document debt cleanup.
4. Read `references/03-closeout-and-gates.md` when defining gates, closeout, or AI hallucination checks.
5. Read `references/04-adoption-guide.md` when introducing the model into an existing project.
6. Read `references/05-sample-walkthrough.md` when a user wants to see how to start from zero.
7. Read `references/06-productization-checklist.md` when improving this package or judging whether it is product-like enough.
8. Read `references/07-paper-topological-modular-governance.md` when the user wants a rigorous paper, methodology defense, governance proposal, or stakeholder explanation.
9. Use `templates/` when producing user-facing cards or module-node records.

## Non-Negotiable Rules

- Start by naming the work mode before continuing a long-running task.
- Treat modules as white-box nodes, not just folders.
- Treat parent-child communication paths as governed edges.
- Do not allow sibling-to-sibling links during development unless a developer explicitly declares release-transition performance work and `RELEASE_TRANSITION_EXCEPTION.md` is approved with `developer_approved: true`, a real approver, an explicit `A -> B` edge, performance evidence, review date or expiry, and rollback.
- Record public method ownership when public methods matter to the change.
- Keep full tree and module tree separate: physical file map versus logical white-box network.
- Do not split large tree files just because they are large; split only when定位速度, gate stability, or reverse lookup reliability is measurably hurt.
- Closeout must prove topology consistency, not just test success.
- `status: closed` requires closeout evidence and a matching ledger row; blank closeout results are not acceptable strict-mode evidence.

## Default Workflow

1. If adopting into a project, run or suggest `scripts/inventory-topology.ps1` first.
2. Bootstrap the target project with `scripts/bootstrap-topological-governance.ps1` when the user wants files installed.
3. Check the scaffold with `scripts/check-topological-governance.ps1`; use `-Strict` after real fields are filled.
4. Classify the task mode: `refactor`, `advance`, `aspect_polish`, or `doc_debt_cleanup`.
5. Identify the affected parent module, child nodes, public methods, state owners, external ports, tests, and docs.
6. Draw or update the topology slice: nodes, edges, allowed communications, forbidden lateral links, and old/new paths.
7. Choose the minimum sufficient execution depth: light, standard, or heavy.
8. Execute or propose changes only inside the declared topology slice.
9. If another mode is needed, explicitly jump to that mode and record the return condition.
10. Close out by proving code, module tree, full tree, contracts, tests, docs, and legacy paths agree.

## Work Mode Summary

| Mode | Use When | Topology Effect |
| --- | --- | --- |
| refactor | Behavior should stay equivalent | rearrange existing nodes and edges |
| advance | New capability or port is added | create or extend nodes and ports |
| aspect_polish | A horizontal slice is improved | fork a topology mirror, optimize, then cut over |
| doc_debt_cleanup | Old paths or stale references are cleaned | repair map accuracy without feature work |

## Required Outputs

For planning:

- work mode
- parent boundary
- affected nodes and edges
- public methods or ports
- old/new topology relation
- gates
- next step

For closeout:

- topology slice changed
- public surface result
- parent-child rule result
- full tree/module tree sync result
- tests or smoke result
- old path status
- residual risks

For adoption:

- inventory summary
- files installed or skipped
- scaffold check result
- strict check result when fields are filled
- cursor check result
- ledger check result
- first parent node to fill
- first task card to use

## Validation

When modifying this package inside `D:\Skill_Shelf`, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\Skill_Shelf\SKILL_SHELF_STANDARD.ps1 -Strict
```

When testing the product-like workflow, use a temporary project:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\Skill_Shelf\topological-modular-governance\scripts\bootstrap-topological-governance.ps1 -ProjectRoot <temp-project>
powershell -NoProfile -ExecutionPolicy Bypass -File <temp-project>\tools\check-topological-governance.ps1 -ProjectRoot <temp-project>
```

For L4-style checks after project fields are filled:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <project>\tools\check-topological-governance.ps1 -ProjectRoot <project> -Strict
powershell -NoProfile -ExecutionPolicy Bypass -File <project>\tools\check-topology-cursor.ps1 -ProjectRoot <project>
powershell -NoProfile -ExecutionPolicy Bypass -File <project>\tools\check-topology-ledger.ps1 -ProjectRoot <project>
powershell -NoProfile -ExecutionPolicy Bypass -File <project>\tools\check-forbidden-sibling-edges.ps1 -ProjectRoot <project>
```

Use `check-topology-ledger.ps1 -AllowEmpty` only immediately after bootstrapping an empty project. Do not use it as an operational CI gate.
