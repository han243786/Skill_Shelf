# Productization Checklist

Use this checklist to judge whether a topology governance package is usable by another team without special oral history.

## 1. Can A New User Start In 10 Minutes?

Required:

- README explains the idea in plain language.
- AI start prompt exists.
- bootstrap script exists.
- check script exists.
- sample walkthrough exists.
- templates can be copied without project-specific names.

## 2. Can The Package Avoid Over-Governance?

Required:

- work modes separate refactor, advance, aspect polish, and document debt
- light work has upgrade triggers
- cold docs can be downgraded
- large trees are protected from size-only splitting

## 3. Can The Package Catch Drift?

Required:

- task card requires parent node
- task card requires affected child nodes
- task card requires changed edges
- closeout requires full tree and module tree status
- closeout requires old path status
- check script verifies the governance scaffold

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
| L4 Operational | project-specific gates, CI integration, real case evidence |

This package targets L3 by default. A specific project reaches L4 only after its own tests, gates, module tree, full tree, and closeout process are wired in.
