param([string]$Godot = "godot")
$ErrorActionPreference = "Stop"
$repo = Split-Path $PSScriptRoot -Parent
$artifacts = Join-Path $repo '.local/g0_4'
New-Item -ItemType Directory -Force $artifacts | Out-Null
Push-Location $repo
try {
    $resolvedGodot = (Get-Command $Godot -ErrorAction Stop).Source
    if ($IsWindows) {
        $capture = Start-Process -FilePath $resolvedGodot -ArgumentList '--path', ('"' + $repo + '/game"'), '--rendering-method', 'gl_compatibility', '--script', 'res://tests/capture_experience.gd' -WindowStyle Hidden -RedirectStandardOutput "$artifacts/capture.log" -RedirectStandardError "$artifacts/capture_errors.log" -Wait -PassThru
        $code = $capture.ExitCode
        $output = (Get-Content "$artifacts/capture.log" -Raw) + (Get-Content "$artifacts/capture_errors.log" -Raw)
    } else {
        $output = (& $resolvedGodot --path game --rendering-method gl_compatibility --script res://tests/capture_experience.gd 2>&1 | Out-String)
        $code = $LASTEXITCODE
    }
    Write-Output $output
    if ($code -ne 0 -or $output -match 'SCRIPT ERROR|Parse Error|ERROR:') {
        throw 'Godot capture failed (a graphical display/GPU is required; do not use --headless)'
    }
    $gallery = '<!doctype html><meta charset="utf-8"><title>Colheita G0.4</title><style>body{background:#e6edd6;color:#29463c;font:18px system-ui;margin:32px}img{max-width:100%;max-height:88vh}a{color:#29463c}</style><h1>G0.4 / Experiência visual em avaliação</h1><p>Capturas reais do Godot; conteúdo original. Gate aguardando revisão humana.</p>'
    foreach ($resolution in @('1920x1080','1080x1920')) {
        foreach ($suffix in @('','_actions','_settings')) {
            $file = "experience_${resolution}${suffix}.png"
            if (-not (Test-Path -LiteralPath "$artifacts/captures/$file")) { throw "Missing capture: $file" }
            $gallery += "<h2>$file</h2><a href='captures/$file'><img src='captures/$file'></a>"
        }
    }
    Set-Content -LiteralPath "$artifacts/index.html" -Value $gallery -Encoding utf8
    Write-Output "Review gallery: $artifacts/index.html"
} finally { Pop-Location }
