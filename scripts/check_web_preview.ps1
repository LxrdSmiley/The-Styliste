$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()

function Require-File([string] $relativePath) {
  if (-not (Test-Path -LiteralPath (Join-Path $repositoryRoot $relativePath))) {
    $failures.Add("Missing required web-preview file: $relativePath")
  }
}

Require-File 'web/index.html'
Require-File 'web/manifest.json'
Require-File 'web/favicon.svg'
Require-File '.github/workflows/pages.yml'

$main = Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'lib/main.dart')
$auth = Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'lib/core/providers/auth_provider.dart')
$pubspec = Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot 'pubspec.yaml')
$pages = Get-Content -Raw -LiteralPath (Join-Path $repositoryRoot '.github/workflows/pages.yml')

if (-not $main.Contains('SUPABASE_PUBLISHABLE_KEY')) {
  $failures.Add('lib/main.dart does not consume the public Supabase publishable key.')
}
if ([regex]::Matches($main, 'Supabase\.initialize\(').Count -ne 1) {
  $failures.Add('lib/main.dart must contain exactly one Supabase.initialize call.')
}
if ($main -match '(?m)^\s*publishableKey\s*:') {
  $failures.Add('lib/main.dart uses an unsupported Supabase.initialize named parameter.')
}
if (-not $main.Contains('anonKey: publicClientKey')) {
  $failures.Add('lib/main.dart does not pass the selected public key to Supabase.initialize.')
}
if (-not $auth.Contains('signInAnonymously')) {
  $failures.Add('Supabase anonymous founder-trial bootstrap is missing.')
}
if ($auth -match '(?i)firebase') {
  $failures.Add('Firebase identity terminology remains in auth_provider.dart.')
}
if ($pubspec -match '(?m)^\s*firebase_(core|auth|app_check|messaging):') {
  $failures.Add('A Firebase client dependency remains in pubspec.yaml.')
}
$dartSources = Get-ChildItem -LiteralPath (Join-Path $repositoryRoot 'lib') -Recurse -File -Filter '*.dart'
foreach ($source in $dartSources) {
  $sourceText = Get-Content -Raw -LiteralPath $source.FullName
  if ($sourceText -match 'import\s+[''"]dart:io[''"]') {
    $relative = [System.IO.Path]::GetRelativePath($repositoryRoot, $source.FullName)
    $failures.Add("Web-incompatible dart:io import remains in $relative")
  }
  if ($sourceText -match "package:firebase_(auth|core|app_check|messaging)") {
    $relative = [System.IO.Path]::GetRelativePath($repositoryRoot, $source.FullName)
    $failures.Add("Retired Firebase client import remains in $relative")
  }
}
if (-not $pages.Contains('flutter build web --release')) {
  $failures.Add('Pages workflow does not build Flutter Web.')
}
if (-not $pages.Contains('workflow_dispatch:')) {
  $failures.Add('Pages workflow is not manually dispatchable.')
}
if ($pages -match '(?m)^\s+(push|pull_request|schedule)\s*:') {
  $failures.Add('Pages workflow contains a prohibited automatic trigger.')
}
if (-not $pages.Contains('test "$PREVIEW_ENVIRONMENT" = "staging"')) {
  $failures.Add('Pages workflow does not fail closed outside staging.')
}
if (-not $pages.Contains('--base-href "/The-Styliste/"')) {
  $failures.Add('Pages workflow is missing the reviewed repository base href.')
}
if (-not $pages.Contains('path: build/web')) {
  $failures.Add('Pages workflow does not upload build/web.')
}
if ($pages.Contains('path: docs/pages')) {
  $failures.Add('Pages workflow still uploads the retired project-status site.')
}
if (-not $pages.Contains('actions/upload-pages-artifact@') -or
    -not $pages.Contains('actions/deploy-pages@')) {
  $failures.Add('Pages workflow does not use the official Pages artifact/deployment actions.')
}
if (-not $pages.Contains('SUPABASE_SERVICE_ROLE_KEY') -or
    -not $pages.Contains('BEGIN PRIVATE KEY')) {
  $failures.Add('Pages workflow is missing the reviewed private-credential artifact scan.')
}

foreach ($retiredPath in @(
  'firebase.json',
  'android/app/google-services.json',
  'lib/core/services/firebase_service.dart',
  'supabase/functions/send-fcm-notification/index.ts'
)) {
  if (Test-Path -LiteralPath (Join-Path $repositoryRoot $retiredPath)) {
    $failures.Add("Retired Firebase artifact remains: $retiredPath")
  }
}

if ($failures.Count -gt 0) {
  foreach ($failure in $failures) { Write-Error $failure }
  exit 1
}

Write-Output 'Static pass: Flutter Web and Pages preview contracts are aligned.'
