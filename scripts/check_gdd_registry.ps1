$ErrorActionPreference = 'Stop'

$gddPath = Join-Path $PSScriptRoot '..\THE_STYLISTE_GDD_v7.md'
$strictUtf8 = New-Object System.Text.UTF8Encoding($false, $true)

try {
  $gdd = [System.IO.File]::ReadAllText($gddPath, $strictUtf8)
} catch {
  throw "GDD registry failure: malformed UTF-8 in THE_STYLISTE_GDD_v7.md. $($_.Exception.Message)"
}

$lines = $gdd -split "\r\n|\n|\r"
$errors = New-Object System.Collections.Generic.List[string]

$mojibakeMarkers = [ordered]@{
  'Unicode replacement character U+FFFD' = [string][char]0xFFFD
  'stray Latin-1 A-circumflex U+00C2' = [string][char]0x00C2
  'stray Latin-1 A-tilde U+00C3' = [string][char]0x00C3
  'UTF-8 punctuation decoded as Latin-1' =
    ([string][char]0x00E2 + [string][char]0x20AC)
}

foreach ($marker in $mojibakeMarkers.GetEnumerator()) {
  $markerLines = for ($index = 0; $index -lt $lines.Count; $index++) {
    if ($lines[$index].Contains($marker.Value)) { $index + 1 }
  }
  if ($markerLines.Count -gt 0) {
    $errors.Add(
      "Known mojibake marker '$($marker.Key)' found on line numbers: " +
      ($markerLines -join ', ')
    )
  }
}

$headings = for ($index = 0; $index -lt $lines.Count; $index++) {
  if ($lines[$index] -match '^## (?<number>\d+)\. (?<title>.+)$') {
    [pscustomobject]@{
      Line = $index + 1
      Number = [int]$Matches.number
      Text = $lines[$index]
    }
  }
}

$closingHeading = $headings |
  Where-Object { $_.Number -eq 24 } |
  Select-Object -First 1
$restartHeading = if ($null -ne $closingHeading) {
  $headings |
    Where-Object { $_.Line -gt $closingHeading.Line } |
    Select-Object -First 1
}
$restartSummary = if ($null -ne $restartHeading) {
  "line $($restartHeading.Line): $($restartHeading.Text)"
} else {
  'none'
}

$requiredHeadings = @(
  '## 1. Product Vision',
  '## 21. Implementation Staging and Release Roadmap',
  '## 22. Feature Acceptance Criteria'
)

foreach ($requiredHeading in $requiredHeadings) {
  $matches = for ($index = 0; $index -lt $lines.Count; $index++) {
    if ($lines[$index] -ceq $requiredHeading) { $index + 1 }
  }
  if ($matches.Count -ne 1) {
    $lineSummary = if ($matches.Count -eq 0) { 'none' } else { $matches -join ', ' }
    $errors.Add(
      "Canonical heading '$requiredHeading' occurrence count: " +
      "$($matches.Count); line numbers: $lineSummary; " +
      "first suspected restart line: $restartSummary"
    )
  }
}

foreach ($section in 1..24) {
  $sectionHeadings = @($headings | Where-Object { $_.Number -eq $section })
  if ($sectionHeadings.Count -ne 1) {
    $lineSummary = if ($sectionHeadings.Count -eq 0) {
      'none'
    } else {
      ($sectionHeadings.Line -join ', ')
    }
    $headingSummary = if ($sectionHeadings.Count -eq 0) {
      "section $section"
    } else {
      (($sectionHeadings.Text | Select-Object -Unique) -join ' | ')
    }
    $errors.Add(
      "Top-level section number $section occurrence count: " +
      "$($sectionHeadings.Count); duplicated heading(s): $headingSummary; " +
      "line numbers: $lineSummary; first suspected restart line: $restartSummary"
    )
  }
}

if ($null -ne $restartHeading) {
  $errors.Add(
    "Numbered top-level sequence restarts after canonical closing material; " +
    "first suspected restart line: $restartSummary"
  )
}

$orphanedTocEntries = if ($null -ne $closingHeading) {
  for ($index = $closingHeading.Line; $index -lt $lines.Count; $index++) {
    if ($lines[$index] -match '^\d+\.\s+\[[^\]]+\]\(#[^)]+\)$') {
      [pscustomobject]@{
        Line = $index + 1
        Text = $lines[$index]
      }
    }
  }
}
if ($orphanedTocEntries.Count -gt 0) {
  $errors.Add(
    'Orphaned table-of-contents restart after canonical closing material; ' +
    "occurrence count: $($orphanedTocEntries.Count); line numbers: " +
    ($orphanedTocEntries.Line -join ', ') + '; first suspected restart line: ' +
    "line $($orphanedTocEntries[0].Line): $($orphanedTocEntries[0].Text)"
  )
}

$featureIds = [regex]::Matches($gdd, '(?m)^\|\s*([A-Z]+-\d+)\s*\|') |
  ForEach-Object { $_.Groups[1].Value }
$duplicateIds = $featureIds |
  Group-Object |
  Where-Object { $_.Count -gt 1 }
foreach ($duplicateId in $duplicateIds) {
  $idLines = for ($index = 0; $index -lt $lines.Count; $index++) {
    if ($lines[$index] -match ('^\|\s*' + [regex]::Escape($duplicateId.Name) + '\s*\|')) {
      $index + 1
    }
  }
  $errors.Add(
    "Duplicate Feature ID '$($duplicateId.Name)' occurrence count: " +
    "$($duplicateId.Count); line numbers: $($idLines -join ', ')"
  )
}

$featureFamilies = $featureIds |
  ForEach-Object {
    if ($_ -match '^(?<prefix>[A-Z]+)-(?<number>\d+)$') {
      [pscustomobject]@{
        Prefix = $Matches.prefix
        Number = [int]$Matches.number
      }
    }
  } |
  Group-Object Prefix
foreach ($family in $featureFamilies) {
  $numbers = @($family.Group.Number | Sort-Object -Unique)
  $maximum = ($numbers | Measure-Object -Maximum).Maximum
  $missingNumbers = @(1..$maximum | Where-Object { $_ -notin $numbers })
  if ($missingNumbers.Count -gt 0) {
    $missingIds = $missingNumbers |
      ForEach-Object { '{0}-{1:D2}' -f $family.Name, $_ }
    $errors.Add(
      "Non-continuous Feature ID family '$($family.Name)': missing " +
      ($missingIds -join ', ')
    )
  }
}

$requiredAcceptanceIds = @(
  (1..5 | ForEach-Object { 'FTUE-{0:D2}' -f $_ })
  (1..14 | ForEach-Object { 'SEC-{0:D2}' -f $_ })
)
$missingAcceptanceIds = $requiredAcceptanceIds |
  Where-Object { $_ -notin $featureIds }
if ($missingAcceptanceIds.Count -gt 0) {
  $errors.Add(
    'Missing required acceptance Feature IDs: ' +
    ($missingAcceptanceIds -join ', ')
  )
}

if ($errors.Count -gt 0) {
  throw ("GDD registry failure:`n- " + ($errors -join "`n- "))
}

Write-Output (
  'Static pass: GDD v7 has 24 unique top-level sections and ' +
  "$($featureIds.Count) unique Feature IDs across " +
  "$($featureFamilies.Count) continuous families."
)
