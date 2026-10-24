param([string]$Godot = 'godot', [string]$Python = 'python')
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$artifacts = Join-Path $repo '.local/g12'
New-Item -ItemType Directory -Force $artifacts | Out-Null
$engine = (Get-Command $Godot -ErrorAction Stop).Source
$capture = Start-Process -FilePath $engine -ArgumentList '--path', ('"' + $repo + '/game"'), '--rendering-method', 'gl_compatibility', '--script', 'res://tests/capture_care.gd' -WindowStyle Hidden -RedirectStandardOutput "$artifacts/capture.log" -RedirectStandardError "$artifacts/capture_errors.log" -PassThru
if (-not $capture.WaitForExit(60000)) { $capture.Kill(); throw 'Care capture timed out' }
$output = (Get-Content "$artifacts/capture.log" -Raw) + (Get-Content "$artifacts/capture_errors.log" -Raw)
Write-Output $output
if ($capture.ExitCode -ne 0 -or $output -match 'SCRIPT ERROR|Parse Error|ERROR:') { throw 'Care capture failed' }
& $Python "$PSScriptRoot/gallery_care.py"
if ($LASTEXITCODE -ne 0) { throw 'Care gallery failed' }
