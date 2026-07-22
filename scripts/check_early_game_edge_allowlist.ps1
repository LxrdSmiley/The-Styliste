$ErrorActionPreference = 'Stop'

# Directive 1X requires this exact gate name. The canonical contract check owns
# the detailed assertions so the allowlist cannot drift into a second source of
# truth.
$contractCheck = Join-Path $PSScriptRoot 'check_early_game_api_contract.ps1'
if (-not (Test-Path -LiteralPath $contractCheck)) {
  throw 'The canonical Early Game API contract check is missing.'
}

& $contractCheck
if ($null -ne $LASTEXITCODE -and $LASTEXITCODE -ne 0) {
  throw "The Early Game API contract check failed with exit code $LASTEXITCODE."
}

$feedProviderPath = 'lib/features/feed/providers/feed_provider.dart'
$feedProvider = Get-Content -Raw -Encoding utf8 $feedProviderPath
if ($feedProvider -match '\.rpc\s*(?:<[^>]+>)?\s*\(' -or
    $feedProvider -match '\.from\s*\(\s*SupabaseConstants\.') {
  throw 'The active Kingston Feed provider reaches a later-wave default-schema social surface.'
}
if ($feedProvider -notmatch "\.schema\('api'\)\s*\.from\('feed_projection'\)") {
  throw 'The active Kingston Feed provider must read only the reviewed api.feed_projection relation.'
}

Write-Output 'Static pass: Early Game Edge allowlist is restricted to the six cataloged Kingston endpoints.'
