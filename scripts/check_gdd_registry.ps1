$ErrorActionPreference = 'Stop'

$gddPath = Join-Path $PSScriptRoot '..\THE_STYLISTE_GDD_v8.md'
$strictUtf8 = New-Object System.Text.UTF8Encoding($false, $true)

try {
  $gdd = [System.IO.File]::ReadAllText($gddPath, $strictUtf8)
} catch {
  throw "GDD registry failure: malformed UTF-8 in THE_STYLISTE_GDD_v8.md. $($_.Exception.Message)"
}

$lines = $gdd -split "\r\n|\n|\r"
$errors = New-Object System.Collections.Generic.List[string]

$requiredHeadings = @(
  '## 1. Product Vision',
  '## 21. Implementation Staging and Release Roadmap',
  '### 21.3 Master feature staging registry',
  '## 22. Feature Acceptance Criteria'
)
foreach ($requiredHeading in $requiredHeadings) {
  $matches = @($lines | Where-Object { $_ -ceq $requiredHeading })
  if ($matches.Count -ne 1) {
    $errors.Add("Canonical heading '$requiredHeading' occurrence count: $($matches.Count).")
  }
}

$featureIds = [regex]::Matches($gdd, '(?m)^\|\s*([A-Z][A-Z0-9-]*-\d+)\s*\|') |
  ForEach-Object { $_.Groups[1].Value }
$duplicateIds = $featureIds | Group-Object | Where-Object { $_.Count -gt 1 }
foreach ($duplicateId in $duplicateIds) {
  $errors.Add("Duplicate Feature ID '$($duplicateId.Name)' occurrence count: $($duplicateId.Count).")
}

if ($featureIds.Count -ne 160) {
  $errors.Add("Expected 160 unique v8 Feature IDs; found $($featureIds.Count).")
}

foreach ($requiredId in @('FTUE-01', 'FTUE-05', 'SEC-01', 'SEC-14', 'ART-DIR-01')) {
  if ($requiredId -notin $featureIds) {
    $errors.Add("Missing required v8 Feature ID: $requiredId.")
  }
}

if ($errors.Count -gt 0) {
  throw ("GDD registry failure:`n- " + ($errors -join "`n- "))
}

Write-Output "Static Pass: GDD v8 has 160 unique Feature IDs and one canonical implementation registry."
