# G1.3 — registro de execução e entrega

2026-10-24. Branch `feature/g1-3-economy-progression`, criada da base limpa
`22f988b`. Briefing anexado G1.3 lido como instrução do diretor; ADR-017 registra
sua autorização exclusiva. Sem alterações locais prévias, merges, conflitos ou push.
Tag de aceite G1.2 preservada e nenhum gate anterior foi sobrescrito.

**G1.3 técnico: PASS. G1.3 experiência: PENDING HUMAN APPROVAL.**

## Arquivos criados

- `JOGAR_G13_TESTE.cmd`.
- `docs/G13_BALANCE.md`.
- `docs/G13_BALANCE_RESULTS.md`.
- `docs/G13_EXECUTION_RECORD.md`.
- `docs/G13_TECHNICAL_REPORT.md`.
- `docs/G13_TEST_GUIDE.md`.
- `game/data/farming/g13/audio_slots.json`.
- `game/data/farming/g13/economy.json`.
- `game/scenes/farm/g13/farm.gd`.
- `game/scenes/farm/g13/farm.gd.uid`.
- `game/scenes/farm/g13/farm.tscn`.
- `game/scripts/domain/economy/economy_rules.gd`.
- `game/scripts/domain/economy/economy_rules.gd.uid`.
- `game/scripts/domain/economy/economy_state.gd`.
- `game/scripts/domain/economy/economy_state.gd.uid`.
- `game/scripts/services/economy/local_economy_service.gd`.
- `game/scripts/services/economy/local_economy_service.gd.uid`.
- `game/scripts/ui/economy/economy_audio.gd`.
- `game/scripts/ui/economy/economy_audio.gd.uid`.
- `game/scripts/ui/economy/economy_presenter.gd`.
- `game/scripts/ui/economy/economy_presenter.gd.uid`.
- `game/scripts/ui/economy/economy_ui.gd`.
- `game/scripts/ui/economy/economy_ui.gd.uid`.
- `game/tests/capture_economy.gd`.
- `game/tests/capture_economy.gd.uid`.
- `game/tests/economy_restart_probe.gd`.
- `game/tests/economy_restart_probe.gd.uid`.
- `game/tests/economy_tests.gd`.
- `game/tests/economy_tests.gd.uid`.
- `game/tests/simulate_economy.gd`.
- `game/tests/simulate_economy.gd.uid`.
- `tools/capture_economy.ps1`.
- `tools/gallery_economy.py`.
- `tools/play_economy.ps1`.
- `tools/report_economy_balance.py`.
- `tools/simulate_economy.ps1`.

## Arquivos alterados

- `README.md`.
- `docs/DECISIONS.md`.
- `docs/GDD.md`.
- `docs/ROADMAP.md`.
- `tools/check.ps1`.

## Comandos e ferramentas executados

Leitura do anexo e `AGENTS.md`, GDD, arquitetura, roadmap, monetização/economia,
UX, Art Bible, progressão e relatórios/implementação G1.1/G1.2. `Get-Content -Raw`,
`rg`, `rg --files`, `git status --short`, `branch --show-current`, `branch --list`,
`log -4 --oneline`. `git switch -c feature/g1-3-economy-progression`.
Edição de fontes com apply_patch e Python local; sem instalações, geração de imagem,
novos PNGs/sons, downloads, segredos, treinamento ou rede.

Com Godot/Python locais definidos em `G13_TEST_GUIDE.md`:

```powershell
& $godot --headless --path game --editor --quit
& $godot --headless --path game res://scenes/farm/g13/farm.tscn --quit-after 3
& $godot --headless --path game --script res://tests/economy_tests.gd
& $godot --headless --path game --script res://tests/simulate_economy.gd
& $python tools/report_economy_balance.py
./tools/check.ps1 -Godot $godot -Python $python
./tools/capture_economy.ps1 -Godot $godot -Python $python
./tools/play_economy.ps1 -Fast -PrintCommand
powershell.exe -NoProfile -File tools/play_economy.ps1 -Fast -PrintCommand
git diff --check
```

O wrapper `tools/simulate_economy.ps1` reproduz as chamadas de simulação/relatório
acima; nesta execução seus componentes foram chamados diretamente. Iniciador
validado por resolução dos argumentos nos dois PowerShells; não é alegação de
playtest humano. Testes usam MemoryStore ou arquivos exclusivos em
`.local/g13/tests/`, inclusive subprocessos buy/harvest/sell/replay.

Primeiro boot restrito pelo sandbox não conseguiu gravar pastas normais de Godot
no AppData. Execuções posteriores com autorização de execução local funcionaram.
Durante implementação, erro de tipo bool/int da UI e uma expectativa de estoque
em teste foram corrigidos; resultados abaixo são os finais, sem esses erros.

Capturas usam processo gráfico oculto, Compatibility/RX7600, fixtures e relógio
controlados. `view_image` inspecionou PNGs reais de desktop/retrato e o atlas próprio
reutilizado. Painéis, contraste, áreas de quantidade e feedback sobreposto foram
ajustados com base nessas imagens. Capturas finais sem retoque. Não foi feito teste
em aparelho físico nem export público.

## Resultados

| Verificação | Resultado |
|---|---|
| Política do repositório | PASS; 5.946 gráficos e 6.158 fontes históricos preservados |
| Fundação | PASS |
| G0.3 / G0.4 / G0.5 | PASS; 480 / 15 / 418 checks |
| G0.5-R / amostra v2 / G0.6 | PASS; 1.148 / 154 / 329 checks |
| G1.1 / G1.2 | PASS; 126 / 176 checks |
| G1.3 | PASS; 135 checks, incluindo quatro processos separados |
| Simulações econômicas | 27 cenários concluídos; não aprovação de balanceamento |
| Capturas reais | 16 PNGs PC 1920×1080 / retrato 1080×1920 |
| Parsing/runtime final | sem erros reportados |
| Preservação anterior | diff vazio nos caminhos de runtime dos gates anteriores |

Logs e artefatos ignorados: `.local/g13/check.log`, `balance.json`, `capture.log`,
`capture_errors.log`, `economy_final.log`, `captures/` e `index.html`. Não versionar caches, saves,
capturas ou extrações. A lista acima é o conjunto de fontes/documentos da entrega.

Preservação verificada com `git diff --exit-code milestone/g1.2-mechanics-approved --`
sobre project.godot, cenas G1.1/G1.2/arte, assets, catálogos e dados anteriores,
domínios/serviços de farming/care, UI care, renderers e testes G1.1/G1.2. Sem diferenças.

## Pendências e parada

Sem blocker técnico local. Diretor avalia experiência G1.3 e números provisórios.
Continuam pendentes acabamento artístico, áudio final, celular físico e segurança
online, além de licenças/release e validação econômica de longo prazo. Loja finita
sem restock é fixture DEV; ledger local não certifica integridade contra trapaça.
Nenhum G1.4/G2, pagamento, premium, anúncio, visita, roubo, expansão ou produção animal.
Parar e aguardar avaliação.
