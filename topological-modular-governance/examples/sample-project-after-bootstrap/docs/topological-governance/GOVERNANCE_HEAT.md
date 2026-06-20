# Governance Heat

```yaml
governance_heat: G2
required_depth: Standard
heat_reason: sample route facade work declares a parent-child module edge
upgrade_triggers:
  - public route, schema, event, or capability change would require at least G3
```

| Heat | Name | Minimum Governance |
| --- | --- | --- |
| G0 | Leaf low heat | Light |
| G1 | Module low-medium heat | Light |
| G2 | Module boundary heat | Standard |
| G3 | Capability heat | Standard |
| G4 | Architecture heat | Precision |
| G5 | Release or unknown risk heat | Precision |

## Upgrade Rules

Do not lower heat because this is a sample. Replace sample evidence with project-specific evidence before production use.
