# Productization Checklist

Use this checklist to judge whether a topology governance package is usable by another team without special oral history.

## 1. Can A New User Start In 10 Minutes?

Required:

- README explains the idea in plain language.
- North Star template exists.
- Full feature tree template exists.
- AI start prompt exists.
- bootstrap script exists.
- check script exists.
- sample walkthrough exists.
- templates can be copied without project-specific names.

## 2. Can The Package Avoid Over-Governance?

Required:

- work modes separate refactor, advance, aspect polish, and document debt
- North Star replaces milestone planning as the default orientation
- light work has upgrade triggers
- cold docs can be downgraded
- large trees are protected from size-only splitting

## 3. Can The Package Catch Drift?

Required:

- task card requires parent node
- task card requires affected child nodes
- task card requires changed edges
- task card requires governance heat and required depth
- cursor requires North Star alignment and growth vector
- closeout requires full tree and module tree status
- closeout requires QPCursor/evidence/local invariant status
- closeout requires old path status
- check script verifies the governance scaffold
- strict mode rejects blank closeout result, blank full tree/module tree proof, and blank smoke/test proof
- cursor check rejects parent nodes not listed in the project topology
- QPCursor check rejects missing North Star, feature tree, heat, depth, local invariants, stop rules, and evidence
- direct sibling edge check scans task card, module node, project topology, cursor, aspect cutover, and closeout records
- release-transition exceptions default to `status: none` and require developer approval, explicit edge, performance evidence, review date or expiry, and rollback before approval
- schema files are valid JSON and their required fields stay aligned with templates

## 4. Can It Connect To Existing Packages?

Required:

- explains when to use heavy governance
- explains when to use modular refactor
- does not duplicate either package

## 5. Product Maturity Levels

| Level | Meaning |
| --- | --- |
| L1 Method | clear concept and rules |
| L2 Package | README, SKILL, references, templates |
| L3 Product-Like | bootstrap, check, inventory, prompt, walkthrough |
| L4 Operational | project-specific gates, CI integration, real case evidence, non-empty ledger, cursor/topology cross-check, and direct-edge exception checks |

This package targets L3 by default and ships L4 hardening checks. A specific project reaches L4 only after its own tests, gates, module tree, full tree, non-empty ledger, and closeout process are wired in.
