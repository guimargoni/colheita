# G1.5 — Registro de execução

2026-10-26. Branch `feature/g1-5-historical-crops`; base `a27e6a8`. Commit de entrega: consultar `git log -1` nesta branch (este registro integra o próprio commit).

## Resultado

G1.5 técnico: PASS. G1.5 experiência: PENDING HUMAN APPROVAL. Sem conflito Git; sem push ou tag de aprovação humana. G1.4 continua com validação humana formal pendente. Sem avanço para G1.6/G2.

## Comandos e ferramentas executados

- Leitura de AGENTS, documentação atual pertinente, briefing e código; `git status`, `git log`, `git switch -c feature/g1-5-historical-crops`, buscas `rg`.
- Pesquisa web nas fontes históricas citadas no catálogo; nenhuma arte histórica baixada.
- Uma geração raster original pelo image_gen integrado, conforme skill imagegen; prompt, hash e procedência registrados. Análise de alpha/dimensões com Pillow, sem edição do PNG.
- `./tools/check.ps1 -Godot <Godot 4.7.2 console> -Python <Python local>`: editor sem erros de parsing, checks de repositório e suites anteriores passaram, mais 128 checks G1.5 então existentes.
- `Godot --headless --path game --script res://tests/cultures_tests.gd`: última versão ampliada, 136 checks, zero falhas.
- `Godot --headless --path game --script res://tests/simulate_cultures.gd` e `python tools/report_cultures_balance.py`: 30 cenários, relatório gerado. Wrapper equivalente `tools/simulate_cultures.ps1` disponível.
- `./tools/capture_cultures.ps1 -Godot <Godot 4.7.2 console> -Python <Python local>`: 20 capturas GPU reais, 1920×1080 / 1080×1920, zero erros; galeria gerada. Capturas finais de recuperação retrato e loja especial desktop inspecionadas visualmente.
- Importador executado em subprocessos pela suite para schemas 1–4, destinos novos e origem preservada. Launcher validado com `-PrintCommand`, inclusive save customizado.
- `python tools/check_repository.py`: PASS, 5946 gráficos e 6158 fontes inventariados no checkout local; estrutura, metadados, quarentena e padrões básicos de segredos verificados.
- `git diff --exit-code a27e6a8 -- <cenas, dados, domínio e serviços legados>`: nenhum delta no runtime anterior; `git diff --check` e verificação de staging.
- `git add` somente fontes/configuração/documentação autorizadas; `git commit`. Caches, saves, logs, capturas e HTML gerados permanecem ignorados em `.local/`.

Executáveis usados: Godot `C:/Users/guilh/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe`; Python `C:/Users/guilh/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`. Algumas chamadas exigiram execução fora do sandbox para diretórios normais do Godot em AppData; sem alteração de ExecutionPolicy, download de dependência ou credenciais.

## Pendências e limites

Sem blocker técnico conhecido para o protótipo local. Revisão humana de mecânicas, arte, novos valores, fontes históricas menos confiáveis e distribuição/licença do material gerado; acabamento de sprites e áudio final; teste em celular físico, avaliação de desempenho e segurança/autoridade online continuam pendentes. Os checks de padrões não substituem auditoria de segurança. Resultados e passos reproduzíveis estão nos relatórios técnicos, artístico, histórico, balanceamento e guia.

## Arquivos criados/alterados

- `JOGAR_G15_TESTE.cmd`
- `README.md`
- `docs/DECISIONS.md`
- `docs/G15_ART_REPORT.md`
- `docs/G15_BALANCE.md`
- `docs/G15_BALANCE_RESULTS.md`
- `docs/G15_EXECUTION_RECORD.md`
- `docs/G15_HISTORICAL_CATALOG.md`
- `docs/G15_PROMPTS.json`
- `docs/G15_TECHNICAL_REPORT.md`
- `docs/G15_TEST_GUIDE.md`
- `docs/GDD.md`
- `docs/ROADMAP.md`
- `docs/g15_assets_manifest.json`
- `game/assets/art/g15/cultures_v1.png`
- `game/assets/art/g15/cultures_v1.png.import`
- `game/data/farming/g15/art.json`
- `game/data/farming/g15/care.json`
- `game/data/farming/g15/crops.json`
- `game/data/farming/g15/economy.json`
- `game/data/farming/g15/events.json`
- `game/data/farming/g15/fertilizers.json`
- `game/scenes/farm/g15/farm.gd`
- `game/scenes/farm/g15/farm.gd.uid`
- `game/scenes/farm/g15/farm.tscn`
- `game/scripts/domain/cultures/culture_catalog.gd`
- `game/scripts/domain/cultures/culture_catalog.gd.uid`
- `game/scripts/domain/cultures/culture_economy.gd`
- `game/scripts/domain/cultures/culture_economy.gd.uid`
- `game/scripts/domain/cultures/culture_land.gd`
- `game/scripts/domain/cultures/culture_land.gd.uid`
- `game/scripts/domain/cultures/culture_state.gd`
- `game/scripts/domain/cultures/culture_state.gd.uid`
- `game/scripts/domain/cultures/repeat_rules.gd`
- `game/scripts/domain/cultures/repeat_rules.gd.uid`
- `game/scripts/domain/cultures/save_migration.gd`
- `game/scripts/domain/cultures/save_migration.gd.uid`
- `game/scripts/domain/cultures/season_rules.gd`
- `game/scripts/domain/cultures/season_rules.gd.uid`
- `game/scripts/services/cultures/culture_clock.gd`
- `game/scripts/services/cultures/culture_clock.gd.uid`
- `game/scripts/services/cultures/local_culture_service.gd`
- `game/scripts/services/cultures/local_culture_service.gd.uid`
- `game/scripts/ui/cultures/culture_presenter.gd`
- `game/scripts/ui/cultures/culture_presenter.gd.uid`
- `game/scripts/ui/cultures/culture_ui.gd`
- `game/scripts/ui/cultures/culture_ui.gd.uid`
- `game/scripts/visual/g15_view.gd`
- `game/scripts/visual/g15_view.gd.uid`
- `game/tests/capture_cultures.gd`
- `game/tests/capture_cultures.gd.uid`
- `game/tests/cultures_tests.gd`
- `game/tests/cultures_tests.gd.uid`
- `game/tests/import_cultures_save.gd`
- `game/tests/import_cultures_save.gd.uid`
- `game/tests/simulate_cultures.gd`
- `game/tests/simulate_cultures.gd.uid`
- `tools/capture_cultures.ps1`
- `tools/check.ps1`
- `tools/check_repository.py`
- `tools/gallery_cultures.py`
- `tools/import_cultures.ps1`
- `tools/play_cultures.ps1`
- `tools/report_cultures_balance.py`
- `tools/simulate_cultures.ps1`
