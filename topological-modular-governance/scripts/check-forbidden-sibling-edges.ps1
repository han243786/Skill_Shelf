[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [string]$GovernanceRoot = "docs\topological-governance"
)

$ErrorActionPreference = "Stop"

$resolvedProject = Resolve-Path -LiteralPath $ProjectRoot
$projectPath = $resolvedProject.ProviderPath
$issues = New-Object System.Collections.Generic.List[string]

function Add-Issue {
    param([Parameter(Mandatory = $true)][string]$Message)
    $issues.Add($Message) | Out-Null
}

$exceptionPath = Join-Path $projectPath "$GovernanceRoot\RELEASE_TRANSITION_EXCEPTION.md"
$taskPath = Join-Path $projectPath "$GovernanceRoot\TOPOLOGY_TASK_CARD.md"

$texts = @()
foreach ($path in @($taskPath)) {
    if (Test-Path -LiteralPath $path) {
        $texts += Get-Content -Encoding UTF8 -LiteralPath $path -Raw
    }
}

$mentionsDirectSibling = ($texts -join "`n") -match "sibling_direct|direct sibling|direct_edge|横向直连|sibling-to-sibling"
$hasApprovedException = $false
if (Test-Path -LiteralPath $exceptionPath) {
    $exceptionText = Get-Content -Encoding UTF8 -LiteralPath $exceptionPath -Raw
    $hasApprovedException = $exceptionText -match "(?m)^\s*status\s*:\s*approved\s*$" -and
        $exceptionText -match "(?m)^\s*approved_by\s*:\s*\S+" -and
        $exceptionText -match "(?m)^\s*rollback\s*:\s*\S+" -and
        $exceptionText -match "(?m)^\s*performance_evidence\s*:\s*\S+"
}

if ($mentionsDirectSibling -and -not $hasApprovedException) {
    Add-Issue "direct sibling edge mentioned but no approved RELEASE_TRANSITION_EXCEPTION.md with approved_by, performance_evidence, and rollback"
}

if ($issues.Count -gt 0) {
    Write-Host "Forbidden sibling edge check FAILED:"
    foreach ($issue in $issues) {
        Write-Host " - $issue"
    }
    exit 1
}

Write-Host "Forbidden sibling edge check OK: $projectPath"
exit 0
