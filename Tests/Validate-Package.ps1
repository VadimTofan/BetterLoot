param(
    [Parameter(Mandatory = $true)]
    [string] $ReleaseDirectory,

    [Parameter(Mandatory = $true)]
    [string] $Version
)

$ErrorActionPreference = 'Stop'

function Get-BigEndianInt32 {
    param(
        [byte[]] $Bytes,
        [int] $Offset
    )

    return ($Bytes[$Offset] -shl 24) -bor
        ($Bytes[$Offset + 1] -shl 16) -bor
        ($Bytes[$Offset + 2] -shl 8) -bor
        $Bytes[$Offset + 3]
}

# Describe: the release archive contains the complete runtime addon and no
# development files.

# Given
$archivePath = Join-Path $ReleaseDirectory "BetterLoot-$Version.zip"
$expectedFiles = @(
    'BetterLoot/BetterLoot.toc',
    'BetterLoot/Core.lua',
    'BetterLoot/Media/BetterLoot.png',
    'BetterLoot/Position.lua',
    'BetterLoot/RollController.lua',
    'BetterLoot/RollState.lua',
    'BetterLoot/RollView.lua'
)

if (-not (Test-Path -LiteralPath $archivePath)) {
    throw "Release archive was not created: $archivePath"
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead(
    (Resolve-Path $archivePath)
)

try {
    # When
    $actualFiles = @(
        $archive.Entries |
            Where-Object { -not $_.FullName.EndsWith('/') } |
            ForEach-Object { $_.FullName.Replace('\', '/') } |
            Sort-Object
    )

    # Then
    $expectedSorted = @($expectedFiles | Sort-Object)
    $difference = Compare-Object $expectedSorted $actualFiles

    if ($difference) {
        $details = $difference | Out-String
        throw "Release archive contents differ from the allowlist:`n$details"
    }

    foreach ($entryName in $actualFiles) {
        if ($entryName.StartsWith('/') -or $entryName.Contains('../')) {
            throw "Unsafe archive path: $entryName"
        }
    }

    $iconEntry = $archive.GetEntry('BetterLoot/Media/BetterLoot.png')
    $iconStream = $iconEntry.Open()

    try {
        $header = New-Object byte[] 24
        $bytesRead = $iconStream.Read($header, 0, $header.Length)

        if ($bytesRead -ne $header.Length) {
            throw 'Packaged icon does not contain a complete PNG header'
        }

        $width = Get-BigEndianInt32 $header 16
        $height = Get-BigEndianInt32 $header 20

        if ($width -ne 32 -or $height -ne 32) {
            throw "Packaged icon must be 32x32, got ${width}x${height}"
        }
    }
    finally {
        $iconStream.Dispose()
    }
}
finally {
    $archive.Dispose()
}

Write-Output "PASS: validated $($actualFiles.Count) packaged runtime files"
