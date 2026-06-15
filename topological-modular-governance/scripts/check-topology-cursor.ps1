[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [string]$CursorPath = "docs\topological-governance\CURRENT_CURSOR.yaml"
)

$ErrorActionPreference = "Stop"

$resolvedProject = Resolve-Path -LiteralPath $ProjectRoot
$projectPath = $resolvedProject.ProviderPath
$path = Join-Path $projectPath $CursorPath
$issues = New-Object System.Collections.Generic.List[string]

function Add-Issue {
    param([Parameter(Mandatory = $true)][string]$Message)
    $issues.Add($Message) | Out-Null
}

if (-not (Test-Path -LiteralPath $path)) {
    Add-Issue "missing cursor: $CursorPath"
} else {
    $text = Get-Content -Encoding UTF8 -LiteralPath $path -Raw
    foreach ($field in @("cursor_id", "status", "work_mode_stack", "topology_slice", "parent_node", "allowed_workset", "forbidden_operations", "gates", "closeout_required", "next_action")) {
        if ($text -notmatch "(?m)^\s*$([regex]::Escape($field))\s*:") {
            Add-Issue "cursor missing field: $field"
        }
    }

    $status = ""
    if ($text -match "(?m)^\s*status\s*:\s*(?<value>.+?)\s*$") {
        $status = $Matches.value.Trim().Trim('"')
    }
    if ($status -ne "" -and $status -notin @("active", "blocked", "closed", "superseded")) {
        Add-Issue "cursor status must be active / blocked / closed / superseded"
    }

    $parent = ""
    if ($text -match "(?m)^\s*parent_node\s*:\s*(?<value>.+?)\s*$") {
        $parent = $Matches.value.Trim().Trim('"')
    }
    if ($parent -eq "") {
        Add-Issue "cursor parent_node must be filled"
    }
}

if ($issues.Count -gt 0) {
    Write-Host "Topology cursor check FAILED:"
    foreach ($issue in $issues) {
        Write-Host " - $issue"
    }
    exit 1
}

Write-Host "Topology cursor OK: $path"
exit 0
