param([string]$Godot = "godot")
$ErrorActionPreference = "Stop"
$repo = Split-Path $PSScriptRoot -Parent
$artifacts = Join-Path $repo '.local/g0_3'
New-Item -ItemType Directory -Force $artifacts | Out-Null
Push-Location $repo
try {
    $resolvedGodot = (Get-Command $Godot -ErrorAction Stop).Source
    if ($IsWindows) {
        $capture = Start-Process -FilePath $resolvedGodot -ArgumentList '--path', ('"' + $repo + '/game"'), '--rendering-method', 'gl_compatibility', '--script', 'res://tests/capture_visuals.gd' -WindowStyle Hidden -RedirectStandardOutput "$artifacts/capture.log" -RedirectStandardError "$artifacts/capture_errors.log" -Wait -PassThru
        $code = $capture.ExitCode
        $output = (Get-Content "$artifacts/capture.log" -Raw) + (Get-Content "$artifacts/capture_errors.log" -Raw)
    } else {
        $output = (& $resolvedGodot --path game --rendering-method gl_compatibility --script res://tests/capture_visuals.gd 2>&1 | Out-String)
        $code = $LASTEXITCODE
    }
    Write-Output $output
    if ($code -ne 0 -or $output -match 'SCRIPT ERROR|Parse Error|ERROR:') {
        throw 'Godot capture failed (a graphical display/GPU is required; do not use --headless)'
    }
    $names = @('menu','a','b')
    $resolutions = @('1920x1080','1080x1920')
    $gallery = '<!doctype html><meta charset="utf-8"><title>Colheita G0.3</title><style>body{background:#e7ead3;color:#29463c;font:18px system-ui;margin:32px}img{max-width:100%;max-height:85vh;border-radius:10px}section{margin:32px 0}a{color:#29463c}</style><h1>G0.3 / Direção visual em avaliação</h1><p>Cenas reais do Godot. A: isométrica; B: oblíqua. Placeholders originais; aprovação humana pendente.</p>'
    foreach ($resolution in $resolutions) {
        foreach ($name in $names) {
            $files = @("proposal_${name}_${resolution}.png")
            if ($name -ne 'menu') { $files += "proposal_${name}_${resolution}_detail.png" }
            foreach ($file in $files) {
                if (-not (Test-Path -LiteralPath "$artifacts/captures/$file")) { throw "Missing capture: $file" }
                $gallery += "<section><h2>$file</h2><a href='captures/$file'><img src='captures/$file' loading='lazy'></a></section>"
            }
        }
    }
    Set-Content -LiteralPath "$artifacts/index.html" -Value $gallery -Encoding utf8
    Write-Output "Review gallery: $artifacts/index.html"
} finally { Pop-Location }
