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
    return $normalized -in @("none", "n/a", "na", "todo", "tbd", "pending", "proposed", "trust me", "unknown")
}

function Test-IsInvalidApprover {
    param([string]$Value)
    if (Test-IsPlaceholder -Value $Value) {
        return $true
    }
    $normalized = $Value.Trim().ToLowerInvariant()
    return $normalized -in @("bot", "ai", "assistant", "codex", "auto", "automated")
}

function Test-IsGuardrailLine {
    param([string]$Line)
    $lower = $Line.ToLowerInvariant()
    return (
        $lower -match "not allowed" -or
        $lower -match "must not" -or
        $lower -match "do not" -or
        $lower -match "unless" -or
        $lower -match "without_release_transition" -or
        $lower -match "forbidden_operations" -or
        $lower -match "ai must not" -or
        $Line -match "不得" -or
        $Line -match "禁止"
    )
}

function Find-DirectSiblingMentions {
    param(
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][string]$Text
    )

    $findings = New-Object System.Collections.Generic.List[string]
    $lineNo = 0
    $inForbiddenEdges = $false
    foreach ($line in ($Text -split "\r?\n")) {
        $lineNo += 1
        $trimmed = $line.Trim()

        if ($trimmed -match "^\s*forbidden_edges\s*:") {
            $inForbiddenEdges = $true
            continue
        }
        if ($inForbiddenEdges -and $trimmed -match "^\s*-") {
            continue
        }
        if ($inForbiddenEdges -and $trimmed -match "^\s*[A-Za-z0-9_-]+\s*:") {
            $inForbiddenEdges = $false
        }

        if ($trimmed -eq "" -or (Test-IsGuardrailLine -Line $trimmed)) {
            continue
        }

        $explicitDirect = $trimmed -match "sibling_direct|direct sibling|direct_edge|sibling-to-sibling|cross-child direct|横向直连"
        $arrowDirect = $trimmed -match "->" -and $trimmed -match "direct|private call|bypass|shortcut|hot path|横向"
        if ($explicitDirect -or $arrowDirect) {
            $findings.Add("${RelativePath}:${lineNo}: $trimmed") | Out-Null
        }
    }
    return $findings
}

$exceptionPath = Join-Path $projectPath "$GovernanceRoot\RELEASE_TRANSITION_EXCEPTION.md"
$scanFiles = @(
    "$GovernanceRoot\TOPOLOGY_TASK_CARD.md",
    "$GovernanceRoot\TOPOLOGY_MODULE_NODE.md",
    "$GovernanceRoot\PROJECT_TOPOLOGY.md",
    "$GovernanceRoot\TOPOLOGY_CLOSEOUT.md",
    "$GovernanceRoot\CURRENT_CURSOR.yaml",
    "$GovernanceRoot\TOPOLOGY_CURSOR.md",
    "$GovernanceRoot\QPCURSOR.md",
    "$GovernanceRoot\NORTH_STAR.md",
    "$GovernanceRoot\FULL_FEATURE_TREE.md",
    "$GovernanceRoot\LOCAL_INVARIANTS.md",
    "$GovernanceRoot\ASPECT_POLISH_CUTOVER.md"
)

$directFindings = New-Object System.Collections.Generic.List[string]
foreach ($relative in $scanFiles) {
    $path = Join-Path $projectPath $relative
    if (Test-Path -LiteralPath $path) {
        $text = Get-Content -Encoding UTF8 -LiteralPath $path -Raw
        foreach ($finding in (Find-DirectSiblingMentions -RelativePath $relative -Text $text)) {
            $directFindings.Add($finding) | Out-Null
        }
    }
}

$hasApprovedException = $false
$exceptionStatus = ""
if (Test-Path -LiteralPath $exceptionPath) {
    $exceptionText = Get-Content -Encoding UTF8 -LiteralPath $exceptionPath -Raw
    $exceptionStatus = Get-ScalarField -Text $exceptionText -Name "status"
    if ($exceptionStatus -ne "" -and $exceptionStatus -notin @("none", "proposed", "approved", "expired", "revoked")) {
        Add-Issue "RELEASE_TRANSITION_EXCEPTION.md status must be none / proposed / approved / expired / revoked"
    }

    if ($exceptionStatus -eq "approved") {
        $approvedBy = Get-ScalarField -Text $exceptionText -Name "approved_by"
        $scope = Get-ScalarField -Text $exceptionText -Name "scope"
        $performanceEvidence = Get-ScalarField -Text $exceptionText -Name "performance_evidence"
        $directEdgeAdded = Get-ScalarField -Text $exceptionText -Name "direct_edge_added"
        $rollback = Get-ScalarField -Text $exceptionText -Name "rollback"
        $expiry = Get-ScalarField -Text $exceptionText -Name "expiry"
        $reviewDate = Get-ScalarField -Text $exceptionText -Name "review_date"
        $developerApproved = Get-ScalarField -Text $exceptionText -Name "developer_approved"

        if (Test-IsInvalidApprover -Value $approvedBy) {
            Add-Issue "approved release-transition exception requires a real developer approved_by value"
        }
        if (Test-IsPlaceholder -Value $scope) {
            Add-Issue "approved release-transition exception requires scope"
        }
        if (Test-IsPlaceholder -Value $performanceEvidence) {
            Add-Issue "approved release-transition exception requires concrete performance_evidence"
        }
        if ((Test-IsPlaceholder -Value $directEdgeAdded) -or $directEdgeAdded -notmatch "->") {
            Add-Issue "approved release-transition exception requires direct_edge_added with an explicit A -> B edge"
        }
        if (Test-IsPlaceholder -Value $rollback) {
            Add-Issue "approved release-transition exception requires rollback"
        }
        if ((Test-IsPlaceholder -Value $expiry) -and (Test-IsPlaceholder -Value $reviewDate)) {
            Add-Issue "approved release-transition exception requires expiry or review_date"
        }
        if ($developerApproved.Trim().ToLowerInvariant() -ne "true") {
            Add-Issue "approved release-transition exception requires developer_approved: true"
        }

        $hasApprovedException = $issues.Count -eq 0
    }
}

if ($directFindings.Count -gt 0 -and -not $hasApprovedException) {
    Add-Issue "direct sibling edge mentioned but no approved RELEASE_TRANSITION_EXCEPTION.md with developer approval, direct edge, performance evidence, review date, and rollback"
    foreach ($finding in $directFindings) {
        Add-Issue "direct sibling finding: $finding"
    }
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
