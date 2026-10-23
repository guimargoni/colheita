param([string]$Godot = "godot", [string]$Python = "python")
$ErrorActionPreference = "Stop"
$repo = Split-Path $PSScriptRoot -Parent
$artifacts = Join-Path $repo '.local/g06'
New-Item -ItemType Directory -Force $artifacts | Out-Null
$resolvedGodot = (Get-Command $Godot -ErrorAction Stop).Source
$capture = Start-Process -FilePath $resolvedGodot -ArgumentList '--path', ('"' + $repo + '/game"'), '--rendering-method', 'gl_compatibility', '--script', 'res://tests/capture_g06.gd' -WindowStyle Hidden -RedirectStandardOutput "$artifacts/capture.log" -RedirectStandardError "$artifacts/capture_errors.log" -PassThru
if (-not $capture.WaitForExit(60000)) { $capture.Kill(); throw 'Pilot capture timed out' }
$output = (Get-Content "$artifacts/capture.log" -Raw) + (Get-Content "$artifacts/capture_errors.log" -Raw)
Write-Output $output
if ($capture.ExitCode -ne 0 -or $output -match 'SCRIPT ERROR|Parse Error|ERROR:') { throw 'Pilot capture failed; graphical display required' }

& $Python "$PSScriptRoot/gallery_g06.py"
if ($LASTEXITCODE -ne 0) { throw 'G0.6 gallery generation failed' }
