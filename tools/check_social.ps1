param([string]$Godot = 'godot',[string]$Python = 'python',[int]$Port = 16664)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$engine = (Get-Command $Godot -ErrorAction Stop).Source
$run = Join-Path $repo ('.local/backend/qa_'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force $run | Out-Null
$world = Join-Path $run 'world.json'
$server = $null
function Start-TestServer {
    $args = @('--headless','--path',('"'+(Join-Path $repo 'game')+'"'),'--script',('"'+(Join-Path $repo 'backend/local/server.gd')+'"'),'--',"--port=$Port",('"--world='+$world+'"'),'--fast')
    $script:server = Start-Process -FilePath $engine -ArgumentList $args -WindowStyle Hidden -RedirectStandardOutput (Join-Path $run 'server.log') -RedirectStandardError (Join-Path $run 'server.errors.log') -PassThru
    Start-Sleep -Milliseconds 700
    if ($script:server.HasExited) { throw 'QA server exited; see logs' }
}
Push-Location $repo
try {
    $import = & $engine --headless --path game --editor --quit 2>&1
    if ($LASTEXITCODE -ne 0 -or $import -match "SCRIPT ERROR|Parse Error|ERROR:") { throw "Import failed: $import" }
    Start-TestServer
    & $Python tools/test_local_social.py --port $Port
    if ($LASTEXITCODE -ne 0) { throw 'Real social test failed' }
    Stop-Process -Id $server.Id
    $server.WaitForExit()
    Start-TestServer
    & $Python tools/test_social_recovery.py --port $Port
    if ($LASTEXITCODE -ne 0) { throw 'Recovery test failed' }
    & $Python tools/test_social_concurrency.py --port $Port
    if ($LASTEXITCODE -ne 0) { throw "Concurrent social test failed" }
    $mailbox = Join-Path $run 'mailbox'
    New-Item -ItemType Directory -Force $mailbox | Out-Null
    $clients = @()
    foreach ($role in @('sender','receiver')) {
        $clientArgs = @('--headless','--path',('"'+(Join-Path $repo 'game')+'"'),'--script','res://tests/integrated_client_probe.gd','--',"--port=$Port","--role=$role",('"--mailbox='+$mailbox+'"'))
        $clients += Start-Process -FilePath $engine -ArgumentList $clientArgs -WindowStyle Hidden -RedirectStandardOutput (Join-Path $run "client_$role.log") -RedirectStandardError (Join-Path $run "client_$role.errors.log") -PassThru
    }
    foreach ($client in $clients) {
        if (-not $client.WaitForExit(30000)) { $client.Kill(); throw 'Separate client process timed out' }
        if ($client.ExitCode -ne 0) { throw 'Separate client process failed; see QA logs' }
    }
    foreach ($role in @('sender','receiver')) {
        Get-Content (Join-Path $run "client_$role.log") | Write-Output
        $errors = Get-Content (Join-Path $run "client_$role.errors.log") -Raw
        if ($errors -match 'SCRIPT ERROR|ERROR:') { throw $errors }
    }
    $output = & $engine --headless --path game --script res://tests/integrated_remote_ui_tests.gd -- "--port=$Port" 2>&1
    $output | ForEach-Object { Write-Output "$_" }
    if ($LASTEXITCODE -ne 0 -or $output -match 'SCRIPT ERROR|Parse Error|ERROR:') { throw 'Native remote UI failed' }
    $errors = Get-Content (Join-Path $run 'server.errors.log') -Raw
    if ($errors -match 'SCRIPT ERROR|ERROR:') { throw "Server errors: $errors" }
    Write-Output "Social integration logs: $run"
} finally {
    foreach ($client in $clients) { if (-not $client.HasExited) { Stop-Process -Id $client.Id } }
    if ($server -and -not $server.HasExited) { Stop-Process -Id $server.Id }
    Pop-Location
}
