# G1.V — Registro de execução

Data: 2026-10-26. Branch `experiment/g1v-visual-gamefeel`; base preservada `c326268` (G1.5). Commit de entrega: consultar `git log -1` nesta branch; este registro integra o próprio commit.

**G1.V técnico: PASS. G1.V direção visual: PENDING HUMAN DECISION.** Sem avanço para G1.6/G2, sem push, sem tag de aprovação artística. Nenhum conflito Git.

## Trabalho e verificações

- Leitura do briefing anexado e de AGENTS, arquitetura, GDD, roadmap, UX/framing, Art Bible, guia de animação, áudio e documentação/implementação G1.5 pertinente.
- `git status --short`, inspeção de código/arquivos com `Get-Content`, `rg`; `git switch -c experiment/g1v-visual-gamefeel`.
- Implementação apenas em cena/scripts/dados próprios G1.V, documentação e ferramentas. Nenhuma geração nova de imagem, dependência, credencial ou arquivo de asset comercial introduzido. Ícones nativos originais em código.
- Godot `--headless --path game --editor --quit`: importação sem parsing errors.
- Smoke `--headless --path game res://scenes/farm/g1v/farm.tscn --quit-after 12 -- --g1v-fast --g1v-save=user://g1v_smoke_isolated.json`: save exclusivo de teste.
- `./tools/check.ps1 -Godot <Godot console> -Python <Python>`: rodada final completa PASS, editor, integridade do repositório, G0–G1.5 e 88 checks G1.V. Log privado `.local/g1v/check_final.log`.
- `Godot --headless --path game --script res://tests/living_farm_tests.gd`: 88 checks finais PASS, incluindo execução das transições, compras em lote/vendas parciais e trajetórias analíticas. Log `.local/g1v/visual_tests.log`.
- `./tools/capture_living_farm.ps1 -Godot <Godot console> -Python <Python>`: 12 screenshots e 144 frames GPU reais; `tools/gallery_living_farm.py` codifica dois GIFs e HTML local. Sessão gráfica Compatibility / RX 7600. Capturas inspecionadas em desktop e retrato; arquivos sem retoque. Não são prova de aprovação artística ou de hardware móvel.
- Benchmark `--path game --rendering-method gl_compatibility --script res://tests/benchmark_living_farm.gd`: 4 execuções de 240 frames, aquecimento de 30, intensidade 100%. Relatório `G1V_PERFORMANCE.md`, dados privados `.local/g1v/performance.json`. Não usar duração do GIF como FPS.
- `powershell.exe -NoProfile -File tools/play_living_farm.ps1 -PrintCommand -Fast`: launcher validado com Windows PowerShell normal. Bloqueio do AuthorizationManager somente no sandbox foi resolvido executando normalmente fora dele, sem modificar ExecutionPolicy.
- Uma chamada anterior inteira foi impedida pela revisão automática devido ao limite de uso; não havia sido executada. A retomada conferiu o estado e executou os passos faltantes.
- `git diff --exit-code c326268 -- docs/ART_BIBLE.md game/project.godot game/scenes/farm/g15 game/scripts/domain game/scripts/services game/data/farming game/assets`: nenhum delta. `git diff --name-only c326268 -- game` antes do staging: nenhuma fonte antiga modificada.
- `python tools/check_repository.py`, `git diff --check`, `git diff --cached --check`: integridade, metadados, quarentena e padrões básicos de segredos; whitespace. Não equivalem a auditoria de segurança.
- `git add` com caminhos explícitos e `git commit` da entrega. `.local/`, saves, PNGs/GIFs e caches ficam fora do commit.

Executáveis locais: Godot `C:/Users/guilh/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe`; Python `C:/Users/guilh/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.

## Pendências

Sem blocker técnico conhecido do experimento local. Escolha A/B e game feel dependem do diretor. Produção artística final, licença/distribuição dos assets já em revisão, áudio, celular físico, desempenho móvel, safe areas e segurança online continuam pendentes. Não inferir aprovação humana do G1.4/G1.5. Guia exato em `G1V_TEST_GUIDE.md`; limitações e materiais em `G1V_VISUAL_COMPARISON.md`.

## Arquivos criados/alterados

- `JOGAR_G1V_TESTE.cmd`
- `README.md`
- `docs/DECISIONS.md`
- `docs/G1V_EXECUTION_RECORD.md`
- `docs/G1V_PERFORMANCE.md`
- `docs/G1V_TECHNICAL_REPORT.md`
- `docs/G1V_TEST_GUIDE.md`
- `docs/G1V_VISUAL_COMPARISON.md`
- `docs/GDD.md`
- `docs/ROADMAP.md`
- `game/data/visual/g1v/feel.json`
- `game/scenes/farm/g1v/farm.gd`
- `game/scenes/farm/g1v/farm.gd.uid`
- `game/scenes/farm/g1v/farm.tscn`
- `game/scripts/ui/g1v/line_icon.gd`
- `game/scripts/ui/g1v/line_icon.gd.uid`
- `game/scripts/ui/g1v/living_economy_ui.gd`
- `game/scripts/ui/g1v/living_economy_ui.gd.uid`
- `game/scripts/ui/g1v/living_kit.gd`
- `game/scripts/ui/g1v/living_kit.gd.uid`
- `game/scripts/visual/g1v/demo_setup.gd`
- `game/scripts/visual/g1v/demo_setup.gd.uid`
- `game/scripts/visual/g1v/living_view.gd`
- `game/scripts/visual/g1v/living_view.gd.uid`
- `game/scripts/visual/g1v/presentation.gdshader`
- `game/scripts/visual/g1v/presentation.gdshader.uid`
- `game/tests/benchmark_living_farm.gd`
- `game/tests/benchmark_living_farm.gd.uid`
- `game/tests/capture_living_farm.gd`
- `game/tests/capture_living_farm.gd.uid`
- `game/tests/living_farm_tests.gd`
- `game/tests/living_farm_tests.gd.uid`
- `tools/capture_living_farm.ps1`
- `tools/check.ps1`
- `tools/gallery_living_farm.py`
- `tools/play_living_farm.ps1`
