param([string]$Godot = '', [switch]$Fast, [switch]$PrintCommand)
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
if (-not $Godot -or -not (Test-Path -LiteralPath $Godot)) { throw 'Godot nao localizado. Execute tools/play_land.ps1 -Godot CAMINHO_DO_GODOT -Fast, ou abra a cena farm/g14/farm.tscn com F6.' }
$arguments = @('--path', (Join-Path $repo 'game'), 'res://scenes/farm/g14/farm.tscn')
if ($Fast) { $arguments += @('--','--g14-fast') }
if ($PrintCommand) { Write-Output $Godot; Write-Output $arguments; exit 0 }
Write-Output 'G1.4: Loja compra sementes; Inventario seleciona sementes e vende produtos; Menu abre historico.'
Write-Output 'O teste acelerado usa save separado. Trigo: 120 segundos; morango: 15; cenoura: 2.'
& $Godot @arguments
