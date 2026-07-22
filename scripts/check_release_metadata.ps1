$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$pubspecPath = Join-Path $repositoryRoot 'pubspec.yaml'
$readmePath = Join-Path $repositoryRoot 'README.md'
$changelogPath = Join-Path $repositoryRoot 'CHANGELOG.md'
$settingsPath = Join-Path $repositoryRoot 'lib/features/settings/screens/settings_screen.dart'

$pubspec = Get-Content -Raw -LiteralPath $pubspecPath
$versionMatch = [regex]::Match($pubspec, '(?m)^version:\s*([^\s]+)\s*$')
if (-not $versionMatch.Success) {
  throw 'Failed: pubspec.yaml has no application version.'
}

$versionWithBuild = $versionMatch.Groups[1].Value
$version = ($versionWithBuild -split '\+', 2)[0]
$tag = "v$version"
$releaseNotesPath = Join-Path $repositoryRoot "docs/releases/$tag.md"

$readme = Get-Content -Raw -LiteralPath $readmePath
$changelog = Get-Content -Raw -LiteralPath $changelogPath
$settings = Get-Content -Raw -LiteralPath $settingsPath

$failures = [System.Collections.Generic.List[string]]::new()

if (-not $readme.Contains("Current development version: ``$versionWithBuild``")) {
  $failures.Add("README.md does not declare $versionWithBuild as the current development version.")
}

if (-not $changelog.Contains("## [$version] - Unreleased")) {
  $failures.Add("CHANGELOG.md has no active prerelease section for $version.")
}

if (-not (Test-Path -LiteralPath $releaseNotesPath)) {
  $failures.Add("Missing release notes: docs/releases/$tag.md")
}

if (-not $settings.Contains("THE STYLISTE  v$version")) {
  $failures.Add('The in-app Settings version is not synchronized with pubspec.yaml.')
}

if ($failures.Count -gt 0) {
  foreach ($failure in $failures) {
    Write-Error $failure
  }
  exit 1
}

Write-Output "Static pass: release metadata is synchronized for $tag ($versionWithBuild)."
