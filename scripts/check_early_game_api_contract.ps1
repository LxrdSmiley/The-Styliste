$ErrorActionPreference = 'Stop'

$catalogPath = 'supabase/tests/authority_contract_matrix.json'
$configPath = 'supabase/config.toml'
$migrationPath = 'supabase/migrations/20260722151802_kingston_early_game_api_contract.sql'
$correctionPath = 'supabase/migrations/20260722190000_gdd_v7_kingston_authority_corrections.sql'
$catalog = Get-Content -Raw -Encoding utf8 $catalogPath | ConvertFrom-Json
$config = Get-Content -Raw -Encoding utf8 $configPath
$migration = Get-Content -Raw -Encoding utf8 $migrationPath
$correction = Get-Content -Raw -Encoding utf8 $correctionPath
$routes = Get-Content -Raw -Encoding utf8 'supabase/functions/_shared/kingston_routes.ts'
$gdd = Get-Content -Raw -Encoding utf8 'THE_STYLISTE_GDD_v7.md'

if ($config -notmatch '(?m)^schemas = \["api"\]$' -or
    $config -match '(?m)^schemas\s*=.*"public"') {
  throw 'Only the api schema may be exposed through the gameplay Data API.'
}
if ($config -notmatch '(?ms)^\[realtime\]\s*enabled = false' -or
    $config -notmatch '(?ms)^\[storage\]\s*enabled = false') {
  throw 'Realtime and Storage must remain disabled for Directive 1.'
}

$sections = [regex]::Matches(
  $config,
  '(?ms)^\[functions\.([^\]]+)\]\s*(.*?)(?=^\[|\z)'
)
$functionState = @{}
foreach ($section in $sections) {
  $name = $section.Groups[1].Value
  $body = $section.Groups[2].Value
  $functionState[$name] = [pscustomobject]@{
    Enabled = $body -match '(?m)^enabled\s*=\s*true\s*$'
    VerifyJwt = $body -match '(?m)^verify_jwt\s*=\s*true\s*$'
  }
}

$enabledCatalog = @($catalog.enabled_endpoints)
$enabledNames = @($enabledCatalog.endpoint) | Sort-Object
$enabledConfig = @($functionState.Keys | Where-Object { $functionState[$_].Enabled }) |
  Sort-Object
if (Compare-Object $enabledNames $enabledConfig) {
  throw 'Enabled config surface differs from the six cataloged Kingston endpoints.'
}
if ($enabledNames.Count -ne 6) { throw 'Exactly six Kingston endpoints must be enabled.' }

$requiredFields = @(
  'endpoint', 'feature_id', 'implementation_wave', 'auth_mode',
  'verified_actor_source', 'api_wrapper', 'read_projections',
  'tables_affected', 'economic_mutation', 'idempotency_requirement',
  'owner_test', 'stranger_test', 'anonymous_test', 'replay_test',
  'concurrency_test', 'disable_switch', 'owner'
)
foreach ($entry in $enabledCatalog) {
  foreach ($field in $requiredFields) {
    if ($entry.PSObject.Properties.Name -notcontains $field -or
        $null -eq $entry.$field -or
        ($entry.$field -is [string] -and [string]::IsNullOrWhiteSpace($entry.$field))) {
      throw "$($entry.endpoint) lacks required catalog field $field."
    }
  }
  if (-not $functionState[$entry.endpoint].VerifyJwt) {
    throw "$($entry.endpoint) must set verify_jwt=true."
  }
  $wrapperName = ($entry.api_wrapper -split '\.')[-1]
  if ($migration -notmatch "(?i)CREATE OR REPLACE FUNCTION\s+api\.$([regex]::Escape($wrapperName))\s*\(") {
    throw "Cataloged wrapper $($entry.api_wrapper) does not exist in the forward migration."
  }
  if ($gdd -notmatch [regex]::Escape($entry.feature_id)) {
    throw "Cataloged Feature ID $($entry.feature_id) is absent from the GDD."
  }
  $indexPath = "supabase/functions/$($entry.endpoint)/index.ts"
  if (-not (Test-Path -LiteralPath $indexPath)) {
    throw "Enabled endpoint $($entry.endpoint) lacks an entrypoint."
  }
  $source = Get-Content -Raw -Encoding utf8 $indexPath
  if ($source -notmatch 'handleKingstonRequest') {
    throw "$($entry.endpoint) bypasses the shared identity boundary."
  }
  if ($source -match '(?m)\b(admin|service)\.rpc\s*\(') {
    throw "$($entry.endpoint) calls a default-schema privileged RPC."
  }
  if ($entry.economic_mutation -eq $true) {
    if ($entry.replay_test -notmatch '\.(sql|ps1):' -or
        $entry.concurrency_test -notmatch 'kingston_economic_concurrency\.ps1') {
      throw "$($entry.endpoint) lacks named replay or concurrency evidence."
    }
  }
}

foreach ($entry in @($catalog.disabled_endpoints)) {
  if (-not $functionState.ContainsKey($entry.endpoint) -or
      $functionState[$entry.endpoint].Enabled) {
    throw "Later-wave endpoint $($entry.endpoint) is not disabled."
  }
}

$activeFlutterFiles = @(
  'lib/features/onboarding/providers/sovereign_genesis_provider.dart',
  'lib/features/atelier/providers/mint_design_provider.dart',
  'lib/features/atelier/providers/drop_design_provider.dart',
  'lib/features/ledger/providers/ledger_provider.dart',
  'lib/core/services/idle_engine_service.dart',
  'lib/features/ftue/repositories/first_objective_repository.dart',
  'lib/features/reporting/widgets/report_modal.dart'
)
foreach ($path in $activeFlutterFiles) {
  $source = Get-Content -Raw -Encoding utf8 $path
  if ($source -match '[''"](?:p_user_id|player_id|owner_id)[''"]\s*:') {
    throw "Flutter mutation source $path still submits an authoritative actor identifier."
  }
  if ($source -match '\.rpc\s*\(') {
    throw "Flutter Early Game source $path still invokes a default-schema RPC."
  }
}

if ($migration -match '(?is)GRANT\s+EXECUTE\s+ON\s+FUNCTION\s+api\..*?\s+TO\s+(?:anon|authenticated)') {
  throw 'A server-only api wrapper is executable by a client role.'
}
if ($migration -notmatch 'IDEMPOTENCY_KEY_CONFLICT' -or
    $migration -notmatch 'pg_advisory_xact_lock' -or
    $migration -notmatch 'kingston_operation_receipts') {
  throw 'The migration lacks replay conflict, locking, or append-only receipt controls.'
}

if ($routes -match 'market_tier|avatar_config' -or
    $routes -notmatch 'vex_opt_in') {
  throw 'The active Edge contract retains obsolete Founder authority or omits Vex consent.'
}
foreach ($required in @(
  'house_funds', 'lifetime_gross_revenue', 'lifetime_costs',
  'lifetime_net_result', 'idle_base_revenue_per_hour',
  'idle_store_revenue_per_hour', 'idle_automation_revenue_per_hour',
  'kingston_starter_design_catalog', 'release_design_v2',
  'FOUNDER_TRIAL_ADVANCE_NOT_AVAILABLE'
)) {
  if ($correction -notmatch [regex]::Escape($required)) {
    throw "The forward correction is missing required Kingston authority marker $required."
  }
}
if ($correction -match 'v_zone_count\s*\*|v_material_count\s*\*|v_palette_count\s*\*|v_construction_count\s*\*') {
  throw 'The final Kingston design settlement contains count-based scoring.'
}

Write-Output 'Static pass: Kingston allowlist, actor boundary, wrappers, catalog, grants, replay controls, and disable switches agree.'
