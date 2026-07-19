<#
  Runs independent local database sessions against the quarantined Casting RPC.
  Every attempt must fail promptly with CASTING_UNAVAILABLE and leave the
  player's economic, pity, banner, and roster state unchanged.
#>

$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$playerId = '00000000-0000-4000-8000-00000000c107'
$castingJobs = @()

function Invoke-LocalQuery {
  param([Parameter(Mandatory)][string]$Sql)

  $previousErrorAction = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  $output = & supabase db query --local --output json $Sql 2>&1
  $exitCode = $LASTEXITCODE
  $ErrorActionPreference = $previousErrorAction
  if ($exitCode -ne 0) {
    throw "Local database query failed: $($output | Out-String)"
  }

  return $output | Out-String
}

function Start-ExpectedCastingUnavailableJob {
  param([Parameter(Mandatory)][string]$Sql)

  return Start-Job -ArgumentList $repositoryRoot, $Sql -ScriptBlock {
    param($jobRepositoryRoot, $jobSql)

    Set-Location $jobRepositoryRoot
    $ErrorActionPreference = 'Continue'
    $output = & supabase db query --local --output json $jobSql 2>&1
    if ($LASTEXITCODE -eq 0) {
      throw "A quarantined Casting call unexpectedly succeeded: $($output | Out-String)"
    }
    if (($output | Out-String) -notmatch 'CASTING_UNAVAILABLE') {
      throw "Casting failed for an unexpected reason: $($output | Out-String)"
    }

    return 'blocked'
  }
}

function Assert-JobsBlockedWithoutDeadlock {
  param([Parameter(Mandatory)][array]$Jobs)

  foreach ($job in $Jobs) {
    $completed = Wait-Job -Job $job -Timeout 30
    if ($null -eq $completed) {
      Stop-Job -Job $job
      throw 'A concurrent Casting attempt did not finish within 30 seconds.'
    }
  }

  foreach ($job in $Jobs) {
    if ((Receive-Job -Job $job -ErrorAction Stop) -ne 'blocked') {
      throw 'A concurrent Casting attempt was not quarantined.'
    }
  }
}

$singleQuery = @"
WITH claims AS MATERIALIZED (
  SELECT set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', '$playerId',
      'role', 'authenticated',
      'is_anonymous', FALSE
    )::text,
    false
  )
)
SELECT casting.*
FROM claims
CROSS JOIN LATERAL public.execute_casting_pull('standard', FALSE) AS casting;
"@

$tenPullQuery = @"
WITH claims AS MATERIALIZED (
  SELECT set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', '$playerId',
      'role', 'authenticated',
      'is_anonymous', FALSE
    )::text,
    false
  )
)
SELECT casting.*
FROM claims
CROSS JOIN LATERAL public.execute_casting_pull('standard', TRUE) AS casting;
"@

try {
  Invoke-LocalQuery @"
WITH deleted_player AS (
  DELETE FROM public.players
  WHERE id = '$playerId'
  RETURNING id
),
inserted_player AS (
  INSERT INTO public.players (id, brand_name, path, hq_city)
  SELECT
    '$playerId',
    'Directive 26 Concurrent Casting',
    'mogul',
    'Paris'
  FROM (SELECT count(*) FROM deleted_player) AS cleanup
  RETURNING id
),
inserted_brand AS (
  INSERT INTO public.brand_state (player_id, luxe_tokens)
  SELECT id, 1100 FROM inserted_player
  RETURNING player_id
),
inserted_pity AS (
  INSERT INTO public.gacha_pity_state (
    player_id,
    banner_id,
    pulls_since_sovereign,
    total_pulls,
    last_pull_at
  )
  SELECT id, 'standard', 89, 189, '2026-01-02T00:00:00Z'
  FROM inserted_player
  RETURNING player_id
),
inserted_roster AS (
  INSERT INTO public.player_roster (
    player_id,
    talent_id,
    acquisition_source
  )
  SELECT player.id, talent.id, 'historical_casting'
  FROM inserted_player AS player
  CROSS JOIN LATERAL (
    SELECT id FROM public.talent_pool ORDER BY id LIMIT 1
  ) AS talent
  RETURNING player_id
)
SELECT
  (SELECT count(*) FROM inserted_brand) AS brand_rows,
  (SELECT count(*) FROM inserted_pity) AS pity_rows,
  (SELECT count(*) FROM inserted_roster) AS roster_rows;
"@ | Out-Null

  $castingJobs = @(
    Start-ExpectedCastingUnavailableJob $singleQuery
    Start-ExpectedCastingUnavailableJob $singleQuery
    Start-ExpectedCastingUnavailableJob $tenPullQuery
    Start-ExpectedCastingUnavailableJob $tenPullQuery
  )
  Assert-JobsBlockedWithoutDeadlock -Jobs $castingJobs

  $state = Invoke-LocalQuery @"
SELECT
  (SELECT luxe_tokens = 1100 FROM public.brand_state WHERE player_id = '$playerId') AS luxe_unchanged,
  (
    SELECT pulls_since_sovereign = 89 AND total_pulls = 189
      AND last_pull_at = '2026-01-02T00:00:00Z'::timestamptz
    FROM public.gacha_pity_state
    WHERE player_id = '$playerId' AND banner_id = 'standard'
  ) AS pity_and_banner_unchanged,
  (
    SELECT count(*) = 1 FROM public.player_roster WHERE player_id = '$playerId'
  ) AS roster_unchanged;
"@

  if (
    $state -notmatch '"luxe_unchanged"\s*:\s*true' -or
    $state -notmatch '"pity_and_banner_unchanged"\s*:\s*true' -or
    $state -notmatch '"roster_unchanged"\s*:\s*true'
  ) {
    throw "Concurrent Casting quarantine mutated state: $state"
  }

  Write-Output 'Passed: concurrent Casting attempts are denied without mutation or deadlock.'
}
finally {
  foreach ($job in $castingJobs) {
    if ($job.State -eq 'Running') {
      Stop-Job -Job $job
    }
    Remove-Job -Job $job -Force
  }

  Invoke-LocalQuery "DELETE FROM public.players WHERE id = '$playerId';" | Out-Null
}
