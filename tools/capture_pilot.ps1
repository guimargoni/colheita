param([string]$Godot = "godot")
$ErrorActionPreference = "Stop"
$repo = Split-Path $PSScriptRoot -Parent
$artifacts = Join-Path $repo '.local/pilot_v2'
New-Item -ItemType Directory -Force $artifacts | Out-Null
$resolvedGodot = (Get-Command $Godot -ErrorAction Stop).Source
$capture = Start-Process -FilePath $resolvedGodot -ArgumentList '--path', ('"' + $repo + '/game"'), '--rendering-method', 'gl_compatibility', '--script', 'res://tests/capture_pilot.gd' -WindowStyle Hidden -RedirectStandardOutput "$artifacts/capture.log" -RedirectStandardError "$artifacts/capture_errors.log" -PassThru
if (-not $capture.WaitForExit(60000)) { $capture.Kill(); throw 'Pilot capture timed out' }
$output = (Get-Content "$artifacts/capture.log" -Raw) + (Get-Content "$artifacts/capture_errors.log" -Raw)
Write-Output $output
if ($capture.ExitCode -ne 0 -or $output -match 'SCRIPT ERROR|Parse Error|ERROR:') { throw 'Pilot capture failed; graphical display required' }
$gallery = '<!doctype html><meta charset="utf-8"><title>Fazenda Viva · piloto v2</title><style>body{background:#fff2d5;color:#203d4a;font:18px system-ui;margin:24px}img{max-width:100%;max-height:86vh}section{display:flex;gap:16px;flex-wrap:wrap}figure{margin:0;max-width:48%}</style><h1>Fazenda Viva · amostra independente v2</h1><p>Capturas reais do Godot, sem retoque. Arte em avaliação. Sequência de colheita em 40/180/360 ms.</p>'
foreach ($resolution in @('1920x1080','1080x1920')) {
    $gallery += "<h2>$resolution</h2><section>"
    foreach ($state in @('farm','harvest_01','harvest_02','harvest_03','studio')) {
        $file = "pilot_${resolution}_${state}.png"
        if (-not (Test-Path -LiteralPath "$artifacts/captures/$file")) { throw "Missing $file" }
        $gallery += "<figure><figcaption>$state</figcaption><a href='captures/$file'><img src='captures/$file'></a></figure>"
    }
    $gallery += '</section>'
}
Set-Content -LiteralPath "$artifacts/index.html" -Value $gallery -Encoding utf8
Write-Output "Gallery: $artifacts/index.html"
