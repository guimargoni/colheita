param([string]$Godot = "godot", [string]$Python = "python")
$ErrorActionPreference = "Stop"
$repo = Split-Path $PSScriptRoot -Parent
Push-Location $repo
try {
    & $Python tools/check_repository.py
    if ($LASTEXITCODE -ne 0) { throw "Repository checks failed" }
    $steps = @(
        @("--headless", "--path", "game", "--editor", "--quit"),
        @("--headless", "--path", "game", "--script", "res://tests/run_tests.gd"),
        @("--headless", "--path", "game", "--script", "res://tests/comparison_tests.gd"),
        @("--headless", "--path", "game", "--script", "res://tests/experience_tests.gd"),
        @("--headless", "--path", "game", "--script", "res://tests/art_tests.gd"),
        @("--headless", "--path", "game", "--script", "res://tests/art_standard_tests.gd"),
        @("--headless", "--path", "game", "--script", "res://tests/pilot_tests.gd"),
        @("--headless", "--path", "game", "--quit-after", "3")
    )
    foreach ($step in $steps) {
        $output = & $Godot @step 2>&1
        $code = $LASTEXITCODE
        $output | ForEach-Object { Write-Output "$_" }
        if ($code -ne 0 -or ($output -match "SCRIPT ERROR|Parse Error|ERROR:")) {
            throw "Godot validation failed"
        }
    }
} finally { Pop-Location }
