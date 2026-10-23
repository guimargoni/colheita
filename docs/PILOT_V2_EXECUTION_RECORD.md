# Piloto artístico independente v2 — registro de execução

2026-10-23. Branch `foundation/g0-5r-art-sample-v2`; base limpa `258bdad`.
Escopo autorizado: pequena amostra artística nova sob Cozy Pixel Art — Fazenda
Viva, sem substituir G0.4/G0.5/G0.5-R, sem G1, sem push.

## Preservação verificada

`git diff --exit-code 258bdad -- game/project.godot game/scenes/experience
game/scenes/art/art_sample.gd game/scenes/art/art_lab.gd
game/scripts/visual/art_garden.gd game/scripts/visual/art_lab_view.gd
game/assets/art/g05 docs/ART_BIBLE.md game/data/art/visual_standard.json`
retornou zero sem diferenças. Entrada F5, normas e sprites antigos preservados.
Somente uma nova cena F6 e novos arquivos/controles por composição. Decisão nova
adicionada ao registro existente, sem reescrever aprovações anteriores.

## Evidências

- Estrutura/quarentena/padrões básicos de segredos e hashes: PASS.
- Foundation PASS; G0.3 480, G0.4 15, G0.5 418, G0.5-R 1.148 checks: PASS.
- Nova amostra: **154 checks PASS**, nas duas resoluções, com inputs pelo viewport.
- Import/editor, boot antigo e cena nova: sem erros finais de parsing/runtime.
- **10 capturas reais**, 1920×1080 e 1080×1920: fazenda, colheita em 40/180/360 ms
  e painel. Inspecionadas sem retoque ou maquiagem promocional.
- Fontes geradas e alpha preservados; quatro PNGs originais novos em
  `game/assets/art/g05r_pilot/`, prompts exatos e manifesto versionados.
- Reuso de grama original própria em revisão; nenhum arquivo adicional de pack.

Capturas, logs e galeria em `.local/pilot_v2/` ignorados. Não há novo benchmark
Android/iOS, teste de aparelho físico ou export de loja. Testes não aprovam arte.

## Comandos e ferramentas

Leituras de AGENTS/normas/relatórios, Git status/log/diff, skill imagegen, geração
built-in e view_image. Copy-Item preservou os outputs no workspace. Pillow foi
usado somente para ler dimensões/alpha e medir um recorte; não retocou imagens.
Quatro chamadas imagegen (três atlas e uma árvore isolada), sem CLI/API key.

```powershell
git switch -c foundation/g0-5r-art-sample-v2
$godot = 'C:/Users/guilh/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'
$python = 'C:/Users/guilh/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $python tools/catalog_pilot.py
& $godot --headless --path game --editor --quit
& $godot --headless --path game res://scenes/art/pilot/pilot.tscn --quit-after 3
& $godot --headless --path game --script res://tests/pilot_tests.gd
./tools/check.ps1 -Godot $godot -Python $python
./tools/capture_pilot.ps1 -Godot $godot
git diff --check
```

Foram repetidas capturas após corrigir molduras UI, enquadramento, indicador de
água e substituir somente a árvore da nova amostra por saída isolada sem fragmentos.
O tile novo de grama foi rejeitado para repetição pelo ruído de bordas e preservado
na fonte. Nada foi corrigido com formas geométricas substituindo a arte do mundo.

## Arquivos criados/alterados

- `README.md`
- `docs/ASSET_PIPELINE.md`
- `docs/DECISIONS.md`
- `docs/PILOT_V2_EXECUTION_RECORD.md`
- `docs/PILOT_V2_PROMPTS.json`
- `docs/PILOT_V2_PROVENANCE.md`
- `docs/PILOT_V2_REVIEW.md`
- `docs/PILOT_V2_TEST_GUIDE.md`
- `docs/pilot_assets_manifest.json`
- `game/assets/art/g05r_pilot/crops_fx_v1.png`
- `game/assets/art/g05r_pilot/crops_fx_v1.png.import`
- `game/assets/art/g05r_pilot/environment_v1.png`
- `game/assets/art/g05r_pilot/environment_v1.png.import`
- `game/assets/art/g05r_pilot/tree_v2.png`
- `game/assets/art/g05r_pilot/tree_v2.png.import`
- `game/assets/art/g05r_pilot/ui_v1.png`
- `game/assets/art/g05r_pilot/ui_v1.png.import`
- `game/data/art/pilot/sample_v2.json`
- `game/scenes/art/pilot/pilot.gd`
- `game/scenes/art/pilot/pilot.gd.uid`
- `game/scenes/art/pilot/pilot.tscn`
- `game/scripts/ui/pilot_ui.gd`
- `game/scripts/ui/pilot_ui.gd.uid`
- `game/scripts/visual/pilot_view.gd`
- `game/scripts/visual/pilot_view.gd.uid`
- `game/tests/capture_pilot.gd`
- `game/tests/capture_pilot.gd.uid`
- `game/tests/pilot_tests.gd`
- `game/tests/pilot_tests.gd.uid`
- `tools/capture_pilot.ps1`
- `tools/catalog_pilot.py`
- `tools/check.ps1`
- `tools/check_repository.py`

Import .png.import e .uid são metadados; caches .ctex/.godot e imagens de captura
não são versionados. Prompts em PILOT_V2_PROMPTS.json; base de direitos em
PILOT_V2_PROVENANCE.md. Nenhum asset recebe aprovação de release.

## Avaliação e parada

Executável entregue para avaliação técnica/artística, sem erro de boot conhecido.
**Aprovação artística/release pendente**. A geração não garantiu pixels nativos,
grade perfeita ou metadados anatômicos; matriz 32×16 é do renderer, não um selo de
conformidade das fontes. Normalização/limpeza, kit de bordas, humano para escala,
fonte final e QA físico são pendentes documentados em PILOT_V2_REVIEW.md.
Áudio não produzido e não requerido como nova entrega nesta rodada.

Abrir `game/scenes/art/pilot/pilot.tscn` e F6; instruções completas em
PILOT_V2_TEST_GUIDE.md. Parar aqui, sem G1 ou substituição definitiva.
