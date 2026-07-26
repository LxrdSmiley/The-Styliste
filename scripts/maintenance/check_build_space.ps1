[CmdletBinding()]
param(
    [switch]$DryRun,
    [ValidateRange(1, 100)]
    [int]$MinimumFreeGB = 5
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptsDirectory = Split-Path -Parent $PSScriptRoot
$repositoryRoot = Split-Path -Parent $scriptsDirectory
$driveRoot = [System.IO.Path]::GetPathRoot($repositoryRoot)
$drive = [System.IO.DriveInfo]::new($driveRoot)
$freeGB = [math]::Round($drive.AvailableFreeSpace / 1GB, 2)
Write-Output "Repository: $repositoryRoot"
Write-Output "Available space on ${driveRoot}: $freeGB GB"
Write-Output "Required build headroom: $MinimumFreeGB GB"

if ($DryRun) {
    Write-Output 'Dry run: would fail if free space is below the Android build threshold.'
    Write-Output 'Dry run never deletes build outputs, caches, source files, or migrations.'
    exit 0
}

if ($freeGB -lt $MinimumFreeGB) {
    throw "Blocked: free at least $MinimumFreeGB GB before starting an Android build."
}

Write-Output 'Passed: Android build-space preflight completed.'
