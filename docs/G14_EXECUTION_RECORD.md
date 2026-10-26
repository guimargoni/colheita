# G1.4 — fechamento da execução

Fechamento em 2026-10-26, após interrupção por limite de uso. Implementação e
artefatos foram preservados em disco. Branch `feature/g1-4-land-expansion`.
Base funcional `62112b1`; integração histórica commitada em `56fc39f`.
Marco G1.3: `milestone/g1.3-mechanics-approved`, anterior ao novo runtime.

**G1.4 técnico: PASS. G1.4 experiência: PENDING HUMAN APPROVAL.**

A finalização acrescentou relatório técnico e atualizou README/GDD/roadmap, sem
nova mecânica. Os resultados técnicos abaixo são da execução já concluída;
no fechamento documental foram repetidos check_repository.py e diff --check,
conferidos logs, preservação dos caminhos anteriores e argumentos do iniciador.

## Resultados e comandos

Suíte `tools/check.ps1 -Godot CAMINHO -Python CAMINHO`: fundação e todos os gates
anteriores PASS; G1.4 99 checks, sem erros finais de parsing/runtime reportados.
Quatro processos earn/unlock/replay/plant verificam reinício, débito único e cultivo.
Simulação `godot --headless --path game --script res://tests/simulate_land.gd`:
12 cenários concluídos. `python tools/report_land_balance.py` gerou resultados.
O wrapper `tools/simulate_land.ps1` reproduz esses dois componentes.
`tools/capture_land.ps1`: 16 capturas reais PC/retrato, sem erro final no log.
`tools/play_land.ps1 -Fast -PrintCommand`: argumentos do Godot/cena/flag verificados.

Inspeção e integração: Get-Content, rg, git status/branch/log/remote/ls-tree/show,
`git fetch origin foundation/game-design`, diffs por três pontos e cópia byte a
byte dos dois documentos novos. Sem merge/cherry-pick/conflito. Rede restrita
falhou na primeira tentativa; fetch autorizado funcionou. A auditoria não foi
inventada nem suas URLs certificadas novamente. Registro completo de origem em
G14_HISTORICAL_INTEGRATION.md. Nenhum push.

Durante desenvolvimento foram corrigidos comparação de arrays JSON int/float,
fixture sem sementes, temporização do botão e fingerprint numérico após reinício.
Os resultados acima são posteriores às correções. Processos de teste com erro
foram encerrados; nenhum save do jogador foi usado para simulação/captura.

Preservação: `git diff --exit-code 62112b1 --` nos caminhos de runtime anteriores
(project.godot, assets, cenas, catálogos, domínios, serviços, UI, renderer e testes
G1.1–G1.3) sem diferenças. Nenhum PNG/áudio novo ou asset de licença pendente foi
adicionado. Capturas, logs, JSON bruto, HTML, saves e caches ficam ignorados em
`.local/g14/`/diretórios próprios do Godot, fora do commit.

## Arquivos da implementação e fechamento

Criados:

- `JOGAR_G14_TESTE.cmd`.
- `docs/G14_BALANCE.md`.
- `docs/G14_BALANCE_RESULTS.md`.
- `docs/G14_EXECUTION_RECORD.md`.
- `docs/G14_TECHNICAL_REPORT.md`.
- `docs/G14_TEST_GUIDE.md`.
- `game/data/farming/g14/audio_slots.json`.
- `game/data/farming/g14/land.json`.
- `game/data/farming/g14/terrain.json`.
- `game/scenes/farm/g14/farm.gd`.
- `game/scenes/farm/g14/farm.gd.uid`.
- `game/scenes/farm/g14/farm.tscn`.
- `game/scripts/domain/land/land_economy_rules.gd`.
- `game/scripts/domain/land/land_economy_rules.gd.uid`.
- `game/scripts/domain/land/land_rules.gd`.
- `game/scripts/domain/land/land_rules.gd.uid`.
- `game/scripts/domain/land/land_state.gd`.
- `game/scripts/domain/land/land_state.gd.uid`.
- `game/scripts/services/land/local_land_service.gd`.
- `game/scripts/services/land/local_land_service.gd.uid`.
- `game/scripts/ui/land/land_audio.gd`.
- `game/scripts/ui/land/land_audio.gd.uid`.
- `game/scripts/ui/land/land_presenter.gd`.
- `game/scripts/ui/land/land_presenter.gd.uid`.
- `game/scripts/ui/land/land_ui.gd`.
- `game/scripts/ui/land/land_ui.gd.uid`.
- `game/scripts/visual/g14_view.gd`.
- `game/scripts/visual/g14_view.gd.uid`.
- `game/tests/capture_land.gd`.
- `game/tests/capture_land.gd.uid`.
- `game/tests/land_restart_probe.gd`.
- `game/tests/land_restart_probe.gd.uid`.
- `game/tests/land_tests.gd`.
- `game/tests/land_tests.gd.uid`.
- `game/tests/simulate_land.gd`.
- `game/tests/simulate_land.gd.uid`.
- `tools/capture_land.ps1`.
- `tools/gallery_land.py`.
- `tools/play_land.ps1`.
- `tools/report_land_balance.py`.
- `tools/simulate_land.ps1`.

Alterados:

- `README.md`.
- `docs/GDD.md`.
- `docs/ROADMAP.md`.
- `tools/check.ps1`.

A etapa histórica anterior criou `docs/G1H_HISTORICAL_AUDIT.md`,
`docs/EMOTIONAL_DESIGN_PILLARS.md`, `docs/G14_HISTORICAL_INTEGRATION.md` e
acrescentou ADR-018 em `docs/DECISIONS.md`, commit `56fc39f`.

## Pendências e parada

Sem blocker técnico local identificado. Avaliação humana G1.4, valores/inflação,
arte/acabamento, áudio final, celular físico, licenças/release e segurança online
continuam pendentes. Não declarar o ambiente local resistente a trapaças.
Guia de abertura e roteiro: G14_TEST_GUIDE.md. Parar no G1.4; nenhum G1.5/G2.
