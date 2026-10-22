param([string]$Godot = "godot")
$ErrorActionPreference = "Stop"
$repo = Split-Path $PSScriptRoot -Parent
$artifacts = Join-Path $repo '.local/g0_5r'
New-Item -ItemType Directory -Force $artifacts | Out-Null
$resolvedGodot = (Get-Command $Godot -ErrorAction Stop).Source
$capture = Start-Process -FilePath $resolvedGodot -ArgumentList '--path', ('"' + $repo + '/game"'), '--rendering-method', 'gl_compatibility', '--script', 'res://tests/capture_art_lab.gd' -WindowStyle Hidden -RedirectStandardOutput "$artifacts/capture.log" -RedirectStandardError "$artifacts/capture_errors.log" -PassThru
if (-not $capture.WaitForExit(60000)) { $capture.Kill(); throw 'Lab capture timed out' }
$output = (Get-Content "$artifacts/capture.log" -Raw) + (Get-Content "$artifacts/capture_errors.log" -Raw)
Write-Output $output
if ($capture.ExitCode -ne 0 -or $output -match 'SCRIPT ERROR|Parse Error|ERROR:') { throw 'Lab capture failed; graphical display required' }
$gallery = '<!doctype html><meta charset="utf-8"><title>G0.5-R lab</title><style>body{background:#fff2d5;color:#203d4a;font:18px system-ui;margin:24px}img{max-width:100%;max-height:86vh}</style><h1>G0.5-R · Laboratório técnico</h1><p>Sprites G0.5 provisórios. Fixtures e paleta não são layout, quantidade ou arte final aprovada.</p>'
foreach ($resolution in @('1920x1080','1080x1920')) {
    foreach ($layout in @('compact','dense','avenues')) {
        $file = "lab_${resolution}_${layout}.png"
        if (-not (Test-Path -LiteralPath "$artifacts/captures/$file")) { throw "Missing $file" }
        $gallery += "<h2>$resolution / $layout</h2><a href='captures/$file'><img src='captures/$file'></a>"
    }
}
Set-Content -LiteralPath "$artifacts/index.html" -Value $gallery -Encoding utf8
Write-Output "Gallery: $artifacts/index.html"
