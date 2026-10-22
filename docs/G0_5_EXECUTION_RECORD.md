# G0.5 — registro de execução

2026-10-22. Branch: `foundation/g0-5-art-bible`. Sem push ou release.
G0.4 preservado em `e2f075f`; integração documental `b1873dd`, sem conflitos.
Commit de entrega G0.5 identificável por `git log -1 --oneline` nesta branch.

## Comandos e ferramentas executados

Da raiz do repositório, PowerShell:

```powershell
git status --short
git branch --show-current
git log --oneline
git fetch origin
git show origin/foundation/game-design:docs/ASSET_FIRST_PRODUCTION_POLICY.md
git add <arquivos específicos de G0.4>
git commit -m 'feat: preserve G0.4 local interactions and regression checks'
git switch -c foundation/g0-5-art-bible
git merge-tree --write-tree HEAD origin/foundation/game-design
git merge --no-ff origin/foundation/game-design -m 'docs: integrate approved asset-first production policy'
$godot = 'C:/Users/guilh/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'
$python = 'C:/Users/guilh/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $godot --headless --path game --editor --quit
& $godot --headless --path game --quit-after 3
& $godot --headless --path game --script res://tests/experience_tests.gd
& $godot --headless --path game --script res://tests/art_tests.gd
& $python tools/catalog_art.py
./tools/check.ps1 -Godot $godot -Python $python
./tools/capture_art.ps1 -Godot $godot
git diff --check
```

Leituras com Get-Content/rg e inspeções Git; imagegen (5 outputs), view_image e
Pillow somente para leitura de RGBA/dimensões; Copy-Item preservando fontes;
consulta web dos termos públicos OpenAI. Nenhuma edição de bitmap por código.
Uma colisão intermediária do nome GRASS com o renderer pai causou erro de parsing;
renomeada para TERRAIN_TEXTURE e capturas regeneradas. A captura com erro foi
encerrada pelos seus PIDs identificados, sem afetar editor/processos do usuário.

Validação final: Foundation PASS; G0.3 480, G0.4 15 e G0.5 418 checks sem falhas.
Editor/boot sem erros finais. Oito PNGs reais, duas resoluções, gallery/logs em
`.local/g0_5/` (ignorados). Amostra GPU RX 7600 ~5,6–5,8 ms mediana,
p95 ~6,4–6,8 ms; não medição móvel. Revisão visual feita nas capturas finais.

## Arquivos G0.5 criados/alterados

Inclui este registro. Metadados .import são configuração de import; os caches
.ctex/.godot não são versionados.

- `README.md`
- `docs/ART_BIBLE.md`
- `docs/ART_PRODUCTION_PLAN.md`
- `docs/ASSET_PIPELINE.md`
- `docs/AUDIO_PRODUCTION_PLAN.md`
- `docs/DECISIONS.md`
- `docs/DEVELOPMENT.md`
- `docs/G0_5_ART_PROMPTS.json`
- `docs/G0_5_ASSET_PROVENANCE.md`
- `docs/G0_5_EXECUTION_RECORD.md`
- `docs/G0_5_QUALITY_REPORT.md`
- `docs/G0_5_TERRAIN_PROMPT.json`
- `docs/G0_5_TEST_GUIDE.md`
- `docs/G0_5_UI_PROMPT.json`
- `docs/ROADMAP.md`
- `docs/runtime_assets_manifest.json`
- `game/assets/art/g05/animals_atlas_v1.png`
- `game/assets/art/g05/animals_atlas_v1.png.import`
- `game/assets/art/g05/crops_atlas_v1.png`
- `game/assets/art/g05/crops_atlas_v1.png.import`
- `game/assets/art/g05/environment_atlas_v1.png`
- `game/assets/art/g05/environment_atlas_v1.png.import`
- `game/assets/art/g05/terrain_atlas_v1.png`
- `game/assets/art/g05/terrain_atlas_v1.png.import`
- `game/assets/art/g05/ui_atlas_v1.png`
- `game/assets/art/g05/ui_atlas_v1.png.import`
- `game/data/art/audio_slots.json`
- `game/data/art/sample.json`
- `game/project.godot`
- `game/scenes/art/art_sample.gd`
- `game/scenes/art/art_sample.gd.uid`
- `game/scenes/art/art_sample.tscn`
- `game/scripts/audio/review_audio.gd`
- `game/scripts/audio/review_audio.gd.uid`
- `game/scripts/visual/art_garden.gd`
- `game/scripts/visual/art_garden.gd.uid`
- `game/tests/art_tests.gd`
- `game/tests/art_tests.gd.uid`
- `game/tests/capture_art.gd`
- `game/tests/capture_art.gd.uid`
- `tools/capture_art.ps1`
- `tools/catalog_art.py`
- `tools/check.ps1`
- `tools/check_repository.py`

## Arquivos do checkpoint G0.4 preservado

- `docs/G0_4_EXECUTION_RECORD.md`
- `game/data/prototype/local_garden.json`
- `game/project.godot`
- `game/scenes/experience/experience.gd`
- `game/scenes/experience/experience.gd.uid`
- `game/scenes/experience/experience.tscn`
- `game/scripts/audio/prototype_audio.gd`
- `game/scripts/audio/prototype_audio.gd.uid`
- `game/scripts/prototype/garden_gesture.gd`
- `game/scripts/prototype/garden_gesture.gd.uid`
- `game/scripts/prototype/local_garden.gd`
- `game/scripts/prototype/local_garden.gd.uid`
- `game/scripts/visual/garden_view.gd`
- `game/scripts/visual/garden_view.gd.uid`
- `game/tests/capture_experience.gd`
- `game/tests/capture_experience.gd.uid`
- `game/tests/experience_tests.gd`
- `game/tests/experience_tests.gd.uid`
- `tools/capture_experience.ps1`
- `tools/check.ps1`

A integração remota acrescentou apenas `docs/ASSET_FIRST_PRODUCTION_POLICY.md`.
Arquivos históricos de assets permanecem byte a byte; nenhuma extração/contact
sheet, cache, captura ou asset adicional de pack pendente é parte dos commits.

## Pendências e limite

Avaliação artística, normalização pixel/pivô, áudio final, dispositivo físico e
revisão de release/IP/contrato. UX_GAME_FEEL.md e FARM_VISUAL_SCALE.md ausentes
nas árvores inspecionadas. Detalhes em G0_5_QUALITY_REPORT.md e planos de produção.
G0.5 técnico PASS da amostra, artístico/release pendente. Parar aqui; nenhum G1.
