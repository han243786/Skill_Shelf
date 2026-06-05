[CmdletBinding()]
param(
    [string]$Root = "D:\Skill_Shelf",
    [switch]$Strict
)

$ErrorActionPreference = "Stop"

function New-Issue {
    param(
        [Parameter(Mandatory = $true)][ValidateSet("ERROR", "WARN")][string]$Severity,
        [Parameter(Mandatory = $true)][string]$Message
    )

    [pscustomobject]@{
        Severity = $Severity
        Message = $Message
    }
}

function Add-Issue {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[object]]$Issues,
        [Parameter(Mandatory = $true)][ValidateSet("ERROR", "WARN")][string]$Severity,
        [Parameter(Mandatory = $true)][string]$Message
    )

    $Issues.Add((New-Issue -Severity $Severity -Message $Message)) | Out-Null
}

function Read-Text {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Get-Content -Encoding UTF8 -LiteralPath $Path -Raw
}

function Get-SkillFrontmatter {
    param([Parameter(Mandatory = $true)][string]$SkillPath)

    $text = Read-Text -Path $SkillPath
    if ($text -notmatch "(?s)^---\s*\r?\n(?<body>.*?)\r?\n---") {
        return $null
    }

    $frontmatter = $Matches.body
    $name = $null
    $description = $null

    if ($frontmatter -match "(?m)^name:\s*(?<name>[A-Za-z0-9_-]+)\s*$") {
        $name = $Matches.name
    }

    if ($frontmatter -match "(?m)^description:\s*(?<description>.+?)\s*$") {
        $description = $Matches.description.Trim()
    }

    return [pscustomobject]@{
        Name = $name
        Description = $description
        Raw = $frontmatter
    }
}

function Test-PowerShellSyntax {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[object]]$Issues
    )

    $tokens = $null
    $parseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$parseErrors) | Out-Null
    foreach ($parseError in $parseErrors) {
        Add-Issue -Issues $Issues -Severity "ERROR" -Message "PowerShell syntax error in ${Path}: $($parseError.Message)"
    }
}

function Test-ScriptConservatism {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[object]]$Issues
    )

    $text = Read-Text -Path $Path
    $relative = $Path
    $dangerousPatterns = @(
        "Remove-Item",
        "Move-Item",
        "Format-Volume",
        "Clear-Content",
        "Set-ExecutionPolicy",
        "Invoke-Expression",
        "iex ",
        "rm -r",
        "del /s"
    )

    foreach ($pattern in $dangerousPatterns) {
        if ($text -match [regex]::Escape($pattern)) {
            Add-Issue -Issues $Issues -Severity "WARN" -Message "Review potentially destructive or dynamic command '$pattern' in script: $relative"
        }
    }

    if ($text -match "Copy-Item" -and $text -notmatch '-Force:\$Force|-Force\s*\$Force') {
        Add-Issue -Issues $Issues -Severity "WARN" -Message "Copy-Item appears without Force gate in script: $relative"
    }
}

function Test-NonEmptyMarkdown {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[object]]$Issues
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        Add-Issue -Issues $Issues -Severity "ERROR" -Message "Missing file: $Path"
        return
    }

    $item = Get-Item -LiteralPath $Path
    if ($item.Length -le 0) {
        Add-Issue -Issues $Issues -Severity "ERROR" -Message "Empty markdown file: $Path"
        return
    }

    $text = Read-Text -Path $Path
    if ($text -notmatch "^\s*(#|---)") {
        Add-Issue -Issues $Issues -Severity "WARN" -Message "Markdown file does not start with a heading: $Path"
    }
}

if (-not (Test-Path -LiteralPath $Root)) {
    throw "Skill shelf root not found: $Root"
}

$rootPath = (Resolve-Path -LiteralPath $Root).ProviderPath
$issues = New-Object System.Collections.Generic.List[object]

$topReadme = Join-Path $rootPath "README.md"
$standardMd = Join-Path $rootPath "SKILL_SHELF_STANDARD.md"
$standardPs = Join-Path $rootPath "SKILL_SHELF_STANDARD.ps1"
$legacyManagement = Join-Path $rootPath "MANAGEMENT.md"

$requiredTopFiles = @($topReadme, $standardMd, $standardPs)
foreach ($required in $requiredTopFiles) {
    if (-not (Test-Path -LiteralPath $required)) {
        Add-Issue -Issues $issues -Severity "ERROR" -Message "Missing required top-level file: $required"
    }
}

if (Test-Path -LiteralPath $legacyManagement) {
    Add-Issue -Issues $issues -Severity "ERROR" -Message "Legacy top-level MANAGEMENT.md should not exist after consolidation"
}

if (Test-Path -LiteralPath $topReadme) {
    Test-NonEmptyMarkdown -Path $topReadme -Issues $issues
}

if (Test-Path -LiteralPath $standardMd) {
    Test-NonEmptyMarkdown -Path $standardMd -Issues $issues
}

if (Test-Path -LiteralPath $standardPs) {
    Test-PowerShellSyntax -Path $standardPs -Issues $issues
}

$allowedTopFiles = @(
    ".gitignore",
    "README.md",
    "SKILL_SHELF_STANDARD.md",
    "SKILL_SHELF_STANDARD.ps1"
)

Get-ChildItem -LiteralPath $rootPath -File -Force | ForEach-Object {
    if ($allowedTopFiles -notcontains $_.Name) {
        Add-Issue -Issues $issues -Severity "ERROR" -Message "Unexpected top-level file: $($_.FullName)"
    }
}

$packageDirs = Get-ChildItem -LiteralPath $rootPath -Directory -Force |
    Where-Object { $_.Name -notmatch "^\." } |
    Sort-Object Name

if ($packageDirs.Count -eq 0) {
    Add-Issue -Issues $issues -Severity "ERROR" -Message "No package directories found under $rootPath"
}

if (Test-Path -LiteralPath $topReadme) {
    $readmeText = Read-Text -Path $topReadme
    if ($readmeText -notmatch "SKILL_SHELF_STANDARD\.md") {
        Add-Issue -Issues $issues -Severity "ERROR" -Message "Top README does not link SKILL_SHELF_STANDARD.md"
    }
    if ($readmeText -notmatch "SKILL_SHELF_STANDARD\.ps1") {
        Add-Issue -Issues $issues -Severity "ERROR" -Message "Top README does not link SKILL_SHELF_STANDARD.ps1"
    }

    $linkedPackages = New-Object System.Collections.Generic.HashSet[string]
    $linkMatches = [regex]::Matches($readmeText, "\]\(\./(?<pkg>[^/]+)/README\.md\)")
    foreach ($match in $linkMatches) {
        $linkedPackages.Add($match.Groups["pkg"].Value) | Out-Null
    }

    foreach ($dir in $packageDirs) {
        if (-not $linkedPackages.Contains($dir.Name)) {
            Add-Issue -Issues $issues -Severity "ERROR" -Message "Top README does not link package README: $($dir.Name)"
        }
        if ($readmeText -notmatch [regex]::Escape($dir.Name)) {
            Add-Issue -Issues $issues -Severity "ERROR" -Message "Top README does not mention package: $($dir.Name)"
        }
    }

    foreach ($linkedPackage in $linkedPackages) {
        $actualPath = Join-Path $rootPath $linkedPackage
        if (-not (Test-Path -LiteralPath $actualPath)) {
            Add-Issue -Issues $issues -Severity "ERROR" -Message "Top README links missing package: $linkedPackage"
        }
    }
}

$allowedPackageDirs = @("references", "templates", "scripts", "agents", "assets")

foreach ($dir in $packageDirs) {
    $name = $dir.Name

    if ($name -notmatch "^[a-z0-9]+(-[a-z0-9]+)*$") {
        Add-Issue -Issues $issues -Severity "ERROR" -Message "Package name is not lowercase kebab-case: $name"
    }

    $packageReadme = Join-Path $dir.FullName "README.md"
    $skillMd = Join-Path $dir.FullName "SKILL.md"

    Test-NonEmptyMarkdown -Path $packageReadme -Issues $issues
    Test-NonEmptyMarkdown -Path $skillMd -Issues $issues

    if (Test-Path -LiteralPath $skillMd) {
        $skillText = Read-Text -Path $skillMd
        $frontmatter = Get-SkillFrontmatter -SkillPath $skillMd

        if ($null -ne $frontmatter) {
            if ([string]::IsNullOrWhiteSpace($frontmatter.Name)) {
                Add-Issue -Issues $issues -Severity "ERROR" -Message "SKILL.md frontmatter missing name: $name"
            } elseif ($frontmatter.Name -ne $name) {
                Add-Issue -Issues $issues -Severity "ERROR" -Message "SKILL.md name '$($frontmatter.Name)' does not match folder '$name'"
            }

            if ([string]::IsNullOrWhiteSpace($frontmatter.Description)) {
                Add-Issue -Issues $issues -Severity "ERROR" -Message "SKILL.md frontmatter missing description: $name"
            }
        } elseif ($skillText -notmatch "^\s*#") {
            Add-Issue -Issues $issues -Severity "ERROR" -Message "SKILL.md has neither YAML frontmatter nor markdown heading: $name"
        }
    }

    Get-ChildItem -LiteralPath $dir.FullName -Directory -Force | ForEach-Object {
        if ($allowedPackageDirs -notcontains $_.Name) {
            Add-Issue -Issues $issues -Severity "WARN" -Message "Unexpected package subdirectory '$($_.Name)' in $name"
        }
    }

    $activeScriptsDir = Join-Path $dir.FullName "scripts"
    if (Test-Path -LiteralPath $activeScriptsDir) {
        Get-ChildItem -LiteralPath $activeScriptsDir -Recurse -File -Filter "*.ps1" | ForEach-Object {
            Test-PowerShellSyntax -Path $_.FullName -Issues $issues
            Test-ScriptConservatism -Path $_.FullName -Issues $issues
        }
    }

    if ($Strict -and (Test-Path -LiteralPath $packageReadme)) {
        $packageReadmeText = Read-Text -Path $packageReadme
        if ($packageReadmeText -notmatch "##\s+") {
            Add-Issue -Issues $issues -Severity "WARN" -Message "README may be too thin or missing second-level sections: $name"
        }
    }
}

$allFiles = Get-ChildItem -LiteralPath $rootPath -Recurse -File -Force
$forbiddenPatterns = @(
    ('large-scale-' + 'modular-refactor'),
    ('Large Scale ' + 'Modular Refactor'),
    ('Large-Scale ' + 'Modular Refactor'),
    ('large-scale ' + 'modular refactor'),
    ('large scale ' + 'modular refactor'),
    '\u5927\u89c4\u6a21\u4ee3\u7801\u6a21\u5757\u5316\u91cd\u6784',
    '\u5927\u89c4\u6a21\u91cd\u6784'
)

$textExtensions = @()
$textExtensions += '.md'
$textExtensions += '.ps1'
$textExtensions += '.txt'
$textExtensions += '.json'
$textExtensions += '.yaml'
$textExtensions += '.yml'
$textExtensions += '.toml'
$textExtensions += '.js'
$textExtensions += '.ts'
$textExtensions += '.rs'
$textExtensions += '.bat'

foreach ($file in $allFiles) {
    $extension = [System.IO.Path]::GetExtension($file.FullName)
    if ($textExtensions -notcontains $extension -and $file.Name -ne 'pre-commit-sample') {
        continue
    }

    $text = Read-Text -Path $file.FullName
    foreach ($pattern in $forbiddenPatterns) {
        if ($text -match $pattern) {
            Add-Issue -Issues $issues -Severity 'ERROR' -Message "Forbidden stale pattern '$pattern' found in $($file.FullName)"
        }
    }
}

if ($issues.Count -eq 0) {
    Write-Host "Skill Shelf standard check OK: $rootPath"
    exit 0
}

Write-Host "Skill Shelf standard check found $($issues.Count) issue(s):"
foreach ($issue in $issues) {
    Write-Host "[$($issue.Severity)] $($issue.Message)"
}

if (($issues | Where-Object { $_.Severity -eq "ERROR" }).Count -gt 0) {
    exit 1
}

exit 0
