<#
  Runs two independent local Supabase CLI sessions per scenario. This is kept
  outside pgTAP because the local test role is intentionally forbidden from
  passwordless database-to-database connections, and no credentials belong in
  a repository test.
#>

$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$singlePlayerId = '00000000-0000-4000-8000-00000000c107'
$mixedPlayerId = '00000000-0000-4000-8000-00000000c108'

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

function Start-LocalCastingJob {
  param([Parameter(Mandatory)][string]$Sql)

  return Start-Job -ArgumentList $repositoryRoot, $Sql -ScriptBlock {
    param($jobRepositoryRoot, $jobSql)

    Set-Location $jobRepositoryRoot
    $ErrorActionPreference = 'Continue'
    $output = & supabase db query --local --output json $jobSql 2>&1
    if ($LASTEXITCODE -ne 0) {
      throw "Concurrent local Casting query failed: $($output | Out-String)"
    }

    return $output
  }
}

function Assert-CastingResult {
  param(
    [Parameter(Mandatory)]$Job,
    [Parameter(Mandatory)][int]$ExpectedLuxeSpent,
    [Parameter(Mandatory)][int]$ExpectedPullCount
  )

  Wait-Job $Job | Out-Null
  $result = Receive-Job $Job -ErrorAction Stop | Out-String

  if (
    $result -notmatch '"success"\s*:\s*true' -or
    $result -notmatch ('"luxe_spent"\s*:\s*{0}' -f $ExpectedLuxeSpent) -or
    $result -notmatch ('"pull_count"\s*:\s*{0}' -f $ExpectedPullCount)
  ) {
    throw "Concurrent Casting result did not match the accepted pull contract: $result"
  }
}

function Start-ExpectedUnavailableJob {
  param([Parameter(Mandatory)][string]$Sql)

  return Start-Job -ArgumentList $repositoryRoot, $Sql -ScriptBlock {
    param($jobRepositoryRoot, $jobSql)

    Set-Location $jobRepositoryRoot
    $ErrorActionPreference = 'Continue'
    $output = & supabase db query --local --output json $jobSql 2>&1
    if ($LASTEXITCODE -eq 0) {
      throw "A contained mini-game call unexpectedly succeeded: $($output | Out-String)"
    }
    if (($output | Out-String) -notmatch 'MINI_GAME_REWARDS_UNAVAILABLE') {
      throw "Mini-game call failed for an unexpected reason: $($output | Out-String)"
    }

    return 'blocked'
  }
}

$singleQuery = @"
WITH claims AS MATERIALIZED (
  SELECT set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', '00000000-0000-4000-8000-00000000c107',
      'role', 'authenticated',
      'is_anonymous', FALSE
    )::text,
    false
  )
)
SELECT success, luxe_spent, jsonb_array_length(pulls) AS pull_count
FROM claims
CROSS JOIN LATERAL public.execute_casting_pull('standard', FALSE);
"@

$mixedSingleQuery = @"
WITH claims AS MATERIALIZED (
  SELECT set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', '00000000-0000-4000-8000-00000000c108',
      'role', 'authenticated',
      'is_anonymous', FALSE
    )::text,
    false
  )
)
SELECT success, luxe_spent, jsonb_array_length(pulls) AS pull_count
FROM claims
CROSS JOIN LATERAL public.execute_casting_pull('standard', FALSE);
"@

$mixedTenQuery = @"
WITH claims AS MATERIALIZED (
  SELECT set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', '00000000-0000-4000-8000-00000000c108',
      'role', 'authenticated',
      'is_anonymous', FALSE
    )::text,
    false
  )
)
SELECT success, luxe_spent, jsonb_array_length(pulls) AS pull_count
FROM claims
CROSS JOIN LATERAL public.execute_casting_pull('standard', TRUE);
"@

$parallelMiniClaim = @"
SELECT public.edge_claim_mini_game(
  '00000000-0000-4000-8000-00000000c106',
  '00000000-0000-4000-8000-00000000c109',
  jsonb_build_object('outcome', 'win', 'score', 999999)
);
"@

try {
  Invoke-LocalQuery @"
DELETE FROM public.players
WHERE id IN ('$singlePlayerId', '$mixedPlayerId');
"@ | Out-Null

  Invoke-LocalQuery @"
WITH fixtures (id, brand_name, luxe_tokens) AS (
  VALUES
    ('$singlePlayerId'::uuid, 'M3A1 Concurrent Singles', 200),
    ('$mixedPlayerId'::uuid, 'M3A1 Concurrent Mixed', 1100)
),
created_players AS (
  INSERT INTO public.players (id, brand_name, path, hq_city)
  SELECT id, brand_name, 'mogul', 'Paris'
  FROM fixtures
  RETURNING id
)
INSERT INTO public.brand_state (player_id, luxe_tokens)
SELECT id, luxe_tokens
FROM fixtures;
"@ | Out-Null

  $singleA = Start-LocalCastingJob $singleQuery
  $singleB = Start-LocalCastingJob $singleQuery
  Assert-CastingResult -Job $singleA -ExpectedLuxeSpent 100 -ExpectedPullCount 1
  Assert-CastingResult -Job $singleB -ExpectedLuxeSpent 100 -ExpectedPullCount 1

  $singleState = Invoke-LocalQuery @"
SELECT
  (SELECT luxe_tokens = 0 FROM public.brand_state WHERE player_id = '$singlePlayerId') AS luxe_conserved,
  (SELECT total_pulls = 2 FROM public.gacha_pity_state WHERE player_id = '$singlePlayerId' AND banner_id = 'standard') AS pity_matches_completed_pulls,
  NOT EXISTS (
    SELECT 1 FROM public.brand_state
    WHERE player_id = '$singlePlayerId' AND luxe_tokens < 0
  ) AS non_negative_balance;
"@
  if (
    $singleState -notmatch '"luxe_conserved"\s*:\s*true' -or
    $singleState -notmatch '"pity_matches_completed_pulls"\s*:\s*true' -or
    $singleState -notmatch '"non_negative_balance"\s*:\s*true'
  ) {
    throw "Concurrent single-pull state did not satisfy containment: $singleState"
  }

  $mixedSingle = Start-LocalCastingJob $mixedSingleQuery
  $mixedTen = Start-LocalCastingJob $mixedTenQuery
  Assert-CastingResult -Job $mixedSingle -ExpectedLuxeSpent 100 -ExpectedPullCount 1
  Assert-CastingResult -Job $mixedTen -ExpectedLuxeSpent 1000 -ExpectedPullCount 10

  $mixedState = Invoke-LocalQuery @"
SELECT
  (SELECT luxe_tokens = 0 FROM public.brand_state WHERE player_id = '$mixedPlayerId') AS luxe_conserved,
  (SELECT total_pulls = 11 FROM public.gacha_pity_state WHERE player_id = '$mixedPlayerId' AND banner_id = 'standard') AS pity_matches_completed_pulls,
  NOT EXISTS (
    SELECT 1 FROM public.brand_state
    WHERE player_id = '$mixedPlayerId' AND luxe_tokens < 0
  ) AS non_negative_balance;
"@
  if (
    $mixedState -notmatch '"luxe_conserved"\s*:\s*true' -or
    $mixedState -notmatch '"pity_matches_completed_pulls"\s*:\s*true' -or
    $mixedState -notmatch '"non_negative_balance"\s*:\s*true'
  ) {
    throw "Concurrent mixed-pull state did not satisfy containment: $mixedState"
  }

  $miniClaimA = Start-ExpectedUnavailableJob $parallelMiniClaim
  $miniClaimB = Start-ExpectedUnavailableJob $parallelMiniClaim
  Wait-Job $miniClaimA, $miniClaimB | Out-Null
  if ((Receive-Job $miniClaimA -ErrorAction Stop) -ne 'blocked') {
    throw 'Parallel mini-game claim one was not contained.'
  }
  if ((Receive-Job $miniClaimB -ErrorAction Stop) -ne 'blocked') {
    throw 'Parallel mini-game claim two was not contained.'
  }

  Write-Output 'Passed: independent-session Casting and mini-game concurrency containment.'
}
finally {
  Invoke-LocalQuery @"
DELETE FROM public.players
WHERE id IN ('$singlePlayerId', '$mixedPlayerId');
"@ | Out-Null
}
