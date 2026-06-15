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
    "$GovernanceRoot\AI_START_PROMPT.md",
    "$GovernanceRoot\CURRENT_CURSOR.yaml",
    "$GovernanceRoot\TOPOLOGY_CURSOR.md",
    "$GovernanceRoot\ASPECT_POLISH_CUTOVER.md",
    "$GovernanceRoot\RELEASE_TRANSITION_EXCEPTION.md"
)

$requiredTerms = @{
    "$GovernanceRoot\PROJECT_TOPOLOGY.md" = @("Top-Level Nodes", "Parent-Child Communication Rules", "Hot Assets", "Known Old Path Debt")
    "$GovernanceRoot\WORK_MODE_ROUTER.md" = @("refactor", "advance", "aspect_polish", "doc_debt_cleanup")
    "$GovernanceRoot\TOPOLOGY_TASK_CARD.md" = @("work_mode", "parent_node", "changed_edges", "exit_gate")
    "$GovernanceRoot\TOPOLOGY_CLOSEOUT.md" = @("topology_closeout", "nodes_changed", "edges_changed", "old_paths")
    "$GovernanceRoot\AI_START_PROMPT.md" = @("Stop immediately", "parent_node cannot be found", "release-transition")
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

    $result = Get-ScalarField -Text $closeout -Name "result"
    $oldPaths = Get-ScalarField -Text $closeout -Name "old_paths"
    if ($oldPaths -ne "" -and $oldPaths -notin @("none", "archived", "retired", "debt_open")) {
        Add-Issue "strict: old_paths must be one of none / archived / retired / debt_open"
    }
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
