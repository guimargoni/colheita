# G1.2 — registro de execução e entrega

2026-10-24. Branch `feature/g1-2-crop-care`, base limpa `f6b265f`.
G1.1 validado pelo diretor no briefing; ADR-015 autoriza somente G1.2.
Nenhuma alteração prévia não commitada encontrada. Sem merge, conflitos ou push.

**Estado histórico na entrega: G1.2 técnico PASS; experiência aguardava aprovação.**

Adendo de 2026-10-24: o diretor validou as mecânicas do estado `5300061`.
O [registro de aprovação](G12_HUMAN_APPROVAL.md) delimita esse aceite e o marco
Git. Acabamento artístico, áudio final, celular físico e segurança online
continuam pendentes. As verificações abaixo são as da entrega original.

## Arquivos criados

- `JOGAR_G12_TESTE.cmd`: entrada simples para teste interativo no Windows.
- `game/scenes/farm/g12/farm.tscn`, `farm.gd`, `farm.gd.uid`.
- `game/scripts/domain/care/care_rules.gd`, `care_commands.gd`, `care_state.gd`,
  e os três `.gd.uid`.
- `game/scripts/services/care/local_care_service.gd` e `.gd.uid`.
- `game/scripts/ui/care/care_presenter.gd`, `care_tools_panel.gd`,
  `care_tooltip.gd`, `care_audio.gd`, e os quatro `.gd.uid`.
- `game/scripts/visual/g12_view.gd` e `.gd.uid`.
- `game/data/farming/g12/care.json`, `fertilizers.json`, `art.json`, `audio_slots.json`.
- `game/assets/art/g12/care_atlas_v1.png` e `.png.import`: único PNG novo, original.
- `game/tests/care_tests.gd`, `care_restart_probe.gd`, `capture_care.gd`,
  `simulate_care.gd`, e os quatro `.gd.uid`.
- `tools/play_care.ps1`, `capture_care.ps1`, `gallery_care.py`, `catalog_care.py`,
  `simulate_care.ps1`, `report_care_balance.py`.
- `docs/G12_TECHNICAL_REPORT.md`, `G12_TEST_GUIDE.md`, `G12_BALANCE.md`,
  `G12_BALANCE_RESULTS.md`, `G12_ART_AND_AUDIO.md`, `G12_PROMPTS.json`,
  `g12_assets_manifest.json` e este registro.

## Arquivos alterados

- `README.md`: iniciador e documentação de cuidados.
- `docs/DECISIONS.md`: ADR-015 de autorização, parâmetros provisórios e parada.
- `docs/GDD.md`: addendum de cuidados leves, sem autoridade online local.
- `docs/ROADMAP.md`: delimitação da entrega G1.2; G1.3/G2 não iniciados.
- `tools/check.ps1`: inclui care_tests mantendo todos os anteriores.
- `tools/check_repository.py`: valida também o manifesto G1.2 e o novo diretório
  original de PNGs, sem afrouxar proveniência/hash/quarentena/false release.

`.local/g12/` contém check/capture logs, HTML, 18 PNGs reais e balance.json.
Testes usam arquivos próprios em `.local/g12/tests/`; não tocam saves do jogador.
Capturas, caches, extrações e anexos não são versionados. Fontes do gerador continuam
preservadas fora do checkout, com cópia integral do PNG aprovado para avaliação
interna; não significa aprovação de release. Nenhum pack terceiro entrou no runtime.

## Comandos e ferramentas executados

Leitura: `Get-Content -Raw` do briefing, AGENTS e documentos de design, arquitetura,
roadmap, arte, UX e G1.1; inspeção dos scripts/modelos existentes. Buscas `rg` e
`rg --files`. Git: `status --short`, `branch --show-current`,
`switch -c feature/g1-2-crop-care`, `diff --exit-code`, `diff --check`.
`Copy-Item` criou cópias versionadas do controller/renderer/adaptador/provedor G1.1.
Alterações nessas cópias não alteram a entrega anterior.

Uma chamada do image_gen integrado, com prompt em `G12_PROMPTS.json`; input somente
atlas próprio. Inspeção com `view_image` do input, output e capturas reais. Nenhuma
edição de PNG por Python, novo pacote instalado, treinamento ou API key.

Com os executáveis locais descritos no guia:

```powershell
& $python tools/catalog_care.py
& $python tools/report_care_balance.py
& $python tools/check_repository.py
& $godot --headless --path game --editor --quit
& $godot --headless --path game --script res://tests/care_tests.gd
& $godot --headless --path game --script res://tests/simulate_care.gd
./tools/check.ps1 -Godot $godot -Python $python
./tools/simulate_care.ps1 -Godot $godot -Python $python
./tools/capture_care.ps1 -Godot $godot -Python $python
./tools/play_care.ps1 -Fast -PrintCommand
powershell.exe -NoProfile -File tools/play_care.ps1 -Fast -PrintCommand
```

Iniciador validado nos dois PowerShells por resolução do engine/argumentos, sem
abrir save do usuário. Captura usa processo gráfico oculto com limite 60 s, Godot
Compatibility/RX7600, fonte controlada e fixture própria. As imagens são renderizadas,
não retoques. Cenas de cuidado forçam ocorrências para inspeção; efeitos antigos
são limpos entre amostras para mostrar uma ação por captura, com estado real do
serviço. Isso não certifica aparelho físico ou performance Android.

Quatro processos separados de care_restart_probe testam plant/care/harvest/replay,
com RNG diferente após abrir: nada rerrola ou duplica estoque/benefício. Erros de
sintaxe/tipagem e de codificação detectados no desenvolvimento foram corrigidos
antes dos checks finais. Processo de teste com erro foi encerrado pelo filtro
específico de script; nenhuma outra instância do jogo foi encerrada.

## Resultados finais

| Validação | Resultado |
|---|---|
| Política repositório | PASS; 5.946 gráficos /6.158 fontes históricos preservados |
| Fundação | PASS |
| G0.3 | PASS, 480 checks |
| G0.4 | PASS, 15 checks |
| G0.5 | PASS, 418 checks |
| G0.5-R | PASS, 1.148 checks |
| Amostra v2 | PASS, 154 checks |
| G0.6 | PASS, 329 checks |
| G1.1 | PASS, 126 checks |
| G1.2 | PASS, 176 checks |
| Perfis de balanceamento | PASS de execução, nove cenários; não aprovação de balanceamento |
| Capturas gráficas | PASS, 18 PNGs reais PC/retrato |
| Parsing/runtime final | sem erros reportados |

Preservação: `git diff --exit-code f6b265f --` sobre project.godot, cenas anteriores,
assets G0.5/v2/G0.6, módulos domain/services/ui farming, prototype, renderer G1.1,
catálogos G1.1, dados art e testes G1.1: sem diferenças. Os novos arquivos estão
isolados e a documentação/checks são as únicas alterações históricas listadas.

Na entrega original, sem blocker de execução local. Pendências então registradas
(para o aceite posterior das mecânicas, consulte o adendo acima): experiência/parâmetros,
sprite native-pixel QA, animação específica de cuidados, masters de áudio, trigo/
morango, bordas adjacentes/caminho e teste de celular real. Servidor/anti-cheat/
concorrência online continuam não implementados, conforme limite do pedido.
Não avançar para G1.3, G2 ou novos gates automaticamente.
