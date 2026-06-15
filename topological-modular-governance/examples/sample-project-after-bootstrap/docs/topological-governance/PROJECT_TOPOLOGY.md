# Project Topology

## 1. Topology Summary

```text
global_root: sample
main_parents:
- sample.backend
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
| Module tree | Logical white-box module network | docs/topological-governance/PROJECT_TOPOLOGY.md |

## 5. Known Cold Docs

| Doc | Why Cold | Replacement Entry |
| --- | --- | --- |
| none | none | none |

## 6. Known Old Path Debt

| Path | Current Status | Cleanup Plan |
| --- | --- | --- |
| none | none | none |
