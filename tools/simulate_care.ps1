param([string]$Godot = 'godot', [string]$Python = 'python')
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$output = & $Godot --headless --path "$repo/game" --script res://tests/simulate_care.gd 2>&1
$code = $LASTEXITCODE
$output | ForEach-Object { Write-Output "$_" }
if ($code -ne 0 -or $output -match 'SCRIPT ERROR|Parse Error|ERROR:') { throw 'Care simulation failed' }
& $Python "$PSScriptRoot/report_care_balance.py"
if ($LASTEXITCODE -ne 0) { throw 'Care balance report failed' }
