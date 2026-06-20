# North Star, QPCursor, And Governance Heat

This package treats development as directional growth toward a North Star. The core document matrix is:

```text
NORTH_STAR.md
  -> final-state premise and convergence direction

FULL_FEATURE_TREE.md
  -> feature-facing full tree and protected behavior facts

PROJECT_TOPOLOGY.md
  -> module topology tree and parent-child communication facts
```

Milestones are not the default planning unit. Process policy is not the default source of direction. Fine-grained operating rituals are not the default substitute for evidence.

## 1. Default Execution Stack

Every governed task should flow through:

```text
User intent
  -> North Star
  -> Full feature tree
  -> Module topology tree
  -> QPCursor
  -> Governance heat
  -> Local anti-regression guardrails
  -> Allowed workset
  -> Action
  -> Evidence
  -> Cursor update
```

## 2. Directional Growth

Directional growth means:

1. The project has a final-state premise, even if the details are still becoming clearer.
2. Each task states how it moves the system toward that final state.
3. The target may become more precise as evidence accumulates.
4. Clarity gains are recorded without converting them into milestone debt.
5. Deferred work is tracked as a gap only when it blocks convergence or risks regression.

This avoids the old pattern where unfinished milestone items silently become technical debt.

## 3. QPCursor Minimum

QPCursor must identify:

- current mode and step
- repo baseline and growth position
- North Star source and alignment
- growth vector: current position, next growth, convergence signal
- user function facet, feature tree location, topology tree location, and leaf
- topology slice and parent node
- governance heat and required depth
- local anti-regression guardrails
- interface freeze
- editable and read-only workset
- next action, done condition, stop conditions, and evidence

## 4. Heat To Depth Mapping

| Heat | Minimum Depth |
| --- | --- |
| G0-G1 | Light |
| G2-G3 | Standard |
| G4-G5 | Precision |

Depth can be stronger than the minimum, but not weaker.

## 5. When To Stop

Stop and update the cursor before continuing when:

1. The task cannot explain its North Star alignment.
2. The task needs files outside `allowed_workset`.
3. Public API, route, schema, event, capability, UI surface, persistence schema, state, lock, auth, security, runtime semantics, money, or trading paths are affected without the correct heat.
4. Local anti-regression guardrails are missing for the active module.
5. Evidence cannot be tied to a real command, file, test, smoke, manual check, or risk.
6. Feature tree and topology tree disagree.

## 6. Operational Checks

Use:

```powershell
tools\check-qpcursor-governance.ps1 -ProjectRoot .
tools\check-topology-cursor.ps1 -ProjectRoot .
```

The first checks North Star, feature tree, heat, local guardrails, depth, and evidence. The second checks that the current cursor still points to a real topology parent.
