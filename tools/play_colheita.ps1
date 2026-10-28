param([string]$Godot = '', [switch]$Fast, [ValidateSet('one','two')][string]$Player = 'one', [switch]$TwoPlayers, [switch]$PrintCommand)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
if (-not $Godot) {
    $installed = Get-Command godot -ErrorAction SilentlyContinue
    if ($installed) { $Godot = $installed.Source }
}
if (-not $Godot) {
    $engine = Get-ChildItem -LiteralPath (Join-Path $env:USERPROFILE 'Downloads') -Filter 'Godot_v4.*-stable_win64_console.exe' -Recurse -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($engine) { $Godot = $engine.FullName }
}
if (-not $Godot -or -not (Test-Path -LiteralPath $Godot)) { throw 'Godot 4.x estavel nao localizado. Passe -Godot CAMINHO_DO_GODOT_CONSOLE.exe.' }
$port = if ($Fast) { 16663 } else { 16661 }
$mode = if ($Fast) { 'fast' } else { 'real' }
$serverDir = Join-Path $repo '.local/backend'
$world = Join-Path $serverDir "world_$mode.json"
$game = Join-Path $repo 'game'
$arguments = @('--path',$game,'res://scenes/main/farm.tscn','--',"--player=$Player","--server-port=$port")
if ($Fast) { $arguments += '--integrated-fast' }
if ($PrintCommand) { Write-Output $Godot; Write-Output $arguments; exit 0 }
New-Item -ItemType Directory -Force $serverDir | Out-Null
$import = & $Godot --headless --path $game --editor --quit 2>&1
if ($LASTEXITCODE -ne 0 -or $import -match 'SCRIPT ERROR|Parse Error|ERROR:') { throw "Falha ao importar o projeto: $import" }
function Test-LocalServer {
    $probe = New-Object System.Net.Sockets.TcpClient
    try { return $probe.ConnectAsync('127.0.0.1',$port).Wait(250) -and $probe.Connected } catch { return $false } finally { $probe.Dispose() }
}
if (-not (Test-LocalServer)) {
    $serverArgs = @('--headless','--path',('"'+$game+'"'),'--script',('"'+(Join-Path $repo 'backend/local/server.gd')+'"'),'--',"--port=$port",('"--world='+$world+'"'))
    if ($Fast) { $serverArgs += '--fast' }
    $server = Start-Process -FilePath $Godot -ArgumentList $serverArgs -WindowStyle Hidden -RedirectStandardOutput "$serverDir/server_$mode.log" -RedirectStandardError "$serverDir/server_$mode.errors.log" -PassThru
    $server.Id | Set-Content "$serverDir/server_$mode.pid"
    $deadline = (Get-Date).AddSeconds(12)
    while (-not (Test-LocalServer)) {
        if ((Get-Date) -gt $deadline -or $server.HasExited) { throw "Servidor local nao iniciou. Consulte $serverDir/server_$mode.errors.log" }
        Start-Sleep -Milliseconds 150
    }
}
Write-Output "Colheita integrada · servidor local em 127.0.0.1:$port · $mode"
Write-Output 'Fazenda abre animais, construcao, decoracao e social. Economia social calculada no servidor; nenhuma publicacao externa.'
if ($TwoPlayers) {
    foreach ($identity in @('one','two')) {
        $clientArgs = @('--path',('"'+$game+'"'),'res://scenes/main/farm.tscn','--',"--player=$identity","--server-port=$port")
        if ($Fast) { $clientArgs += '--integrated-fast' }
        Start-Process -FilePath $Godot -ArgumentList $clientArgs | Out-Null
    }
} else { & $Godot @arguments }
