$ErrorActionPreference = 'Stop'

function Assert-Contains {
    param(
        [string] $Content,
        [string] $Expected,
        [string] $Message
    )

    if (-not $Content.Contains($Expected)) {
        throw "$Message. Missing: $Expected"
    }
}

# Describe: release configuration publishes only validated runtime files.

# Given
$toc = Get-Content -Raw 'BetterLoot.toc'
$packageMeta = Get-Content -Raw '.pkgmeta'
$workflow = Get-Content -Raw '.github/workflows/release.yml'
$gitIgnore = Get-Content -Raw '.gitignore'
$changelog = Get-Content -Raw 'CHANGELOG.md'

# When
$requiredTocValues = @(
    '## Version: v0.1.0',
    '## X-Curse-Project-ID: 1702651',
    '## IconTexture: Interface\AddOns\BetterLoot\Media\BetterLoot'
)
$requiredPackageMetaValues = @(
    'package-as: BetterLoot',
    'manual-changelog:',
    '  filename: CHANGELOG.md',
    '  markup-type: markdown',
    '  - .github',
    '  - .gitignore',
    '  - .pkgmeta',
    '  - .release',
    '  - Tests',
    '  - CHANGELOG.md',
    '  - README.md'
)
$requiredWorkflowValues = @(
    'tags: ["v*"]',
    'uses: BigWigsMods/packager@v2',
    'CF_API_TOKEN: ${{ secrets.CF_API_TOKEN }}',
    'GITHUB_API_TOKEN: ${{ secrets.GITHUB_TOKEN }}',
    'needs: validate',
    'args: -d',
    'Media/BetterLoot.png',
    'Tests/Validate-Package.ps1'
)

# Then
foreach ($value in $requiredTocValues) {
    Assert-Contains $toc $value 'TOC release metadata is incomplete'
}

foreach ($value in $requiredPackageMetaValues) {
    Assert-Contains $packageMeta $value 'Package exclusions are incomplete'
}

foreach ($value in $requiredWorkflowValues) {
    Assert-Contains $workflow $value 'Release workflow is incomplete'
}

Assert-Contains $gitIgnore '.release/' 'Local release output must be ignored'
Assert-Contains $changelog '## v0.1.0' 'Initial release notes are missing'

Write-Output 'PASS: release configuration contract'
