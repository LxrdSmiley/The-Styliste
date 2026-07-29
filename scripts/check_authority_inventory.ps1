$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$inventoryPath = Join-Path $repositoryRoot 'docs\verification\authority_inventory.json'
if (-not (Test-Path -LiteralPath $inventoryPath)) {
  throw 'Authority inventory is missing: docs/verification/authority_inventory.json'
}

$inventory = Get-Content -Raw -Encoding utf8 $inventoryPath | ConvertFrom-Json
$requiredPaths = @(
  'THE_STYLISTE_GDD_v8.md', 'PRODUCT_POSITIONING_BIBLE.md',
  'ART_DIRECTION_BIBLE.md', 'EMOTIONAL_EXPERIENCE_BIBLE.md',
  'AUDIO_DIRECTION_BIBLE.md', 'NARRATIVE_STYLE_GUIDE.md',
  'COMMUNITY_TRUST_CHARTER.md', 'NON_FEATURE_COMPLETION_GATE.md',
  'PROJECT_RULES.md', 'VERIFICATION_PROTOCOL.md'
)
$active = @($inventory.documents | Where-Object { $_.status -eq 'active' })
if ($active.Count -ne $requiredPaths.Count) {
  throw "Authority inventory must contain exactly $($requiredPaths.Count) active documents."
}

foreach ($path in $requiredPaths) {
  $entry = @($active | Where-Object { $_.path -eq $path })
  if ($entry.Count -ne 1) { throw "Authority inventory lacks exactly one active entry for $path." }
  if ([IO.Path]::IsPathRooted($entry[0].path)) { throw "Authority metadata must use a relative path: $path." }
  if ([string]::IsNullOrWhiteSpace($entry[0].purpose) -or [string]::IsNullOrWhiteSpace($entry[0].sha256)) {
    throw "Authority inventory has incomplete metadata for $path."
  }
  $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $repositoryRoot $path)).Hash.ToLowerInvariant()
  if ($actualHash -ne $entry[0].sha256.ToLowerInvariant()) { throw "Authority inventory hash drift for $path." }
}

$ranks = @($active.authority_rank | Sort-Object)
if ((@($ranks | Select-Object -Unique).Count -ne 10) -or (Compare-Object $ranks (1..10))) {
  throw 'Authority ranks must be unique and continuous from 1 through 10.'
}
$canonical = @($active | Where-Object { $_.authority_rank -eq 1 })
if ($canonical.Count -ne 1 -or $canonical[0].path -ne 'THE_STYLISTE_GDD_v8.md') {
  throw 'THE_STYLISTE_GDD_v8.md must be the sole active canonical GDD declaration.'
}

foreach ($relativePath in @('Agent.md', 'PROJECT_RULES.md', 'DEVELOPMENT_STATE.md', 'BOTTLENECK_LOG.md', 'IDE_DIRECTIVES.md', 'MANUAL_TASKS.md')) {
  $lines = Get-Content -Encoding utf8 (Join-Path $repositoryRoot $relativePath)
  $inHistoricalBlock = $false
  for ($index = 0; $index -lt $lines.Count; $index++) {
    if ($lines[$index] -match '^## .*?(?i:historical|archive|superseded)') {
      $inHistoricalBlock = $true
    }
    $nearbyHistory = (@($lines[$index..([Math]::Min($index + 4, $lines.Count - 1))]) -join ' ') -match '(?i)historical|archive|superseded'
    if (($lines[$index] -match '(?i)^\s*(?:[-*>]\s*)?(?:canonical\s+(?:product\s+)?authority|authority)\s*[:—-].*(GDD v7|GDD_v7|THE_STYLISTE_GDD_v7)') -and
        -not $inHistoricalBlock -and -not $nearbyHistory -and
        ($lines[$index] -notmatch '(?i)historical|archive|superseded')) {
      throw "$relativePath line $($index + 1) names v7 without an explicit historical label."
    }
  }
}

& (Join-Path $PSScriptRoot 'check_gdd_registry.ps1')

Write-Output 'Static Pass: active authority inventory, hashes, ranks, and canonical GDD declaration are current.'
