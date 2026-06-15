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
| Full tree | Physical file map |  |
| Module tree | Logical white-box module network |  |
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
