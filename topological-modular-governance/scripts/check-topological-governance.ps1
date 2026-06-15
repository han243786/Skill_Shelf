[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [string]$GovernanceRoot = "docs\topological-governance"
)

$ErrorActionPreference = "Stop"

$resolvedProject = Resolve-Path -LiteralPath $ProjectRoot
$projectPath = $resolvedProject.ProviderPath

$required = @(
    "$GovernanceRoot\PROJECT_TOPOLOGY.md",
    "$GovernanceRoot\WORK_MODE_ROUTER.md",
    "$GovernanceRoot\TOPOLOGY_TASK_CARD.md",
    "$GovernanceRoot\TOPOLOGY_MODULE_NODE.md",
    "$GovernanceRoot\TOPOLOGY_CLOSEOUT.md",
    "$GovernanceRoot\AI_START_PROMPT.md"
)

$requiredTerms = @{
    "$GovernanceRoot\PROJECT_TOPOLOGY.md" = @("Top-Level Nodes", "Parent-Child Communication Rules", "Hot Assets", "Known Old Path Debt")
    "$GovernanceRoot\WORK_MODE_ROUTER.md" = @("refactor", "advance", "aspect_polish", "doc_debt_cleanup")
    "$GovernanceRoot\TOPOLOGY_TASK_CARD.md" = @("work_mode", "parent_node", "changed_edges", "exit_gate")
    "$GovernanceRoot\TOPOLOGY_CLOSEOUT.md" = @("topology_closeout", "nodes_changed", "edges_changed", "old_paths")
}

$issues = New-Object System.Collections.Generic.List[string]

foreach ($relative in $required) {
    $path = Join-Path $projectPath $relative
    if (-not (Test-Path -LiteralPath $path)) {
        $issues.Add("missing: $relative") | Out-Null
        continue
    }

    $item = Get-Item -LiteralPath $path
    if ($item.Length -le 0) {
        $issues.Add("empty: $relative") | Out-Null
    }
}

foreach ($relative in $requiredTerms.Keys) {
    $path = Join-Path $projectPath $relative
    if (-not (Test-Path -LiteralPath $path)) {
        continue
    }

    $text = Get-Content -Encoding UTF8 -LiteralPath $path -Raw
    foreach ($term in $requiredTerms[$relative]) {
        if ($text -notmatch [regex]::Escape($term)) {
            $issues.Add("missing term '$term' in $relative") | Out-Null
        }
    }
}

if ($issues.Count -gt 0) {
    Write-Host "Topological governance check FAILED:"
    foreach ($issue in $issues) {
        Write-Host " - $issue"
    }
    exit 1
}

Write-Host "Topological governance scaffold OK: $projectPath"
exit 0
