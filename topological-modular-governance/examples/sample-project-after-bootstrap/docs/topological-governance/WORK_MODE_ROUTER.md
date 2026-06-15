# Work Mode Router

| Mode | Use When | Required Proof |
| --- | --- | --- |
| `refactor` | Existing behavior should stay equivalent while structure changes | equivalence baseline, parent facade, tests |
| `advance` | New capability, API, route, schema, UI surface, event, or module is added | new port, acceptance, failure behavior, docs |
| `aspect_polish` | A horizontal slice is isolated, forked, optimized, and cut over | affected ports, mirror topology, independent run, cutover proof |
| `doc_debt_cleanup` | Stale paths, stale index, or old references are cleaned | path confirmation, replacement/archive, docs gate |
