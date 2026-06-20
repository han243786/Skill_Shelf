# Project Topology

## 1. Topology Summary

```text
global_root: sample
main_parents:
- sample.backend
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
| sample.backend | Backend parent module for sample routes and state | platform-team | src/backend | active |

## 3. Parent-Child Communication Rules

Development-time rule:

```text
Child modules must communicate through parent facade, registered contract, adapter, event, registry, or public interface.
```

## 4. Hot Assets

| Asset | Purpose | Path |
| --- | --- | --- |
| North Star | Final-state premise | docs/topological-governance/NORTH_STAR.md |
| Full feature tree | Feature-facing growth facts | docs/topological-governance/FULL_FEATURE_TREE.md |
| Module topology tree | Logical white-box module network | docs/topological-governance/PROJECT_TOPOLOGY.md |
| QPCursor | Current handoff coordinate | docs/topological-governance/CURRENT_CURSOR.yaml |
| Governance heat | G0-G5 heat matrix | docs/topological-governance/GOVERNANCE_HEAT.md |
| Local invariants | sample.backend module invariants | docs/topological-governance/LOCAL_INVARIANTS.md |

## 5. Known Cold Docs

| Doc | Why Cold | Replacement Entry |
| --- | --- | --- |
| none | none | none |

## 6. Known Old Path Debt

| Path | Current Status | Cleanup Plan |
| --- | --- | --- |
| none | none | none |
