[CmdletBinding()]
param(
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptsDirectory = Split-Path -Parent $PSScriptRoot
$repositoryRoot = Split-Path -Parent $scriptsDirectory
$requiredSources = @(
    'THE_STYLISTE_GDD_v8.md',
    'PRODUCT_POSITIONING_BIBLE.md',
    'ART_DIRECTION_BIBLE.md',
    'EMOTIONAL_EXPERIENCE_BIBLE.md',
    'AUDIO_DIRECTION_BIBLE.md',
    'NARRATIVE_STYLE_GUIDE.md',
    'COMMUNITY_TRUST_CHARTER.md',
    'NON_FEATURE_COMPLETION_GATE.md',
    'PROJECT_RULES.md',
    'VERIFICATION_PROTOCOL.md',
    'DEVELOPMENT_STATE.md',
    'BOTTLENECK_LOG.md',
    'CHANGELOG.md',
    '.env.example'
)

Write-Output 'The Styliste repository-health maintenance check'
Write-Output "Repository: $repositoryRoot"

if ($DryRun) {
    Write-Output 'Dry run: no command will mutate files, dependencies, migrations, or services.'
    Write-Output 'Would check required source-of-truth files and git whitespace.'
    Write-Output 'Would run the GDD, authority-inventory, deferred-TODO, and authority-matrix checks.'
    Write-Output 'Would validate the complete migration SHA-256 manifest.'
    Write-Output 'Would inspect dependency drift with dart pub outdated --no-dev-dependencies.'
    Write-Output 'Would compare local Supabase migration state and run database lint.'
    Write-Output 'Would scan full Git history with gitleaks using complete redaction.'
    exit 0
}

foreach ($relativePath in $requiredSources) {
    $absolutePath = Join-Path $repositoryRoot $relativePath
    if (-not (Test-Path -LiteralPath $absolutePath)) {
        throw "Missing required source of truth: $relativePath"
    }
}

& git -C $repositoryRoot diff --check
if ($LASTEXITCODE -ne 0) { throw 'git diff --check failed.' }

& (Join-Path $repositoryRoot 'scripts/check_gdd_registry.ps1')
if ($LASTEXITCODE -ne 0) { throw 'GDD registry check failed.' }
& (Join-Path $repositoryRoot 'scripts/check_authority_inventory.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Authority inventory check failed.' }
& (Join-Path $repositoryRoot 'scripts/check_migration_hash_manifest.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Migration hash manifest check failed.' }
& (Join-Path $repositoryRoot 'scripts/check_deferred_todos.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Deferred TODO check failed.' }
& (Join-Path $repositoryRoot 'scripts/check_authority_matrix.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Authority matrix check failed.' }

& dart pub outdated --no-dev-dependencies
if ($LASTEXITCODE -ne 0) { throw 'Flutter dependency audit failed.' }

& supabase migration list --local
if ($LASTEXITCODE -ne 0) { throw 'Supabase migration comparison failed.' }
& supabase db lint --local
if ($LASTEXITCODE -ne 0) { throw 'Supabase database lint failed.' }

$gitleaksCommand = Get-Command gitleaks -ErrorAction SilentlyContinue
if ($null -eq $gitleaksCommand) {
    throw 'Blocked: gitleaks is required for full-history secret verification.'
}
$gitleaksExecutable = $gitleaksCommand.Source
& $gitleaksExecutable git $repositoryRoot --redact=100 --no-banner
if ($LASTEXITCODE -ne 0) { throw 'Full-history secret scan failed.' }

Write-Output 'Passed: repository-health maintenance checks completed.'
