param([string]$Godot = 'godot', [string]$Python = 'python')
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
Push-Location $repo
try {
    $output = & $Godot --headless --path game --script res://tests/simulate_land.gd 2>&1
    $code = $LASTEXITCODE
    $output | ForEach-Object { Write-Output "$_" }
    if ($code -ne 0 -or $output -match 'SCRIPT ERROR|Parse Error|ERROR:') { throw 'Land simulation failed' }
    & $Python tools/report_land_balance.py
    if ($LASTEXITCODE -ne 0) { throw 'Land balance report failed' }
} finally { Pop-Location }
