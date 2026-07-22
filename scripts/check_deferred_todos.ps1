$ErrorActionPreference = 'Stop'
$allowList = Get-Content -Raw -Encoding utf8 'docs/governance/deferred_feature_ids.md'
$todoMatches = rg --no-heading --line-number 'TODO\(([A-Z]+-\d+)\)' lib test supabase
foreach ($match in $todoMatches) {
  if ($match -match 'TODO\(([A-Z]+-\d+)\)') {
    if ($allowList -notmatch [regex]::Escape($Matches[1])) {
      throw "Untracked TODO Feature ID: $($Matches[1])"
    }
  }
}
if (rg -P --no-heading --line-number 'TODO(?!\([A-Z]+-\d+\))' lib test supabase) {
  throw 'Every TODO must include a tracked Feature ID.'
}
Write-Output 'Static pass: TODO Feature IDs are tracked.'
