[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [string]$GovernanceRoot = "docs\topological-governance",

    [switch]$Strict
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
    "$GovernanceRoot\QPCURSOR.md",
    "$GovernanceRoot\NORTH_STAR.md",
    "$GovernanceRoot\FULL_FEATURE_TREE.md",
    "$GovernanceRoot\GOVERNANCE_HEAT.md",
    "$GovernanceRoot\LOCAL_INVARIANTS.md",
    "$GovernanceRoot\AI_START_PROMPT.md",
    "$GovernanceRoot\CURRENT_CURSOR.yaml",
    "$GovernanceRoot\TOPOLOGY_CURSOR.md",
    "$GovernanceRoot\ASPECT_POLISH_CUTOVER.md",
    "$GovernanceRoot\RELEASE_TRANSITION_EXCEPTION.md",
    "$GovernanceRoot\schemas\project-topology.schema.json",
    "$GovernanceRoot\schemas\topology-task-card.schema.json",
    "$GovernanceRoot\schemas\topology-module-node.schema.json",
    "$GovernanceRoot\schemas\topology-closeout.schema.json",
    "$GovernanceRoot\schemas\topology-cursor.schema.json",
    "$GovernanceRoot\schemas\qpcursor.schema.json",
    "$GovernanceRoot\schemas\north-star.schema.json",
    "$GovernanceRoot\schemas\full-feature-tree.schema.json",
    "$GovernanceRoot\schemas\governance-heat.schema.json",
    "$GovernanceRoot\schemas\local-invariants.schema.json"
)

$requiredTerms = @{
    "$GovernanceRoot\PROJECT_TOPOLOGY.md" = @("Top-Level Nodes", "Parent-Child Communication Rules", "Hot Assets", "Known Old Path Debt", "north_star", "full_feature_tree", "module_topology_tree", "qpcursor_required")
    "$GovernanceRoot\WORK_MODE_ROUTER.md" = @("refactor", "advance", "aspect_polish", "doc_debt_cleanup")
    "$GovernanceRoot\TOPOLOGY_TASK_CARD.md" = @("work_mode", "parent_node", "changed_edges", "north_star_alignment", "growth_vector", "governance_heat", "required_depth", "exit_gate")
    "$GovernanceRoot\TOPOLOGY_CLOSEOUT.md" = @("topology_closeout", "nodes_changed", "edges_changed", "governance_heat", "evidence", "old_paths")
    "$GovernanceRoot\QPCURSOR.md" = @("cursor_version", "north_star", "growth_vector", "governance_heat", "local_invariants", "interface_freeze", "anti_regression", "evidence")
    "$GovernanceRoot\NORTH_STAR.md" = @("north_star", "final_state", "growth_direction", "anti_regression", "convergence_evidence")
    "$GovernanceRoot\FULL_FEATURE_TREE.md" = @("feature_tree_version", "north_star", "feature_nodes", "growth_edges")
    "$GovernanceRoot\GOVERNANCE_HEAT.md" = @("G0", "G1", "G2", "G3", "G4", "G5", "Light", "Standard", "Precision")
    "$GovernanceRoot\LOCAL_INVARIANTS.md" = @("module", "public_surface", "forbidden_edges", "local_invariants", "north_star_refs", "stop_if")
    "$GovernanceRoot\AI_START_PROMPT.md" = @("Stop immediately", "parent_node cannot be found", "governance_heat", "local invariants", "release-transition")
}

$issues = New-Object System.Collections.Generic.List[string]

function Add-Issue {
    param([Parameter(Mandatory = $true)][string]$Message)
    $issues.Add($Message) | Out-Null
}

function Read-ProjectText {
    param([Parameter(Mandatory = $true)][string]$Relative)
    $path = Join-Path $projectPath $Relative
    return Get-Content -Encoding UTF8 -LiteralPath $path -Raw
}

function Get-ScalarField {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $pattern = "(?m)^\s*$([regex]::Escape($Name)):\s*(?<value>.+?)\s*$"
    $match = [regex]::Match($Text, $pattern)
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

        if ($node -in @("Node", "---", "")) {
            continue
        }
        if ($node -eq "" -or $purpose -eq "" -or $owner -eq "" -or $paths -eq "" -or $status -eq "") {
            continue
        }
        if ($node -eq " " -or $purpose -eq " " -or $owner -eq " " -or $paths -eq " " -or $status -eq " ") {
            continue
        }
        $nodes.Add($node) | Out-Null
    }
    return $nodes
}

function Test-PathList {
    param(
        [Parameter(Mandatory = $true)][string]$PathList,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $items = $PathList -split "[,;]" | ForEach-Object { $_.Trim().Trim("`"") } | Where-Object { $_ -ne "" -and $_ -ne "none" }
    foreach ($item in $items) {
        $candidate = Join-Path $projectPath $item
        if (-not (Test-Path -LiteralPath $candidate)) {
            Add-Issue "$Context path does not exist: $item"
        }
    }
}

function Read-ProjectJson {
    param([Parameter(Mandatory = $true)][string]$Relative)
    $path = Join-Path $projectPath $Relative
    return Get-Content -Encoding UTF8 -LiteralPath $path -Raw | ConvertFrom-Json
}

function Assert-SchemaRequiredFieldsAppear {
    param(
        [Parameter(Mandatory = $true)][string]$SchemaRelative,
        [Parameter(Mandatory = $true)][string]$TemplateRelative
    )

    $schemaPath = Join-Path $projectPath $SchemaRelative
    $templatePath = Join-Path $projectPath $TemplateRelative
    if (-not (Test-Path -LiteralPath $schemaPath) -or -not (Test-Path -LiteralPath $templatePath)) {
        return
    }

    try {
        $schema = Read-ProjectJson -Relative $SchemaRelative
    } catch {
        Add-Issue "schema is not valid JSON: $SchemaRelative - $($_.Exception.Message)"
        return
    }

    $templateText = Get-Content -Encoding UTF8 -LiteralPath $templatePath -Raw
    foreach ($field in @($schema.required)) {
        if ($templateText -notmatch "(?m)^\s*$([regex]::Escape($field))\s*:") {
            Add-Issue "schema/template mismatch: required field '$field' from $SchemaRelative is missing in $TemplateRelative"
        }
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
    if ($value -eq "") {
        Add-Issue "strict: $Context $Field must be filled"
        return ""
    }
    if ($AllowValues.Count -gt 0 -and $value -notin $AllowValues) {
        Add-Issue "strict: $Context $Field must be one of: $($AllowValues -join ' / ')"
    }
    return $value
}

foreach ($schemaRelative in @(
    "$GovernanceRoot\schemas\project-topology.schema.json",
    "$GovernanceRoot\schemas\topology-task-card.schema.json",
    "$GovernanceRoot\schemas\topology-module-node.schema.json",
    "$GovernanceRoot\schemas\topology-closeout.schema.json",
    "$GovernanceRoot\schemas\topology-cursor.schema.json",
    "$GovernanceRoot\schemas\qpcursor.schema.json",
    "$GovernanceRoot\schemas\north-star.schema.json",
    "$GovernanceRoot\schemas\full-feature-tree.schema.json",
    "$GovernanceRoot\schemas\governance-heat.schema.json",
    "$GovernanceRoot\schemas\local-invariants.schema.json"
)) {
    $schemaPath = Join-Path $projectPath $schemaRelative
    if (Test-Path -LiteralPath $schemaPath) {
        try {
            Read-ProjectJson -Relative $schemaRelative | Out-Null
        } catch {
            Add-Issue "schema is not valid JSON: $schemaRelative - $($_.Exception.Message)"
        }
    }
}

Assert-SchemaRequiredFieldsAppear -SchemaRelative "$GovernanceRoot\schemas\topology-task-card.schema.json" -TemplateRelative "$GovernanceRoot\TOPOLOGY_TASK_CARD.md"
Assert-SchemaRequiredFieldsAppear -SchemaRelative "$GovernanceRoot\schemas\topology-closeout.schema.json" -TemplateRelative "$GovernanceRoot\TOPOLOGY_CLOSEOUT.md"
Assert-SchemaRequiredFieldsAppear -SchemaRelative "$GovernanceRoot\schemas\topology-cursor.schema.json" -TemplateRelative "$GovernanceRoot\CURRENT_CURSOR.yaml"
Assert-SchemaRequiredFieldsAppear -SchemaRelative "$GovernanceRoot\schemas\qpcursor.schema.json" -TemplateRelative "$GovernanceRoot\CURRENT_CURSOR.yaml"
Assert-SchemaRequiredFieldsAppear -SchemaRelative "$GovernanceRoot\schemas\north-star.schema.json" -TemplateRelative "$GovernanceRoot\NORTH_STAR.md"
Assert-SchemaRequiredFieldsAppear -SchemaRelative "$GovernanceRoot\schemas\full-feature-tree.schema.json" -TemplateRelative "$GovernanceRoot\FULL_FEATURE_TREE.md"
Assert-SchemaRequiredFieldsAppear -SchemaRelative "$GovernanceRoot\schemas\governance-heat.schema.json" -TemplateRelative "$GovernanceRoot\GOVERNANCE_HEAT.md"
Assert-SchemaRequiredFieldsAppear -SchemaRelative "$GovernanceRoot\schemas\local-invariants.schema.json" -TemplateRelative "$GovernanceRoot\LOCAL_INVARIANTS.md"

foreach ($relative in $required) {
    $path = Join-Path $projectPath $relative
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Issue "missing: $relative"
        continue
    }

    $item = Get-Item -LiteralPath $path
    if ($item.Length -le 0) {
        Add-Issue "empty: $relative"
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
            Add-Issue "missing term '$term' in $relative"
        }
    }
}

if ($Strict) {
    $projectTopology = Read-ProjectText -Relative "$GovernanceRoot\PROJECT_TOPOLOGY.md"
    $taskCard = Read-ProjectText -Relative "$GovernanceRoot\TOPOLOGY_TASK_CARD.md"
    $closeout = Read-ProjectText -Relative "$GovernanceRoot\TOPOLOGY_CLOSEOUT.md"

    $nodes = Get-TopologyNodes -ProjectTopologyText $projectTopology
    if ($nodes.Count -eq 0) {
        Add-Issue "strict: PROJECT_TOPOLOGY.md must contain at least one filled Top-Level Nodes row"
    }

    foreach ($line in ($projectTopology -split "\r?\n")) {
        if ($line -match "^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|") {
            $node = $Matches[1].Trim()
            $paths = $Matches[4].Trim()
            if ($node -notin @("Node", "---", "") -and $paths -ne "") {
                Test-PathList -PathList $paths -Context "PROJECT_TOPOLOGY.md node '$node'"
            }
        }
    }

    $workMode = Assert-ScalarFilled -Text $taskCard -Field "work_mode" -Context "TOPOLOGY_TASK_CARD.md" -AllowValues @("refactor", "advance", "aspect_polish", "doc_debt_cleanup")
    Assert-ScalarFilled -Text $taskCard -Field "north_star_alignment" -Context "TOPOLOGY_TASK_CARD.md" | Out-Null
    Assert-ScalarFilled -Text $taskCard -Field "growth_vector" -Context "TOPOLOGY_TASK_CARD.md" | Out-Null
    Assert-ScalarFilled -Text $taskCard -Field "governance_heat" -Context "TOPOLOGY_TASK_CARD.md" -AllowValues @("G0", "G1", "G2", "G3", "G4", "G5") | Out-Null
    Assert-ScalarFilled -Text $taskCard -Field "required_depth" -Context "TOPOLOGY_TASK_CARD.md" -AllowValues @("Light", "Standard", "Precision") | Out-Null
    Assert-ScalarFilled -Text $taskCard -Field "heat_reason" -Context "TOPOLOGY_TASK_CARD.md" | Out-Null
    Assert-ScalarFilled -Text $taskCard -Field "reason" -Context "TOPOLOGY_TASK_CARD.md" | Out-Null
    Assert-ScalarFilled -Text $taskCard -Field "allowed_scope" -Context "TOPOLOGY_TASK_CARD.md" | Out-Null

    $parentNode = Get-ScalarField -Text $taskCard -Name "parent_node"
    if ($parentNode -eq "") {
        Add-Issue "strict: TOPOLOGY_TASK_CARD.md parent_node must be filled"
    } elseif ($nodes.Count -gt 0 -and -not $nodes.Contains($parentNode)) {
        Add-Issue "strict: parent_node '$parentNode' is not listed in PROJECT_TOPOLOGY.md"
    }

    $changedEdges = Get-ScalarField -Text $taskCard -Name "changed_edges"
    if ($changedEdges -eq "") {
        Add-Issue "strict: changed_edges must be filled with 'none' or a real edge"
    }

    $gates = Get-ScalarField -Text $taskCard -Name "gates"
    if ($gates -eq "") {
        Add-Issue "strict: gates must include at least one real command or manual acceptance item"
    }
    Assert-ScalarFilled -Text $taskCard -Field "exit_gate" -Context "TOPOLOGY_TASK_CARD.md" | Out-Null
    Assert-ScalarFilled -Text $taskCard -Field "rollback" -Context "TOPOLOGY_TASK_CARD.md" | Out-Null
    Assert-ScalarFilled -Text $taskCard -Field "local_invariants" -Context "TOPOLOGY_TASK_CARD.md" | Out-Null
    Assert-ScalarFilled -Text $taskCard -Field "stop_if" -Context "TOPOLOGY_TASK_CARD.md" | Out-Null

    $closeoutMode = Assert-ScalarFilled -Text $closeout -Field "mode" -Context "TOPOLOGY_CLOSEOUT.md" -AllowValues @("refactor", "advance", "aspect_polish", "doc_debt_cleanup")
    $closeoutParent = Assert-ScalarFilled -Text $closeout -Field "parent" -Context "TOPOLOGY_CLOSEOUT.md"
    if ($closeoutParent -ne "" -and $nodes.Count -gt 0 -and -not $nodes.Contains($closeoutParent)) {
        Add-Issue "strict: closeout parent '$closeoutParent' is not listed in PROJECT_TOPOLOGY.md"
    }
    foreach ($field in @("cursor_id", "north_star_alignment", "convergence_evidence", "governance_heat", "required_depth", "nodes_changed", "edges_changed", "public_surface", "local_invariants", "interface_freeze", "full_tree", "module_tree", "tests_or_smoke", "evidence", "next")) {
        Assert-ScalarFilled -Text $closeout -Field $field -Context "TOPOLOGY_CLOSEOUT.md" | Out-Null
    }
    Assert-ScalarFilled -Text $closeout -Field "governance_heat" -Context "TOPOLOGY_CLOSEOUT.md" -AllowValues @("G0", "G1", "G2", "G3", "G4", "G5") | Out-Null
    Assert-ScalarFilled -Text $closeout -Field "required_depth" -Context "TOPOLOGY_CLOSEOUT.md" -AllowValues @("Light", "Standard", "Precision") | Out-Null
    $oldPaths = Assert-ScalarFilled -Text $closeout -Field "old_paths" -Context "TOPOLOGY_CLOSEOUT.md" -AllowValues @("none", "archived", "retired", "debt_open")
    $result = Assert-ScalarFilled -Text $closeout -Field "result" -Context "TOPOLOGY_CLOSEOUT.md" -AllowValues @("closed", "closed_with_debt", "blocked", "needs_mode_jump")
    if ($result -eq "closed") {
        foreach ($field in @("full_tree", "module_tree", "tests_or_smoke")) {
            if ((Get-ScalarField -Text $closeout -Name $field) -eq "") {
                Add-Issue "strict: closeout result=closed requires non-empty $field"
            }
        }
    }
    if ($result -in @("blocked", "needs_mode_jump") -and (Get-ScalarField -Text $closeout -Name "next") -eq "") {
        Add-Issue "strict: blocked / needs_mode_jump requires next action"
    }
}

if ($issues.Count -gt 0) {
    Write-Host "Topological governance check FAILED:"
    foreach ($issue in $issues) {
        Write-Host " - $issue"
    }
    exit 1
}

if ($Strict) {
    Write-Host "Topological governance strict check OK: $projectPath"
} else {
    Write-Host "Topological governance scaffold OK: $projectPath"
}
exit 0
