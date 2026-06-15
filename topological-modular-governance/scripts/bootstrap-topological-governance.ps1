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

$templateMappings = @(
    @{ Source = "PROJECT_TOPOLOGY.md"; Dest = "$GovernanceRoot\PROJECT_TOPOLOGY.md" },
    @{ Source = "WORK_MODE_ROUTER.md"; Dest = "$GovernanceRoot\WORK_MODE_ROUTER.md" },
    @{ Source = "TOPOLOGY_TASK_CARD.md"; Dest = "$GovernanceRoot\TOPOLOGY_TASK_CARD.md" },
    @{ Source = "TOPOLOGY_MODULE_NODE.md"; Dest = "$GovernanceRoot\TOPOLOGY_MODULE_NODE.md" },
    @{ Source = "TOPOLOGY_CLOSEOUT.md"; Dest = "$GovernanceRoot\TOPOLOGY_CLOSEOUT.md" },
    @{ Source = "AI_START_PROMPT.md"; Dest = "$GovernanceRoot\AI_START_PROMPT.md" }
)

$scriptMappings = @(
    @{ Source = (Join-Path $PSScriptRoot "check-topological-governance.ps1"); Dest = "tools\check-topological-governance.ps1" },
    @{ Source = (Join-Path $PSScriptRoot "inventory-topology.ps1"); Dest = "tools\inventory-topology.ps1" }
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

Write-Host "Topological modular governance scaffold completed for $projectPath"
Write-Host "Next: fill $GovernanceRoot\PROJECT_TOPOLOGY.md, then run tools\check-topological-governance.ps1"
