[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [string]$DocsRoot = "markdown"
)

$ErrorActionPreference = "Stop"

$resolvedProject = Resolve-Path -LiteralPath $ProjectRoot
$projectPath = $resolvedProject.ProviderPath

$required = @(
    "$DocsRoot\00-matrix-governance\README.md",
    "$DocsRoot\00-matrix-governance\process-matrix.md",
    "$DocsRoot\00-matrix-governance\standard-matrix.md",
    "$DocsRoot\00-matrix-governance\guidance-matrix.md",
    "$DocsRoot\00-matrix-governance\module-tree.md",
    "$DocsRoot\General_Policy.md",
    "$DocsRoot\01-principles\principles-super-standardization.md",
    "$DocsRoot\10-overview\overview-full-feature-tree.md"
)

$missing = New-Object System.Collections.Generic.List[string]

foreach ($relative in $required) {
    $path = Join-Path $projectPath $relative
    if (-not (Test-Path -LiteralPath $path)) {
        $missing.Add($relative) | Out-Null
    }
}

if ($missing.Count -gt 0) {
    Write-Host "Governance scaffold is incomplete:"
    foreach ($item in $missing) {
        Write-Host "  missing: $item"
    }
    exit 1
}

Write-Host "Governance scaffold OK: $projectPath"
exit 0
