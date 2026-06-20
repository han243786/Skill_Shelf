# Project Topology

This document is the project-level topology map. It explains how the project is organized as a module network.

## 1. Topology Summary

```text
global_root:
main_parents:
- 
active_work_modes:
- refactor
- advance
- aspect_polish
- doc_debt_cleanup
qpcursor_required: true
north_star: docs/topological-governance/NORTH_STAR.md
full_feature_tree: docs/topological-governance/FULL_FEATURE_TREE.md
module_topology_tree: docs/topological-governance/PROJECT_TOPOLOGY.md
default_cursor: docs/topological-governance/CURRENT_CURSOR.yaml
heat_matrix: docs/topological-governance/GOVERNANCE_HEAT.md
local_invariants: docs/topological-governance/LOCAL_INVARIANTS.md
```

## 2. Top-Level Nodes

| Node | Purpose | Owner | Main Paths | Status |
| --- | --- | --- | --- | --- |
|  |  |  |  |  |

## 3. Parent-Child Communication Rules

Development-time rule:

```text
Child modules must communicate through parent facade, registered contract, adapter, event, registry, or public interface.
Sibling-to-sibling direct links are not allowed unless the developer explicitly declares release-transition performance work.
```

## 4. Hot Assets

| Asset | Purpose | Path |
| --- | --- | --- |
| North Star | Final-state premise and convergence direction | docs/topological-governance/NORTH_STAR.md |
| Full feature tree | Feature-facing full tree and growth facts | docs/topological-governance/FULL_FEATURE_TREE.md |
| Module topology tree | Logical white-box module network | docs/topological-governance/PROJECT_TOPOLOGY.md |
| QPCursor | Current handoff coordinate | docs/topological-governance/CURRENT_CURSOR.yaml |
| Governance heat | G0-G5 heat matrix | docs/topological-governance/GOVERNANCE_HEAT.md |
| Local invariants | Module-level anti-regression guardrails | docs/topological-governance/LOCAL_INVARIANTS.md |
| Work mode router | Task entry routing |  |
| Closeout ledger | Topology consistency proof |  |

## 5. Known Cold Docs

Cold docs are historical or background references. They should not become default task entry points.

| Doc | Why Cold | Replacement Entry |
| --- | --- | --- |
|  |  |  |

## 6. Known Old Path Debt

| Path | Current Status | Cleanup Plan |
| --- | --- | --- |
|  |  |  |
