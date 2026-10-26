param([string]$Godot = '', [switch]$Fast, [switch]$PrintCommand, [string]$SavePath = '')
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
if (-not $Godot -or -not (Test-Path -LiteralPath $Godot)) { throw 'Godot nao localizado. Execute tools/play_cultures.ps1 -Godot CAMINHO_DO_GODOT -Fast, ou abra a cena farm/g1v/farm.tscn com F6.' }
$arguments = @('--path', (Join-Path $repo 'game'), 'res://scenes/farm/g1v/farm.tscn')
$userArguments = @()
if ($Fast) { $userArguments += '--g1v-fast' }
if ($SavePath) { $userArguments += ('--g1v-save=' + $SavePath) }
if ($userArguments.Count) { $arguments += '--'; $arguments += $userArguments }
if ($PrintCommand) { Write-Output $Godot; Write-Output $arguments; exit 0 }
Write-Output 'G1.V: Loja compra sementes; Inventario seleciona sementes e vende produtos; Menu abre historico.'
Write-Output 'O teste acelerado usa save separado. Trigo: 120 segundos; morango: 15; cenoura: 2.'
& $Godot @arguments
