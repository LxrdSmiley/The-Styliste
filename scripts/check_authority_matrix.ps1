$ErrorActionPreference = 'Stop'

$catalogPath = 'supabase/tests/authority_contract_matrix.json'
$configPath = 'supabase/config.toml'
$functionsRoot = 'supabase/functions'
$catalog = Get-Content -Raw -Encoding utf8 $catalogPath | ConvertFrom-Json
$config = Get-Content -Raw -Encoding utf8 $configPath

$configured = @(
  [regex]::Matches($config, '(?m)^\[functions\.([^\]]+)\]') |
    ForEach-Object { $_.Groups[1].Value }
) | Sort-Object -Unique
$cataloged = @(
  @($catalog.enabled_endpoints).endpoint
  @($catalog.disabled_endpoints).endpoint
) | Sort-Object -Unique
if (Compare-Object $configured $cataloged) {
  throw 'Configured Edge Function sections and authority catalog entries differ.'
}

$folders = @(Get-ChildItem -LiteralPath $functionsRoot -Directory |
  Where-Object Name -ne '_shared' | ForEach-Object Name) | Sort-Object -Unique
$sourceInventory = @($cataloged + @($catalog.unconfigured_function_sources)) |
  Sort-Object -Unique
if (Compare-Object $folders $sourceInventory) {
  throw 'Edge Function source folders and catalog source inventory differ.'
}

$apiRelations = @($catalog.api_relations) | Sort-Object -Unique
$apiRpcs = @($catalog.api_rpcs) | Sort-Object -Unique
if ($apiRelations.Count -ne 12 -or $apiRpcs.Count -ne 7) {
  throw 'The exact Kingston API allowlist must contain 12 projections and 7 wrappers.'
}

Write-Output 'Static pass: function folders, config sections, projections, wrappers, and catalog inventory agree.'
