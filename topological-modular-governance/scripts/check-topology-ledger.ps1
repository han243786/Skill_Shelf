[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [string]$LedgerPath = "docs\topological-governance\topology-ledger.ndjson",

    [switch]$AllowEmpty
)

$ErrorActionPreference = "Stop"

$resolvedProject = Resolve-Path -LiteralPath $ProjectRoot
$projectPath = $resolvedProject.ProviderPath
$path = Join-Path $projectPath $LedgerPath
$issues = New-Object System.Collections.Generic.List[string]

function Add-Issue {
    param([Parameter(Mandatory = $true)][string]$Message)
    $issues.Add($Message) | Out-Null
}

if (-not (Test-Path -LiteralPath $path)) {
    Add-Issue "missing ledger: $LedgerPath"
} else {
    $lines = Get-Content -Encoding UTF8 -LiteralPath $path | Where-Object { $_.Trim() -ne "" }
    if ($lines.Count -eq 0 -and -not $AllowEmpty) {
        Add-Issue "ledger is empty: $LedgerPath"
    }

    $lineNo = 0
    foreach ($line in $lines) {
        $lineNo++
        try {
            $record = $line | ConvertFrom-Json
        } catch {
            Add-Issue "invalid JSON at ledger line ${lineNo}: $($_.Exception.Message)"
            continue
        }

        foreach ($field in @("cursor_id", "mode", "parent", "nodes_changed", "edges_changed", "gates", "result", "next")) {
            if (-not ($record.PSObject.Properties.Name -contains $field)) {
                Add-Issue "ledger line ${lineNo} missing field: $field"
            }
        }

        if (($record.PSObject.Properties.Name -contains "mode") -and $record.mode -notin @("refactor", "advance", "aspect_polish", "doc_debt_cleanup")) {
            Add-Issue "ledger line ${lineNo} has invalid mode: $($record.mode)"
        }
        if (($record.PSObject.Properties.Name -contains "result") -and $record.result -notin @("closed", "closed_with_debt", "blocked", "needs_mode_jump")) {
            Add-Issue "ledger line ${lineNo} has invalid result: $($record.result)"
        }
    }
}

if ($issues.Count -gt 0) {
    Write-Host "Topology ledger check FAILED:"
    foreach ($issue in $issues) {
        Write-Host " - $issue"
    }
    exit 1
}

Write-Host "Topology ledger OK: $path"
exit 0
