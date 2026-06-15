# Release Transition Exception

Use this only when a developer explicitly declares release-version performance transition.

```yaml
exception_id:
approved_by:
scope:
performance_evidence:
direct_edge_added:
why_parent_facade_insufficient:
rollback:
expiry:
review_date:
status: proposed
```

## Rules

1. AI must not propose entering release transition by itself.
2. A direct sibling edge requires explicit approval.
3. The exception must include performance evidence.
4. The exception must be reversible.
5. The exception must have an expiry or review date.
6. The direct edge must be registered as an exception, not normalized as the default development topology.
