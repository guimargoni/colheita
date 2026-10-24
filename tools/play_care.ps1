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
if (-not $Godot -or -not (Test-Path -LiteralPath $Godot)) { throw 'Godot nao localizado. Execute tools/play_care.ps1 -Godot CAMINHO_DO_GODOT -Fast, ou abra a cena farm/g12/farm.tscn com F6.' }
$arguments = @('--path', (Join-Path $repo 'game'), 'res://scenes/farm/g12/farm.tscn')
if ($Fast) { $arguments += @('--','--g12-fast') }
if ($PrintCommand) { Write-Output $Godot; Write-Output $arguments; exit 0 }
Write-Output 'G1.2: clique em Inventario para escolher a semente; Cuidados para regar/remover/fertilizar.'
Write-Output 'O teste acelerado usa save separado. Trigo: 120 segundos; morango: 15; cenoura: 2.'
& $Godot @arguments
