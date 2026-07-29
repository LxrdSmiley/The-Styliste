<#
  Twenty independent local sessions per Kingston economic mutation.
  Requires an already-reset, unlinked local Supabase stack.
#>
$ErrorActionPreference = 'Stop'

$designerId = '00000000-0000-4000-8000-00000000c201'
$mogulId = '00000000-0000-4000-8000-00000000c202'
$databaseContainer = @(
  & docker ps --filter 'name=supabase_db_' --format '{{.Names}}' |
    Select-Object -First 1
).Trim()

if ([string]::IsNullOrWhiteSpace($databaseContainer)) {
  throw 'No local Supabase database container is running.'
}

function Invoke-LocalQuery {
  param([Parameter(Mandatory)][string]$Sql)
  $oldPreference = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  $encodedSql = [Convert]::ToBase64String(
    [Text.UTF8Encoding]::new($false).GetBytes($Sql)
  )
  $containerCommand = "echo '$encodedSql' | base64 -d | psql -X -v ON_ERROR_STOP=1 -qAt -U postgres -d postgres"
  $output = & docker exec $databaseContainer sh -c $containerCommand 2>&1
  $exitCode = $LASTEXITCODE
  $ErrorActionPreference = $oldPreference
  if ($exitCode -ne 0) { throw "Local query failed: $($output | Out-String)" }
  return $output | Out-String
}

function Invoke-TwentySessionReplay {
  param(
    [Parameter(Mandatory)][string]$Mutation,
    [Parameter(Mandatory)][string]$Sql
  )
  $oldPreference = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  $encodedSql = [Convert]::ToBase64String(
    [Text.UTF8Encoding]::new($false).GetBytes($Sql)
  )
  $containerCommand = "echo '$encodedSql' | base64 -d | pgbench -n -U postgres -d postgres -c 20 -j 20 -t 1 -f -"
  $output = & docker exec $databaseContainer sh -c $containerCommand 2>&1
  $exitCode = $LASTEXITCODE
  $ErrorActionPreference = $oldPreference
  $summary = $output | Out-String
  if ($exitCode -ne 0 -or
      $summary -notmatch 'number of transactions actually processed:\s*20/20' -or
      $summary -notmatch 'number of failed transactions:\s*0') {
    throw "$Mutation did not complete 20 independent sessions: $summary"
  }
  Write-Output "Passed: $Mutation completed 20 sessions without a failed transaction or deadlock."
}

function Assert-DeterministicConflict {
  param(
    [Parameter(Mandatory)][string]$Mutation,
    [Parameter(Mandatory)][string]$Sql,
    [Parameter(Mandatory)][string]$Expected
  )
  $oldPreference = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  $encodedSql = [Convert]::ToBase64String(
    [Text.UTF8Encoding]::new($false).GetBytes($Sql)
  )
  $containerCommand = "echo '$encodedSql' | base64 -d | psql -X -v ON_ERROR_STOP=1 -qAt -U postgres -d postgres"
  $output = & docker exec $databaseContainer sh -c $containerCommand 2>&1
  $exitCode = $LASTEXITCODE
  $ErrorActionPreference = $oldPreference
  if ($exitCode -eq 0 -or ($output | Out-String) -notmatch $Expected) {
    throw "$Mutation conflicting replay was not rejected as $Expected."
  }
}

$servicePrefix = @"
SET ROLE service_role;
SELECT set_config('request.jwt.claim.role', 'service_role', false);
"@

$founderKey = '00000000-0000-4000-8000-00000000f101'
$designKey = '00000000-0000-4000-8000-00000000f102'
$storeKey = '00000000-0000-4000-8000-00000000f103'
$idleKey = '00000000-0000-4000-8000-00000000f104'
$designId = '00000000-0000-4000-8000-00000000d201'

try {
  $fixtureCount = Invoke-LocalQuery @"
SELECT count(*)
FROM public.players
WHERE id IN ('$designerId', '$mogulId');
"@
  if ($fixtureCount.Trim() -ne '0') {
    throw 'Concurrency fixture IDs already exist. Reset the disposable local database before rerunning.'
  }

  $founderSql = $servicePrefix + @"
SELECT api.server_founder_trial_intent_v1(
  '$designerId', true, '$founderKey',
  '{"action":"initialize","brand_name":"Concurrent Designer"}'::jsonb,
  'kingston-founder-trial.v1'
);
"@
  Invoke-TwentySessionReplay -Mutation 'founder_trial' -Sql $founderSql
  Assert-DeterministicConflict -Mutation 'founder_trial' -Expected 'IDEMPOTENCY_KEY_CONFLICT' -Sql ($servicePrefix + @"
SELECT api.server_founder_trial_intent_v1(
  '$designerId', true, '$founderKey',
  '{"action":"initialize","brand_name":"Conflicting Designer"}'::jsonb,
  'kingston-founder-trial.v1'
);
"@)

  Invoke-LocalQuery @"
INSERT INTO public.designs(id, player_id, name, session_type, status)
VALUES ('$designId', '$designerId', 'Concurrent Alpha', 'quick_sketch', 'complete');
INSERT INTO public.atelier_sessions(
  id, player_id, fabric_color_hex, style_tags, minted_at, design_id
) VALUES (
  '00000000-0000-4000-8000-00000000e201', '$designerId', 'FAF7F0',
  ARRAY['minimalist']::TEXT[], clock_timestamp(), '$designId'
);
"@ | Out-Null
  $blueprint = '{"version":1,"garment_category":"starter_garment","editable_zones":["bodice"],"materials":["minimalist"],"palette":["FAF7F0"],"construction_choices":["straight_seam"],"revision_lineage":[]}'
  $designSql = $servicePrefix + @"
SELECT api.server_design_intent_v1(
  '$designerId', '$designKey',
  jsonb_build_object('action','release','design_id','$designId','release_intent','publish_first_drop','blueprint','$blueprint'::jsonb,'vex_opt_in',true),
  'kingston-design-intent.v1'
);
"@
  Invoke-TwentySessionReplay -Mutation 'design_release' -Sql $designSql
  Assert-DeterministicConflict -Mutation 'design_release' -Expected 'IDEMPOTENCY_KEY_CONFLICT' -Sql ($servicePrefix + @"
SELECT api.server_design_intent_v1(
  '$designerId', '$designKey',
  jsonb_build_object('action','release','design_id','$designId','release_intent','publish_first_drop','blueprint',jsonb_set('$blueprint'::jsonb,'{palette}','["FFFFFF"]'::jsonb),'vex_opt_in',true),
  'kingston-design-intent.v1'
);
"@)

  Invoke-LocalQuery ($servicePrefix + @"
SELECT api.server_founder_trial_intent_v1(
  '$mogulId', false, '00000000-0000-4000-8000-00000000f105',
  '{"action":"initialize","brand_name":"Concurrent Mogul"}'::jsonb,
  'kingston-founder-trial.v1'
);
SELECT api.server_founder_trial_intent_v1(
  '$mogulId', false, '00000000-0000-4000-8000-00000000f106',
  '{"action":"advance","next_stage":"complete_artisan_sample","artisan_choice":"draped_bodice"}'::jsonb,
  'kingston-founder-trial.v1'
);
SELECT api.server_founder_trial_intent_v1(
  '$mogulId', false, '00000000-0000-4000-8000-00000000f107',
  '{"action":"advance","next_stage":"complete_architect_sample","architect_choice":"limited_run"}'::jsonb,
  'kingston-founder-trial.v1'
);
SELECT api.server_founder_trial_intent_v1(
  '$mogulId', false, '00000000-0000-4000-8000-00000000f108',
  '{"action":"advance","next_stage":"reveal_shared_result"}'::jsonb,
  'kingston-founder-trial.v1'
);
SELECT api.server_founder_trial_intent_v1(
  '$mogulId', false, '00000000-0000-4000-8000-00000000f109',
  '{"action":"advance","next_stage":"choose_revision_or_business_response","response_choice":"adjust_run_plan"}'::jsonb,
  'kingston-founder-trial.v1'
);
SELECT api.server_founder_trial_intent_v1(
  '$mogulId', false, '00000000-0000-4000-8000-00000000f10a',
  '{"action":"advance","next_stage":"select_founder_path","specialization":"architect"}'::jsonb,
  'kingston-founder-trial.v1'
);
"@) | Out-Null
  $storeSql = $servicePrefix + @"
SELECT api.server_open_first_store_v1(
  '$mogulId', '$storeKey',
  '{"store_type":"flagship","price_tier":"signature","inventory_capacity":24}'::jsonb,
  'kingston-first-store.v1'
);
"@
  Invoke-TwentySessionReplay -Mutation 'first_store' -Sql $storeSql
  Assert-DeterministicConflict -Mutation 'first_store' -Expected 'IDEMPOTENCY_KEY_CONFLICT' -Sql ($servicePrefix + @"
SELECT api.server_open_first_store_v1(
  '$mogulId', '$storeKey',
  '{"store_type":"flagship","price_tier":"signature","inventory_capacity":25}'::jsonb,
  'kingston-first-store.v1'
);
"@)

  Invoke-LocalQuery "UPDATE public.brand_state SET last_active_at = clock_timestamp() - interval '1 hour' WHERE player_id = '$designerId';" | Out-Null
  $idleSql = $servicePrefix + @"
SELECT api.server_settle_idle_income_v1(
  '$designerId', '$idleKey', '{}'::jsonb, 'kingston-idle-settlement.v1'
);
"@
  Invoke-TwentySessionReplay -Mutation 'idle_settlement' -Sql $idleSql
  Assert-DeterministicConflict -Mutation 'idle_settlement' -Expected 'IDLE_PAYLOAD_MUST_BE_EMPTY' -Sql ($servicePrefix + @"
SELECT api.server_settle_idle_income_v1(
  '$designerId', '$idleKey', '{"elapsed_seconds":999999}'::jsonb,
  'kingston-idle-settlement.v1'
);
"@)

  $state = Invoke-LocalQuery @"
SELECT jsonb_build_object(
  'founder_receipt_once', (SELECT count(*) FROM ledger.kingston_operation_receipts WHERE player_id = '$designerId' AND operation = 'founder_trial' AND idempotency_key = '$founderKey') = 1,
  'founder_ledger_once', (SELECT count(*) FROM ledger.economy_ledger WHERE player_id = '$designerId' AND entry_type = 'founder_house_funds' AND idempotency_key = '$founderKey') = 1,
  'design_receipt_once', (SELECT count(*) FROM ledger.kingston_operation_receipts WHERE player_id = '$designerId' AND operation = 'design_intent' AND idempotency_key = '$designKey') = 1,
  'design_ledger_once', (SELECT count(*) FROM ledger.economy_ledger WHERE player_id = '$designerId' AND entry_type = 'design_release') = 1,
  'store_once', (SELECT count(*) FROM public.stores WHERE player_id = '$mogulId') = 1,
  'store_ledger_once', (SELECT count(*) FROM ledger.economy_ledger WHERE player_id = '$mogulId' AND entry_type = 'first_store_open' AND idempotency_key = '$storeKey') = 1,
  'idle_ledger_once', (SELECT count(*) FROM ledger.economy_ledger WHERE player_id = '$designerId' AND entry_type = 'idle_income_settlement' AND idempotency_key = '$idleKey') = 1,
  'designer_nonnegative', (SELECT house_funds >= 0 FROM public.brand_state WHERE player_id = '$designerId'),
  'mogul_nonnegative', (SELECT house_funds >= 0 FROM public.brand_state WHERE player_id = '$mogulId')
);
"@
  foreach ($assertion in @(
    'founder_receipt_once', 'founder_ledger_once', 'design_receipt_once',
    'design_ledger_once', 'store_once', 'store_ledger_once',
    'idle_ledger_once', 'designer_nonnegative', 'mogul_nonnegative'
  )) {
    if ($state -notmatch ('"' + $assertion + '"\s*:\s*true')) {
      throw "Concurrency invariant failed: $assertion. State: $state"
    }
  }
  Write-Output 'Passed: all four economic mutations produced one receipt/ledger effect, no negative balance, and deterministic conflicts.'
}
finally {
  # Append-only receipts deliberately make this suite single-use per reset.
}
