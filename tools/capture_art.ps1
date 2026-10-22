param([string]$Godot = "godot")
$ErrorActionPreference = "Stop"
$repo = Split-Path $PSScriptRoot -Parent
$artifacts = Join-Path $repo '.local/g0_5'
New-Item -ItemType Directory -Force $artifacts | Out-Null
$resolvedGodot = (Get-Command $Godot -ErrorAction Stop).Source
$capture = Start-Process -FilePath $resolvedGodot -ArgumentList '--path', ('"' + $repo + '/game"'), '--rendering-method', 'gl_compatibility', '--script', 'res://tests/capture_art.gd' -WindowStyle Hidden -RedirectStandardOutput "$artifacts/capture.log" -RedirectStandardError "$artifacts/capture_errors.log" -Wait -PassThru
$output = (Get-Content "$artifacts/capture.log" -Raw) + (Get-Content "$artifacts/capture_errors.log" -Raw)
Write-Output $output
if ($capture.ExitCode -ne 0 -or $output -match 'SCRIPT ERROR|Parse Error|ERROR:') { throw 'Godot capture failed; a graphical display is required' }
$gallery = '<!doctype html><meta charset="utf-8"><title>G0.5 Art review</title><style>body{background:#faf2d9;color:#29463c;font:18px system-ui;margin:32px}img{max-width:100%;max-height:86vh}section{display:flex;flex-wrap:wrap;gap:20px}figure{margin:0;max-width:47%}</style><h1>Jardim do Sol · G0.5</h1><p>Capturas reais. Antes: renderer geométrico G0.4 no recorte controlado de quatro canteiros. Depois: sprites G0.5. Mesmos anchors/câmera/estado/HUD. Não é captura histórica integral do G0.4. Arte em revisão; áudio final pendente.</p>'
foreach ($resolution in @('1920x1080','1080x1920')) {
    $gallery += "<h2>$resolution</h2><section>"
    foreach ($suffix in @('before','after','halloween','ui_kit')) {
        $file = "art_${resolution}_${suffix}.png"
        if (-not (Test-Path -LiteralPath "$artifacts/captures/$file")) { throw "Missing capture: $file" }
        $gallery += "<figure><figcaption>$suffix</figcaption><a href='captures/$file'><img src='captures/$file'></a></figure>"
    }
    $gallery += '</section>'
}
Set-Content -LiteralPath "$artifacts/index.html" -Value $gallery -Encoding utf8
Write-Output "Review gallery: $artifacts/index.html"
