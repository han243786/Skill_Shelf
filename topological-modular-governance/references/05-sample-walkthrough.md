# Sample Walkthrough

This walkthrough shows how a team can use topology-style modular governance on a project that is already large and messy.

## Situation

The project has:

- frontend app
- backend API
- runtime executor
- compiler or parser package
- docs and tests
- several large files
- old paths still mentioned in documents

The team wants to keep moving quickly without letting AI-assisted changes drift across module boundaries.

## Step 1. Run A Read-Only Inventory

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\Skill_Shelf\topological-modular-governance\scripts\inventory-topology.ps1 -ProjectRoot D:\your-project
```

Expected output:

- top-level directories
- source file counts
- largest source files
- candidate entrypoints
- existing governance files

This step does not decide the architecture. It only makes reality visible.

## Step 2. Bootstrap The Topology Governance Files

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\Skill_Shelf\topological-modular-governance\scripts\bootstrap-topological-governance.ps1 -ProjectRoot D:\your-project
```

This writes:

```text
docs\topological-governance\PROJECT_TOPOLOGY.md
docs\topological-governance\WORK_MODE_ROUTER.md
docs\topological-governance\TOPOLOGY_TASK_CARD.md
docs\topological-governance\TOPOLOGY_MODULE_NODE.md
docs\topological-governance\TOPOLOGY_CLOSEOUT.md
docs\topological-governance\QPCURSOR.md
docs\topological-governance\NORTH_STAR.md
docs\topological-governance\FULL_FEATURE_TREE.md
docs\topological-governance\GOVERNANCE_HEAT.md
docs\topological-governance\LOCAL_INVARIANTS.md
docs\topological-governance\AI_START_PROMPT.md
tools\check-topological-governance.ps1
tools\check-qpcursor-governance.ps1
tools\inventory-topology.ps1
```

Existing files are not overwritten unless `-Force` is used.

## Step 3. Fill The First Topology Slice

Choose one parent boundary, for example:

```text
parent_node: backend.runtime
affected_child_nodes:
- backend.runtime.routes
- backend.runtime.state
- backend.runtime.events
```

Then fill:

- inputs
- outputs
- public methods or ports
- state owners
- side effects
- allowed edges
- forbidden edges
- tests or smoke

Do not try to map the whole project perfectly on day one.

## Step 4. Route The First Task

Example:

```text
work_mode: refactor
reason: move route handlers behind a parent facade without changing public API
allowed_scope: backend runtime route files, route tests, module tree entries
governance_heat: G2
required_depth: Standard
heat_reason: parent-child route edge is being changed
topology_slice: backend.runtime -> backend.runtime.routes
local_invariants: docs/topological-governance/LOCAL_INVARIANTS.md
exit_gate: route tests pass, parent facade preserved, topology closeout written
```

This is better than saying:

```text
continue refactor
```

because the next agent knows exactly what topology slice is active.

Then update `CURRENT_CURSOR.yaml` with the same parent node, heat, required depth, allowed workset, stop rules, and evidence requirements.

## Step 5. Close Out

Example closeout:

```text
topology_closeout:
  mode: refactor
  parent: backend.runtime
  cursor_id: CURSOR-0001
  governance_heat: G2
  required_depth: Standard
  nodes_changed: backend.runtime.routes
  edges_changed: child route handlers now enter through parent facade
  public_surface: unchanged
  local_invariants: loaded and satisfied
  interface_freeze: public API unchanged
  full_tree: updated
  module_tree: updated
  tests_or_smoke: route tests pass
  evidence: check-topological-governance, check-topology-cursor, check-qpcursor-governance
  old_paths: none introduced
  result: closed
  next: choose backend.runtime.state
```

## What Good Looks Like

After a few cycles:

- developers stop asking where random code lives
- AI stops guessing module ownership
- refactors stop accidentally becoming feature work
- feature work stops hiding structural changes
- old path debt is visible instead of silently growing
- closeout proves structure, not only test success
