[CmdletBinding()]
param(
    [string]$MigrationDirectory = (Join-Path (Split-Path -Parent $PSScriptRoot) 'supabase\migrations'),
    [string]$ManifestPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'docs\verification\aurelian_ui_redesign\migration_hash_manifest.csv')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $MigrationDirectory -PathType Container)) {
    throw "Migration directory does not exist: $MigrationDirectory"
}
if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
    throw "Migration hash manifest does not exist: $ManifestPath"
}

$files = @(
    Get-ChildItem -LiteralPath $MigrationDirectory -File -Filter '*.sql' |
        Sort-Object -Property Name
)
if ($files.Count -eq 0) {
    throw "No SQL migration files were found in $MigrationDirectory"
}

$expected = foreach ($file in $files) {
    if ($file.Name -notmatch '^(?<prefix>\d{3}|\d{14})_(?<name>[a-z0-9_]+)\.sql$') {
        throw "Migration filename does not follow the approved legacy-sequence or timestamp convention: $($file.Name)"
    }

    [pscustomobject]@{
        Prefix = $Matches.prefix
        Path = "supabase/migrations/$($file.Name)"
        SHA256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash.ToUpperInvariant()
    }
}

$prefixDuplicates = @($expected | Group-Object -Property Prefix | Where-Object Count -gt 1)
if ($prefixDuplicates.Count -gt 0) {
    throw "Duplicate migration prefix(es): $($prefixDuplicates.Name -join ', ')"
}

$rawManifest = Get-Content -Raw -LiteralPath $ManifestPath
$rows = @($rawManifest | ConvertFrom-Csv)
if ($rows.Count -eq 0) {
    throw 'Migration hash manifest is empty.'
}

$headers = @($rows[0].PSObject.Properties.Name)
if ($headers.Count -ne 2 -or $headers[0] -ne 'Path' -or $headers[1] -ne 'SHA256') {
    throw 'Migration hash manifest must contain exactly the Path,SHA256 columns in that order.'
}

$manifest = foreach ($row in $rows) {
    $path = [string]$row.Path
    $hash = [string]$row.SHA256
    if ($path -notmatch '^supabase/migrations/(?:\d{3}|\d{14})_[a-z0-9_]+\.sql$') {
        throw "Migration hash manifest contains a non-normalized path: $path"
    }
    if ($hash -notmatch '^[A-Fa-f0-9]{64}$') {
        throw "Migration hash manifest contains an invalid SHA-256 digest for $path"
    }
    [pscustomobject]@{
        Path = $path
        SHA256 = $hash.ToUpperInvariant()
    }
}

$manifestDuplicates = @($manifest | Group-Object -Property Path | Where-Object Count -gt 1)
if ($manifestDuplicates.Count -gt 0) {
    throw "Migration hash manifest contains duplicate path(s): $($manifestDuplicates.Name -join ', ')"
}

if ($manifest.Count -ne $expected.Count) {
    throw "Migration hash manifest coverage mismatch: manifest=$($manifest.Count), migrations=$($expected.Count)."
}

for ($index = 0; $index -lt $expected.Count; $index++) {
    $expectedEntry = $expected[$index]
    $manifestEntry = $manifest[$index]
    if ($manifestEntry.Path -ne $expectedEntry.Path) {
        throw "Migration hash manifest ordering or path mismatch at index ${index}: expected $($expectedEntry.Path), found $($manifestEntry.Path)."
    }
    if ($manifestEntry.SHA256 -ne $expectedEntry.SHA256) {
        throw "Migration hash mismatch for $($expectedEntry.Path)."
    }
}

Write-Output "Passed: migration hash manifest covers $($expected.Count) exact migration files with raw-byte SHA-256 digests."
