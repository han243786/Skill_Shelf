[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [string]$GovernanceRoot = "docs\topological-governance",

    [switch]$Force,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$resolvedProject = Resolve-Path -LiteralPath $ProjectRoot
$projectPath = $resolvedProject.ProviderPath
$packageRoot = Split-Path -Parent $PSScriptRoot
$templateRoot = Join-Path $packageRoot "templates"
$schemaRoot = Join-Path $packageRoot "schemas"

$templateMappings = @(
    @{ Source = "PROJECT_TOPOLOGY.md"; Dest = "$GovernanceRoot\PROJECT_TOPOLOGY.md" },
    @{ Source = "WORK_MODE_ROUTER.md"; Dest = "$GovernanceRoot\WORK_MODE_ROUTER.md" },
    @{ Source = "TOPOLOGY_TASK_CARD.md"; Dest = "$GovernanceRoot\TOPOLOGY_TASK_CARD.md" },
    @{ Source = "TOPOLOGY_MODULE_NODE.md"; Dest = "$GovernanceRoot\TOPOLOGY_MODULE_NODE.md" },
    @{ Source = "TOPOLOGY_CLOSEOUT.md"; Dest = "$GovernanceRoot\TOPOLOGY_CLOSEOUT.md" },
    @{ Source = "QPCURSOR.md"; Dest = "$GovernanceRoot\QPCURSOR.md" },
    @{ Source = "NORTH_STAR.md"; Dest = "$GovernanceRoot\NORTH_STAR.md" },
    @{ Source = "FULL_FEATURE_TREE.md"; Dest = "$GovernanceRoot\FULL_FEATURE_TREE.md" },
    @{ Source = "GOVERNANCE_HEAT.md"; Dest = "$GovernanceRoot\GOVERNANCE_HEAT.md" },
    @{ Source = "LOCAL_INVARIANTS.md"; Dest = "$GovernanceRoot\LOCAL_INVARIANTS.md" },
    @{ Source = "AI_START_PROMPT.md"; Dest = "$GovernanceRoot\AI_START_PROMPT.md" },
    @{ Source = "CURRENT_CURSOR.yaml"; Dest = "$GovernanceRoot\CURRENT_CURSOR.yaml" },
    @{ Source = "TOPOLOGY_CURSOR.md"; Dest = "$GovernanceRoot\TOPOLOGY_CURSOR.md" },
    @{ Source = "ASPECT_POLISH_CUTOVER.md"; Dest = "$GovernanceRoot\ASPECT_POLISH_CUTOVER.md" },
    @{ Source = "RELEASE_TRANSITION_EXCEPTION.md"; Dest = "$GovernanceRoot\RELEASE_TRANSITION_EXCEPTION.md" }
)

$scriptMappings = @(
    @{ Source = (Join-Path $PSScriptRoot "check-topological-governance.ps1"); Dest = "tools\check-topological-governance.ps1" },
    @{ Source = (Join-Path $PSScriptRoot "inventory-topology.ps1"); Dest = "tools\inventory-topology.ps1" },
    @{ Source = (Join-Path $PSScriptRoot "check-topology-cursor.ps1"); Dest = "tools\check-topology-cursor.ps1" },
    @{ Source = (Join-Path $PSScriptRoot "check-qpcursor-governance.ps1"); Dest = "tools\check-qpcursor-governance.ps1" },
    @{ Source = (Join-Path $PSScriptRoot "check-topology-ledger.ps1"); Dest = "tools\check-topology-ledger.ps1" },
    @{ Source = (Join-Path $PSScriptRoot "check-forbidden-sibling-edges.ps1"); Dest = "tools\check-forbidden-sibling-edges.ps1" }
)

$schemaMappings = @(
    @{ Source = "project-topology.schema.json"; Dest = "$GovernanceRoot\schemas\project-topology.schema.json" },
    @{ Source = "topology-task-card.schema.json"; Dest = "$GovernanceRoot\schemas\topology-task-card.schema.json" },
    @{ Source = "topology-module-node.schema.json"; Dest = "$GovernanceRoot\schemas\topology-module-node.schema.json" },
    @{ Source = "topology-closeout.schema.json"; Dest = "$GovernanceRoot\schemas\topology-closeout.schema.json" },
    @{ Source = "topology-cursor.schema.json"; Dest = "$GovernanceRoot\schemas\topology-cursor.schema.json" },
    @{ Source = "qpcursor.schema.json"; Dest = "$GovernanceRoot\schemas\qpcursor.schema.json" },
    @{ Source = "north-star.schema.json"; Dest = "$GovernanceRoot\schemas\north-star.schema.json" },
    @{ Source = "full-feature-tree.schema.json"; Dest = "$GovernanceRoot\schemas\full-feature-tree.schema.json" },
    @{ Source = "governance-heat.schema.json"; Dest = "$GovernanceRoot\schemas\governance-heat.schema.json" },
    @{ Source = "local-invariants.schema.json"; Dest = "$GovernanceRoot\schemas\local-invariants.schema.json" }
)

function Copy-TopologyFile {
    param(
        [Parameter(Mandatory = $true)][string]$SourcePath,
        [Parameter(Mandatory = $true)][string]$DestPath
    )

    $destDir = Split-Path -Parent $DestPath
    if ($DryRun) {
        Write-Host "[dry-run] ensure directory $destDir"
    } else {
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    }

    if ((Test-Path -LiteralPath $DestPath) -and -not $Force) {
        Write-Host "[skip] exists: $DestPath"
        return
    }

    if ($DryRun) {
        Write-Host "[dry-run] copy $SourcePath -> $DestPath"
    } else {
        Copy-Item -LiteralPath $SourcePath -Destination $DestPath -Force:$Force
        Write-Host "[ok] wrote: $DestPath"
    }
}

foreach ($mapping in $templateMappings) {
    Copy-TopologyFile -SourcePath (Join-Path $templateRoot $mapping.Source) -DestPath (Join-Path $projectPath $mapping.Dest)
}

foreach ($mapping in $scriptMappings) {
    Copy-TopologyFile -SourcePath $mapping.Source -DestPath (Join-Path $projectPath $mapping.Dest)
}

foreach ($mapping in $schemaMappings) {
    Copy-TopologyFile -SourcePath (Join-Path $schemaRoot $mapping.Source) -DestPath (Join-Path $projectPath $mapping.Dest)
}

$ledgerPath = Join-Path $projectPath "$GovernanceRoot\topology-ledger.ndjson"
if ((Test-Path -LiteralPath $ledgerPath) -and -not $Force) {
    Write-Host "[skip] exists: $ledgerPath"
} elseif ($DryRun) {
    Write-Host "[dry-run] create empty ledger $ledgerPath"
} else {
    $ledgerDir = Split-Path -Parent $ledgerPath
    New-Item -ItemType Directory -Force -Path $ledgerDir | Out-Null
    Set-Content -Encoding UTF8 -LiteralPath $ledgerPath -Value ""
    Write-Host "[ok] wrote: $ledgerPath"
}

Write-Host "Topological modular governance scaffold completed for $projectPath"
Write-Host "Next: fill $GovernanceRoot\PROJECT_TOPOLOGY.md, then run tools\check-topological-governance.ps1"
