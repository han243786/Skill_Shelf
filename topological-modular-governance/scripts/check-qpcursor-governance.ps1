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

function Read-Text {
    param([Parameter(Mandatory = $true)][string]$Relative)
    $path = Join-Path $projectPath $Relative
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Issue "missing: $Relative"
        return ""
    }
    return Get-Content -Encoding UTF8 -LiteralPath $path -Raw
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

function Test-IsPlaceholder {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $true
    }
    $normalized = $Value.Trim().ToLowerInvariant()
    return $normalized -in @("none", "n/a", "na", "todo", "tbd", "pending", "proposed", "trust me", "unknown", "-")
}

function Assert-FieldPresent {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Field,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Text -notmatch "(?m)^\s*$([regex]::Escape($Field))\s*:") {
        Add-Issue "$Context missing field: $Field"
    }
}

function Assert-ScalarFilled {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Field,
        [Parameter(Mandatory = $true)][string]$Context,
        [string[]]$AllowValues = @()
    )

    $value = Get-ScalarField -Text $Text -Name $Field
    if (Test-IsPlaceholder -Value $value) {
        Add-Issue "$Context $Field must be filled"
        return ""
    }
    if ($AllowValues.Count -gt 0 -and $value -notin $AllowValues) {
        Add-Issue "$Context $Field must be one of: $($AllowValues -join ' / ')"
    }
    return $value
}

function Test-BlockHasListItem {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Field
    )

    $lines = $Text -split "\r?\n"
    $foundField = $false
    foreach ($line in $lines) {
        if (-not $foundField) {
            if ($line -match "^\s*$([regex]::Escape($Field))\s*:") {
                $foundField = $true
            }
            continue
        }

        if ($line -match "^\S[^:]*:\s*") {
            return $false
        }
        if ($line -match "^\s*-\s*(?<item>.+?)\s*$") {
            return -not (Test-IsPlaceholder -Value $Matches["item"])
        }
    }

    return $false
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

function Get-MinDepthForHeat {
    param([Parameter(Mandatory = $true)][string]$Heat)

    if ($Heat -in @("G0", "G1")) { return "Light" }
    if ($Heat -in @("G2", "G3")) { return "Standard" }
    return "Precision"
}

function Get-DepthRank {
    param([Parameter(Mandatory = $true)][string]$Depth)

    switch ($Depth) {
        "Light" { return 1 }
        "Standard" { return 2 }
        "Precision" { return 3 }
        default { return 0 }
    }
}

$cursorRelative = "$GovernanceRoot\CURRENT_CURSOR.yaml"
$northStarRelative = "$GovernanceRoot\NORTH_STAR.md"
$featureTreeRelative = "$GovernanceRoot\FULL_FEATURE_TREE.md"
$heatRelative = "$GovernanceRoot\GOVERNANCE_HEAT.md"
$localRelative = "$GovernanceRoot\LOCAL_INVARIANTS.md"
$topologyRelative = "$GovernanceRoot\PROJECT_TOPOLOGY.md"

$cursor = Read-Text -Relative $cursorRelative
$northStar = Read-Text -Relative $northStarRelative
$featureTree = Read-Text -Relative $featureTreeRelative
$heatDoc = Read-Text -Relative $heatRelative
$local = Read-Text -Relative $localRelative
$topology = Read-Text -Relative $topologyRelative

if ($cursor -ne "") {
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
        Assert-FieldPresent -Text $cursor -Field $field -Context $cursorRelative
    }

    Assert-ScalarFilled -Text $cursor -Field "cursor_version" -Context $cursorRelative | Out-Null
    Assert-ScalarFilled -Text $cursor -Field "cursor_id" -Context $cursorRelative | Out-Null
    $status = Assert-ScalarFilled -Text $cursor -Field "status" -Context $cursorRelative -AllowValues @("draft", "claimed", "reading_context", "executing", "evidence_pending", "gate_pending", "handoff_ready", "closed", "blocked")
    $heat = Assert-ScalarFilled -Text $cursor -Field "governance_heat" -Context $cursorRelative -AllowValues @("G0", "G1", "G2", "G3", "G4", "G5")
    $depth = Assert-ScalarFilled -Text $cursor -Field "required_depth" -Context $cursorRelative -AllowValues @("Light", "Standard", "Precision")
    Assert-ScalarFilled -Text $cursor -Field "heat_reason" -Context $cursorRelative | Out-Null
    Assert-ScalarFilled -Text $cursor -Field "next_action" -Context $cursorRelative | Out-Null
    Assert-ScalarFilled -Text $cursor -Field "done_when" -Context $cursorRelative | Out-Null
    Assert-ScalarFilled -Text $cursor -Field "alignment" -Context "$cursorRelative north_star" | Out-Null
    Assert-ScalarFilled -Text $cursor -Field "next_growth" -Context "$cursorRelative growth_vector" | Out-Null
    Assert-ScalarFilled -Text $cursor -Field "convergence_signal" -Context "$cursorRelative growth_vector" | Out-Null

    if ($heat -ne "" -and $depth -ne "") {
        $minimumDepth = Get-MinDepthForHeat -Heat $heat
        if ((Get-DepthRank -Depth $depth) -lt (Get-DepthRank -Depth $minimumDepth)) {
            Add-Issue "$cursorRelative required_depth '$depth' is weaker than minimum '$minimumDepth' for $heat"
        }
    }

    foreach ($listField in @("stop_if", "required_commands", "manual_checks", "completed", "pending_risks")) {
        if (-not (Test-BlockHasListItem -Text $cursor -Field $listField)) {
            Add-Issue "$cursorRelative $listField must contain at least one non-placeholder list item"
        }
    }

    $parent = Get-ScalarField -Text $cursor -Name "parent_node"
    if (Test-IsPlaceholder -Value $parent) {
        Add-Issue "$cursorRelative parent_node must be filled"
    } elseif ($topology -ne "") {
        $nodes = Get-TopologyNodes -ProjectTopologyText $topology
        if ($nodes.Count -gt 0 -and -not $nodes.Contains($parent)) {
            Add-Issue "$cursorRelative parent_node '$parent' is not listed in $topologyRelative"
        }
    }

    if ($status -eq "blocked" -and (Test-IsPlaceholder -Value (Get-ScalarField -Text $cursor -Name "next_action"))) {
        Add-Issue "$cursorRelative blocked status requires next_action"
    }
}

if ($northStar -ne "") {
    foreach ($field in @("north_star", "final_state", "success_shape", "growth_direction", "anti_regression", "convergence_evidence", "clarity_log")) {
        Assert-FieldPresent -Text $northStar -Field $field -Context $northStarRelative
    }
    Assert-ScalarFilled -Text $northStar -Field "final_state" -Context $northStarRelative | Out-Null
    Assert-ScalarFilled -Text $northStar -Field "next_growth" -Context $northStarRelative | Out-Null
}

if ($featureTree -ne "") {
    foreach ($field in @("feature_tree_version", "north_star", "root_capabilities", "active_growth_paths", "protected_behaviors", "known_gaps", "feature_nodes", "growth_edges")) {
        Assert-FieldPresent -Text $featureTree -Field $field -Context $featureTreeRelative
    }
    Assert-ScalarFilled -Text $featureTree -Field "feature_tree_version" -Context $featureTreeRelative | Out-Null
    Assert-ScalarFilled -Text $featureTree -Field "north_star" -Context $featureTreeRelative | Out-Null
}

if ($heatDoc -ne "") {
    foreach ($term in @("G0", "G1", "G2", "G3", "G4", "G5", "Light", "Standard", "Precision", "Upgrade Rules")) {
        if ($heatDoc -notmatch [regex]::Escape($term)) {
            Add-Issue "$heatRelative missing term: $term"
        }
    }
}

if ($local -ne "") {
    foreach ($field in @("module", "scope", "user_function_facet", "full_feature_tree", "module_tree", "public_surface", "allowed_edges", "forbidden_edges", "local_invariants", "north_star_refs", "heat_escalation", "stop_if", "gates")) {
        Assert-FieldPresent -Text $local -Field $field -Context $localRelative
    }

    Assert-ScalarFilled -Text $local -Field "module" -Context $localRelative | Out-Null
    foreach ($listField in @("public_surface", "allowed_edges", "forbidden_edges", "local_invariants", "heat_escalation", "stop_if", "gates")) {
        if (-not (Test-BlockHasListItem -Text $local -Field $listField)) {
            Add-Issue "$localRelative $listField must contain at least one non-placeholder list item"
        }
    }
}

if ($issues.Count -gt 0) {
    Write-Host "QPCursor governance check FAILED:"
    foreach ($issue in $issues) {
        Write-Host " - $issue"
    }
    exit 1
}

Write-Host "QPCursor governance OK: $projectPath"
exit 0
