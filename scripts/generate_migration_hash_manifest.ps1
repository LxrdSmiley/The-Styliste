[CmdletBinding()]
param(
    [string]$MigrationDirectory = (Join-Path (Split-Path -Parent $PSScriptRoot) 'supabase\migrations'),
    [string]$OutputPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'docs\verification\aurelian_ui_redesign\migration_hash_manifest.csv'),
    [switch]$Write
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-MigrationRecords {
    param([Parameter(Mandatory)][string]$Directory)

    if (-not (Test-Path -LiteralPath $Directory -PathType Container)) {
        throw "Migration directory does not exist: $Directory"
    }

    $files = @(
        Get-ChildItem -LiteralPath $Directory -File -Filter '*.sql' |
            Sort-Object -Property Name
    )
    if ($files.Count -eq 0) {
        throw "No SQL migration files were found in $Directory"
    }

    $records = foreach ($file in $files) {
        if ($file.Name -notmatch '^(?<prefix>\d{3}|\d{14})_(?<name>[a-z0-9_]+)\.sql$') {
            throw "Migration filename does not follow the approved legacy-sequence or timestamp convention: $($file.Name)"
        }

        [pscustomobject]@{
            Prefix = $Matches.prefix
            Path = "supabase/migrations/$($file.Name)"
            SHA256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash.ToUpperInvariant()
        }
    }

    $duplicates = @($records | Group-Object -Property Prefix | Where-Object Count -gt 1)
    if ($duplicates.Count -gt 0) {
        throw "Duplicate migration prefix(es): $($duplicates.Name -join ', ')"
    }

    return @($records)
}

$records = Get-MigrationRecords -Directory $MigrationDirectory
$lines = @('"Path","SHA256"')
$lines += $records | ForEach-Object { '"{0}","{1}"' -f $_.Path, $_.SHA256 }
$content = ($lines -join "`n") + "`n"

if (-not $Write) {
    Write-Output 'Dry run: generated deterministic migration manifest content; no file was written.'
    Write-Output "Entries=$($records.Count)"
    Write-Output $content
    exit 0
}

$parent = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
    throw "Manifest parent directory does not exist: $parent"
}

[System.IO.File]::WriteAllText(
    $OutputPath,
    $content,
    [System.Text.UTF8Encoding]::new($false)
)

Write-Output "Wrote deterministic SHA-256 manifest with $($records.Count) entries: $OutputPath"
