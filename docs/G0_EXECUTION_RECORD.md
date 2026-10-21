# G0 execution record — 2026-10-21

Historical record of the initial G0.1 / G0.2 implementation. No commit, push or PR occurred during that initial delivery. The director subsequently accepted both gates technically and authorized dedicated-branch commits; the follow-up integration/review is recorded in docs/FOUNDATION_DIRECTION_REVIEW.md. No gameplay, backend connection or G0.3 work was performed.

## Checks and observed results

- Godot reports `4.7.2.stable.official.ed1daf0bf`.
- `tools/check.ps1`: PASS. Repository structure/manifest/quarantine/whitespace/baseline secret patterns PASS; editor import/parser PASS; integration harness PASS; project headless boot PASS.
- The same Godot import, integration and boot commands passed against `.local/clean_validation/game`, copied without `.godot` or local config and without third-party art.
- `git diff --check`: PASS.
- SHA-256 of each original archive matches the corresponding blob from `git show HEAD:<archive>`.
- 6,158 extracted files inventoried, 5,946 images fully decoded; 206 effect atlas rectangle maps validated; 42 contact sheets generated and visually inspected with source sheets. Static pose review only; full animation playback approval is deferred.
- No live GitHub Actions run was triggered. CI configuration awaits first remote run.
- No human creative acceptance has been inferred. License and existing archive distribution risks are in the audit report.

Initial attempts from the parent workspace found no documents; inspection located the repository in `colheita/`. Main had no design docs; all seven required documents were read fully from `origin/foundation/game-design` before the branch switch and before changes. Initial sandbox Godot runs encountered editor APPDATA write/safe-save errors. A temporary process-local APPDATA redirected run still reported safe-save errors. Final checks were rerun with approved normal filesystem access and no errors. No antivirus or global safe-save setting was changed.

## Executed command record

All subsequent paths below are relative to repository root. PowerShell command families are grouped to avoid repeating large document/script bodies. File creation used PowerShell UTF-8 here-strings and a temporary Python bootstrap writer (removed after execution).

Read-only discovery:

```powershell
Get-Content AGENTS.md
Get-Content docs/GDD.md
Get-Content docs/TECHNICAL_ARCHITECTURE.md
Get-Content docs/ROADMAP.md
Get-Content docs/ASSET_PIPELINE.md
Get-Content docs/assets_manifest.csv
Get-Content docs/DECISIONS.md
Get-ChildItem -Force
rg --files -g AGENTS.md -g ROADMAP.md -g '*zip' -g '*7z' -g '*rar'
rg --files -g '*.md' -g '*.csv'
git status --short
git remote -v
git branch -a
git log -5 --oneline
git ls-tree -r --name-only HEAD
git ls-tree -r --name-only origin/foundation/game-design
# Each of the seven mandatory paths was read with:
git show origin/foundation/game-design:<path>
```

Working branch:

```powershell
git switch -c foundation/g0-bootstrap-audit origin/foundation/game-design
```

Tool discovery used `Get-Command` for Godot/Python/tar/7z/unrar, selected install paths and the desktop dependency-path discovery tool. The Python WindowsApps alias was unavailable; the bundled executable was used. Pillow 12.3.0 was already available; `rarfile` was absent and not installed. Native tar handled both RARs.

Extraction and audit:

```powershell
tar -tf 'Farm RPG FREE 16x16 - Tiny Asset Pack.rar'
tar -tf 'Harvest Sumer Free Ver. Pack.rar'
New-Item -ItemType Directory -Force .local/asset_audit/extracted
tar -xf 'Farm RPG FREE 16x16 - Tiny Asset Pack.rar' -C .local/asset_audit/extracted
tar -xf 'Harvest Sumer Free Ver. Pack.rar' -C .local/asset_audit/extracted
# Python zipfile initially listed and extracted the ZIP; the reproducible script repeats all extractions.
& $python tools/audit_assets.py
Get-Content '.local/asset_audit/extracted/Harvest Sumer Free Ver. Pack/read_me Free Ver..txt'
Get-Content '.local/asset_audit/extracted/Super Pixel Effects Gigapack (Free Version)/license.txt'
Get-Content '.local/asset_audit/extracted/Super Pixel Effects Gigapack (Free Version)/guide.txt'
# Also inspected example spritesheet.txt metadata and complete source inventory/counts.
```

Browser source checks opened the three author URLs in `ASSET_LICENSE_RECORD.md`; the unTied full-license link failed to load. No art was downloaded from the web. Contact sheets and local review montages were viewed via local image tools. A temporary inline Pillow command created `.local/asset_audit/review_0.png` through `review_5.png` as inspection aids; these do not replace the 42 original sheets.

Final successful validation (exact executables on this machine):

```powershell
$godot = 'C:\Users\guilh\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
$python = 'C:\Users\guilh\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $godot --version
& $python tools/check_repository.py
./tools/check.ps1 -Godot $godot -Python $python
# check.ps1 executes these three commands and rejects errors even with exit code zero:
& $godot --headless --path game --editor --quit
& $godot --headless --path game --script res://tests/run_tests.gd
& $godot --headless --path game --quit-after 3
# Repeat on clean resource copy made via Python shutil.copytree excluding .godot/local.cfg:
& $godot --headless --path .local/clean_validation/game --editor --quit
& $godot --headless --path .local/clean_validation/game --script res://tests/run_tests.gd
& $godot --headless --path .local/clean_validation/game --quit-after 3
git diff --check
git status --short --untracked-files=all
git check-ignore .local/asset_audit/index.html
```

Additional inline Python checks used csv/Counter for counts and SHA-256 against `git show HEAD:<archive>` for unchanged original verification. No package installation was needed. `tools/bootstrap_temp.py` existed only to write the new bootstrap files and was deleted after use; final tooling is listed below.

## All created/changed repository files

The list below is generated from Git's tracked diff and untracked file inventory. Engine-generated `.gd.uid` files are retained for stable resource identity. `.gitkeep` files preserve architectural directories without implementing those systems.

- .editorconfig
- .gitattributes
- .github/workflows/quality.yml
- .gitignore
- README.md
- backend/supabase/functions/.gitkeep
- backend/supabase/migrations/.gitkeep
- backend/supabase/seed/.gitkeep
- docs/ASSET_AUDIT_REPORT.md
- docs/ASSET_LICENSE_RECORD.md
- docs/DECISIONS.md
- docs/DEVELOPMENT.md
- docs/G0_EXECUTION_RECORD.md
- docs/asset_archive_hashes.json
- docs/asset_audit_summary.json
- docs/asset_file_inventory.csv
- docs/asset_pack_licenses.csv
- docs/assets_manifest.csv
- game/assets/art/.gitkeep
- game/assets/audio/.gitkeep
- game/assets/fonts/.gitkeep
- game/autoload/app.gd
- game/autoload/app.gd.uid
- game/config/local.example.cfg
- game/data/animals/.gitkeep
- game/data/crops/.gitkeep
- game/data/items/.gitkeep
- game/data/levels/.gitkeep
- game/data/quests/.gitkeep
- game/project.godot
- game/scenes/boot/boot.gd
- game/scenes/boot/boot.gd.uid
- game/scenes/boot/boot.tscn
- game/scenes/farm/.gitkeep
- game/scenes/inventory/.gitkeep
- game/scenes/profile/.gitkeep
- game/scenes/settings/.gitkeep
- game/scenes/shop/.gitkeep
- game/scenes/social/.gitkeep
- game/scripts/api/.gitkeep
- game/scripts/domain/.gitkeep
- game/scripts/services/.gitkeep
- game/scripts/services/content_service.gd
- game/scripts/services/content_service.gd.uid
- game/scripts/ui/.gitkeep
- game/scripts/utils/.gitkeep
- game/tests/run_tests.gd
- game/tests/run_tests.gd.uid
- tools/audit_assets.py
- tools/check.ps1
- tools/check_repository.py
- tools/requirements-audit.txt

Local ignored artifacts: .local/asset_audit/extracted/ (6,158 unchanged extracted files), contact_sheets/ (42 PNGs), index.html, six review montages; .local/clean_validation/game/; temporary sandbox editor data under .local/godot-user/; Godot import caches under game/.godot/. These are excluded from Git and are not runtime art.
