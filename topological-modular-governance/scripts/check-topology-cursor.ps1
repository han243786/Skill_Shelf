[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [string]$CursorPath = "docs\topological-governance\CURRENT_CURSOR.yaml",

    [string]$ProjectTopologyPath = "docs\topological-governance\PROJECT_TOPOLOGY.md",

    [string]$LedgerPath = "docs\topological-governance\topology-ledger.ndjson",

    [string]$CloseoutPath = "docs\topological-governance\TOPOLOGY_CLOSEOUT.md"
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

function Get-ScalarField {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $match = [regex]::Match($Text, "(?m)^\s*$([regex]::Escape($Name)):\s*(?<value>.+?)\s*$")
    if (-not $match.Success) {
        return ""
    }
    return $match.Groups["value"].Value.Trim().Trim('"')
}

function Get-TopologyNodes {
    param([Parameter(Mandatory = $true)][string]$ProjectTopologyText)

    $nodes = New-Object System.Collections.Generic.HashSet[string]
    foreach ($line in ($ProjectTopologyText -split "\r?\n")) {
        if ($line -notmatch "^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|") {
            continue
        }

        $node = $Matches[1].Trim()
        $purpose = $Matches[2].Trim()
        $owner = $Matches[3].Trim()
        $paths = $Matches[4].Trim()
        $status = $Matches[5].Trim()

        if ($node -in @("Node", "---", "") -or $purpose -eq "" -or $owner -eq "" -or $paths -eq "" -or $status -eq "") {
            continue
        }

        $nodes.Add($node) | Out-Null
    }
    return $nodes
}

if (-not (Test-Path -LiteralPath $path)) {
    Add-Issue "missing cursor: $CursorPath"
} else {
    $text = Get-Content -Encoding UTF8 -LiteralPath $path -Raw
    foreach ($field in @(
        "cursor_version",
        "cursor_id",
        "status",
        "repo_baseline",
        "mode_stack",
        "north_star",
        "growth_vector",
        "scope",
        "topology_slice",
        "parent_node",
        "governance_heat",
        "required_depth",
        "heat_reason",
        "local_invariants",
        "interface_freeze",
        "anti_regression",
        "allowed_workset",
        "forbidden_operations",
        "gates",
        "closeout_required",
        "next_action",
        "done_when",
        "stop_if",
        "evidence"
    )) {
        if ($text -notmatch "(?m)^\s*$([regex]::Escape($field))\s*:") {
            Add-Issue "cursor missing field: $field"
        }
    }

    $cursorId = Get-ScalarField -Text $text -Name "cursor_id"
    $status = Get-ScalarField -Text $text -Name "status"
    if ($status -ne "" -and $status -notin @("draft", "claimed", "reading_context", "executing", "evidence_pending", "gate_pending", "handoff_ready", "closed", "blocked")) {
        Add-Issue "cursor status must be draft / claimed / reading_context / executing / evidence_pending / gate_pending / handoff_ready / closed / blocked"
    }

    $heat = Get-ScalarField -Text $text -Name "governance_heat"
    if ($heat -ne "" -and $heat -notin @("G0", "G1", "G2", "G3", "G4", "G5")) {
        Add-Issue "cursor governance_heat must be G0 / G1 / G2 / G3 / G4 / G5"
    }

    $depth = Get-ScalarField -Text $text -Name "required_depth"
    if ($depth -ne "" -and $depth -notin @("Light", "Standard", "Precision")) {
        Add-Issue "cursor required_depth must be Light / Standard / Precision"
    }

    $parent = Get-ScalarField -Text $text -Name "parent_node"
    if ($parent -eq "") {
        Add-Issue "cursor parent_node must be filled"
    }

    $topologyPath = Join-Path $projectPath $ProjectTopologyPath
    if ($parent -ne "" -and (Test-Path -LiteralPath $topologyPath)) {
        $topologyText = Get-Content -Encoding UTF8 -LiteralPath $topologyPath -Raw
        $nodes = Get-TopologyNodes -ProjectTopologyText $topologyText
        if ($nodes.Count -gt 0 -and -not $nodes.Contains($parent)) {
            Add-Issue "cursor parent_node '$parent' is not listed in $ProjectTopologyPath"
        }
    }

    if ($status -eq "closed") {
        $ledgerFile = Join-Path $projectPath $LedgerPath
        $closeoutFile = Join-Path $projectPath $CloseoutPath

        if (-not (Test-Path -LiteralPath $ledgerFile)) {
            Add-Issue "closed cursor requires ledger: $LedgerPath"
        } else {
            $hasClosedLedger = $false
            foreach ($line in (Get-Content -Encoding UTF8 -LiteralPath $ledgerFile | Where-Object { $_.Trim() -ne "" })) {
                try {
                    $record = $line | ConvertFrom-Json
                    if ($record.cursor_id -eq $cursorId -and $record.result -eq "closed") {
                        $hasClosedLedger = $true
                    }
                } catch {
                    Add-Issue "closed cursor ledger has invalid JSON: $($_.Exception.Message)"
                }
            }
            if (-not $hasClosedLedger) {
                Add-Issue "closed cursor '$cursorId' requires a matching closed ledger row"
            }
        }

        if (Test-Path -LiteralPath $closeoutFile) {
            $closeoutText = Get-Content -Encoding UTF8 -LiteralPath $closeoutFile -Raw
            $closeoutResult = Get-ScalarField -Text $closeoutText -Name "result"
            if ($closeoutResult -ne "closed") {
                Add-Issue "closed cursor requires TOPOLOGY_CLOSEOUT.md result: closed"
            }
        }
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
