param([string]$Godot = 'godot', [string]$Python = 'python')
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$artifacts = Join-Path $repo '.local/g15'
New-Item -ItemType Directory -Force $artifacts | Out-Null
$engine = (Get-Command $Godot -ErrorAction Stop).Source
$capture = Start-Process -FilePath $engine -ArgumentList '--path', ('"' + $repo + '/game"'), '--rendering-method', 'gl_compatibility', '--script', 'res://tests/capture_cultures.gd' -WindowStyle Hidden -RedirectStandardOutput "$artifacts/capture.log" -RedirectStandardError "$artifacts/capture_errors.log" -PassThru
if (-not $capture.WaitForExit(60000)) { $capture.Kill(); throw 'Economy capture timed out' }
$output = (Get-Content "$artifacts/capture.log" -Raw) + (Get-Content "$artifacts/capture_errors.log" -Raw)
Write-Output $output
if ($capture.ExitCode -ne 0 -or $output -match 'SCRIPT ERROR|Parse Error|ERROR:') { throw 'Economy capture failed' }
& $Python "$PSScriptRoot/gallery_cultures.py"
if ($LASTEXITCODE -ne 0) { throw 'Economy gallery failed' }
