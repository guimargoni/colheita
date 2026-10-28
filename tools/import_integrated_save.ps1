param([Parameter(Mandatory=$true)][string]$SourceSave, [Parameter(Mandatory=$true)][string]$DestinationSave, [string]$Godot = '', [switch]$Fast)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
if (-not $Godot) {
    $installed = Get-Command godot -ErrorAction SilentlyContinue
    if ($installed) { $Godot = $installed.Source }
}
if (-not $Godot) {
    $downloads = Join-Path $env:USERPROFILE 'Downloads'
    $engine = Get-ChildItem -LiteralPath $downloads -Filter 'Godot_v4.*-stable_win64_console.exe' -Recurse -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($engine) { $Godot = $engine.FullName }
}
if (-not $Godot -or -not (Test-Path -LiteralPath $Godot)) { throw 'Godot nao localizado. Execute tools/play_colheita.ps1 -Godot CAMINHO_DO_GODOT -Fast, ou abra a cena farm/g15/farm.tscn com F6.' }
$mode = if ($Fast) { 'fast' } else { 'normal' }
$output = & $Godot --headless --path (Join-Path $repo 'game') --script res://tests/import_integrated_save.gd -- $SourceSave $DestinationSave $mode 2>&1
$code = $LASTEXITCODE
$output | ForEach-Object { Write-Output "$_" }
if ($code -ne 0 -or $output -match 'SCRIPT ERROR|Parse Error|ERROR:') { throw 'Importacao recusada. O arquivo original foi preservado.' }
