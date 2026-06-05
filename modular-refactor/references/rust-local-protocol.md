# Rust Local Modular Refactor Protocol

This reference optimizes the general modular-refactor protocol for local Rust workspaces.

Use it when a Rust codebase has large files, many crates, public `pub use` surfaces, facade modules, stateful runtime logic, compiler/lowering logic, tests that are expensive, or a long recursive refactor queue.

## Rust-Specific Goal

Turn a Rust workspace into layered crates and modules where:

- crate public exports stay stable during extraction
- parent modules own `mod` and `pub use` facade decisions
- child modules do not import sibling internals
- pure DTOs and pure helpers move first
- state, locks, IO, runtime lifecycle, and protocol compatibility move last
- each extraction has a small enough cargo gate to run frequently

## Rust Boundary Model

Treat these as white-box boundaries:

| Rust Surface | Governance Meaning |
| --- | --- |
| workspace | global root |
| crate | top-level parent module |
| `src/lib.rs` or binary entry | crate facade |
| `mod parent; pub use parent::*;` | parent-mediated public surface |
| `parent.rs` plus `parent/child.rs` | recursive parent/child module |
| `pub`, `pub(crate)`, `pub(super)` | visibility contract |
| trait/interface | public behavior contract |
| tests and fixtures | equivalence baseline |

Prefer this shape during extraction:

```text
crate/src/lib.rs
  pub use parent::*;

crate/src/parent.rs
  mod child_a;
  mod child_b;
  pub use child_a::*;
  pub use child_b::*;
  parent-owned helpers

crate/src/parent/child_a.rs
crate/src/parent/child_b.rs
```

If a child needs a helper from a sibling, move that helper to the parent or keep it parent-owned. Do not import through the sibling.

## Local Rust Workspace Read-Only Scan

Before editing, collect:

```powershell
rg --files -g "Cargo.toml"
rg --files -g "*.rs" | Measure-Object
rg --files -g "*.rs" | ForEach-Object {
  [pscustomobject]@{
    Lines = (Get-Content -LiteralPath $_ | Measure-Object -Line).Lines
    File = $_
  }
} | Sort-Object Lines -Descending | Select-Object -First 30
rg -n "^pub mod |^mod |^pub use|^use " <crate>/src/lib.rs
```

Classify each crate:

- contract crate: DTOs, protocol types, schema, errors
- compiler/lowering crate: transforms one model into another
- runtime crate: state, IO, event lifecycle, execution, concurrency
- app/backend crate: routes, handlers, persistence, UI-facing API
- test/support crate or file: equivalence evidence, not primary product behavior

## Rust Execution Modes

### Light

Use for:

- DTO structs/enums
- constants
- pure parse/format helpers
- pure validation helpers with local tests
- registry arrays or tables with stable exports

Allowed compression:

- baseline and extraction plan may be one concise note
- gate can be `cargo check -p <crate>` or targeted test

### Standard

Use for:

- normal module extraction
- route handlers without persistent state changes
- projections and mappers
- compiler/lowering families
- validation families with multiple diagnostics

Required:

- stable public export plan
- before/after diagnostic behavior preserved
- targeted crate gate plus relevant test

### Heavy

Use for:

- `Arc`, `Mutex`, `RwLock`, atomics, channels
- database writes or migrations
- filesystem persistence
- network or websocket logic
- process lifecycle
- async tasks and cancellation
- public API/schema/protocol surfaces
- error ordering relied on by tests or clients
- state machines and trading/runtime execution

Required:

- explicit state owner
- side-effect map
- broad gate
- no same-parent parallel wave unless independence is proven

## Rust Extraction Order

For a large Rust parent, use this default order:

1. Types and constants
2. Error types and diagnostics containers
3. Pure helper functions
4. Validation families
5. Mapping/lowering families
6. Facade route/command wrappers
7. Stateful services
8. Persistence and IO
9. Runtime lifecycle and concurrency
10. Tests and fixtures cleanup

This order is faster because early leaves have low coupling and create clean parent-owned surfaces for later heavy leaves.

## Facade Rules

### Keep Public Surface Stable

If callers currently use:

```rust
use crate_name::*;
use crate_name::SomeType;
```

then extraction should preserve it through `pub use` until a separate public API migration is approved.

### Prefer Narrow Child Visibility

Use:

- `pub(super)` for child functions called only by the parent
- `pub(crate)` for crate-internal cross-parent use that cannot yet be eliminated
- `pub` only for stable external surface

Avoid widening visibility just to make extraction compile. If widening is necessary, document it as a temporary compatibility bridge.

### Parent-Owned Helper Rule

Keep shared helpers in the parent when:

- multiple children need them
- ownership is not yet obvious
- moving them would create a sibling dependency
- the helper participates in diagnostics ordering

Split a helper child only after at least two children are closed and the helper has a stable independent white-box boundary.

## Same-Parent Parallel Waves for Rust

Rust same-parent waves are valuable but must respect facade locking.

Good candidates:

- several DTO families under one parent
- several validation functions with independent input sections
- several enum/table registries
- route handlers that only call parent-provided app state
- compiler lowering helpers for independent syntax forms

Bad candidates:

- several children all editing the same `impl` block heavily
- children that must change one shared enum at the same time
- runtime state modules sharing locks
- modules where tests rely on exact error ordering but the order is not documented
- children requiring new crate features or dependency changes

Wave rule:

```text
child files can be prepared in parallel
parent facade/mod/pub use/call order must be merged serially
```

## Cargo Gate Ladder

Use the smallest sufficient gate early, then broaden at parent closeout.

### Local syntax and formatting

```powershell
cargo fmt --check
```

### Single crate check

```powershell
cargo check -p <crate-name>
```

### Single test or test module

```powershell
cargo test -p <crate-name> <test_name>
```

### Binary or app check

```powershell
cargo check --bin <binary-name>
```

### Workspace confidence gate

```powershell
cargo check --workspace
cargo test --workspace
```

Use workspace-wide gates when:

- changing public exports
- changing protocol crates
- changing compiler/runtime shared types
- closing a parent
- touching dependency declarations

## Large Rust File Strategy

For a file above 1500 lines, do not start by moving random functions. First create a parent segmentation:

```text
large_file.rs
  facade / public exports
  DTO and constants
  errors and diagnostics
  pure helpers
  validation
  mapping/lowering
  stateful services
  tests
```

For a file above 3000 lines:

1. create parent segmentation baseline
2. extract DTO/error/helper leaves first
3. keep tests local until behavior is protected
4. move tests only after the main parent facade is stable
5. run crate check after each low-risk wave
6. run broad gate at parent closeout

## Rust Compiler/Lowering Modules

Compiler and lowering crates often look pure but can hide compatibility risk.

Split by transformation responsibility:

- input validation
- identifier and uniqueness rules
- enum/code decoding
- expression parsing
- condition lowering
- strategy-to-core lowering
- runtime-config-to-core lowering
- custom expression validation
- data source validation

Preserve:

- error text
- error order
- default values
- hash inputs
- serialized output shape
- compatibility with runtime consumers

## Rust Runtime Modules

Runtime crates must be treated as heavy when they own:

- execution state
- event streams
- async tasks
- order/fill simulation
- websocket clients
- reconciliation
- risk checks
- hotswap
- sandbox replay
- runtime cache

Split runtime code in this order:

1. pure event/type projection
2. read-only query helpers
3. pure calculation
4. command validation
5. state mutation
6. async lifecycle
7. IO adapters

Never parallelize children that share the same lock or event channel without a written state owner and gate.

## Rust Test Strategy

Large old tests may be discarded later, but during extraction they are still useful as temporary equivalence sensors.

Use tests this way:

- keep existing tests until the extracted parent passes
- add tiny targeted tests only for risky moved behavior
- avoid broad new test suites for code that is scheduled for deletion
- after parent closeout, decide whether old tests are permanent evidence or temporary scaffolding

## Local QuantPilot-Style Priority Heuristic

For a workspace shaped like the current local Rust project snapshot from 2026-06-04:

- `src/backend` is already highly split; avoid spending most speed effort there unless a specific parent is open.
- `qrpc_runtime` and `quantscript` contain many 1000+ line files; use parent segmentation plus same-parent waves for pure families.
- `qrpc_core_ir/src/v4.rs` is a very large protocol/contract file; treat it as heavy at parent level, but split DTO/default/report families in controlled light or standard waves.
- `qrpc_compiler/src/lib.rs` is a good candidate for transformation-family extraction after protocol boundaries are stable.
- `src-executor/main.rs` should be treated as lifecycle/IO heavy, not a casual file split.
- huge test files should inform equivalence but should not dominate the product module tree.

Suggested local priority:

1. finish current contract crate parent before jumping to runtime
2. segment `qrpc_core_ir` before direct extraction
3. split `qrpc_compiler` by lowering/validation families
4. split `qrpc_runtime` by pure evaluator/calculation before stateful runtime services
5. only then handle executor lifecycle and IO

## Rust Closeout Checklist

For each Rust leaf closeout, record:

- parent module
- child module path
- moved items
- visibility changes
- preserved public exports
- parent-owned helpers
- sibling dependency check
- state and side effects
- cargo gates run
- whether further split is justified

Close a Rust parent only when:

- `mod` tree is clear
- `pub use` facade is stable
- child modules do not import sibling internals
- state owners are explicit
- old large file residuals are either closed or deferred
- cargo gates prove the affected workspace layer
