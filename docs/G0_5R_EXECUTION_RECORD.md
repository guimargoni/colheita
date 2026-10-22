# G0.5-R — execução, evidências e parada

2026-10-22. Branch `foundation/g0-5r-art-consolidation`, base limpa `11e5ab1`.
Sem push, merge remoto ou alteração dos sprites/cenas G0.3/G0.4/G0.5.
Entrada F5 e `game/project.godot` preservados. A referência do usuário foi
analisada; arquivo/hash e restrições em `G0_5R_DIAGNOSIS.md`.

## Resultado

**Preparação técnica G0.5-R: PASS. Aprovação artística/aplicação definitiva:
PENDENTE DO DIRETOR.** Não há blocker de parsing ou abertura do laboratório.
Não foi executada produção/substituição definitiva nem avanço a G1.

- Art Bible consolidada; escala, grade, canteiros, skins, animação e UX propostos.
- Matriz por família e catálogo sonoro com origem/licença/status.
- Contrato versionado, contagens/custos de produto indefinidos.
- Laboratório isolado de inspeção, escala, encaixe e câmera.
- Cargas descartáveis de 16/64/100 posições, todas com parcela bloqueada na fase
  cedo; a grade não fica limitada a quatro nem define quota final do jogo.
- Skin de outono é teste de paleta, não desenhos sazonais aprovados.
- Nenhum sprite novo de produção gerado ou copiado; mockup apenas em área privada.

## Evidências e limitações

`tools/check.ps1`: Foundation PASS; G0.3 **480**, G0.4 **15**, G0.5 **418** e
G0.5-R **1.148 checks** sem falhas. Import/editor, parsing e boot sem erros.
Checks de G0.5-R incluem envelopes/pivôs/sockets, grid inversível, fronteiras
semiabertas, IDs estáveis, fase de acesso, regiões extensas, camera inteira,
visão geral, controles móveis e timing individual. Não são aprovação estética.

`tools/capture_art_lab.ps1`: **6 PNGs reais** desktop 1920×1080 / retrato
1080×1920, render Compatibility em RX 7600. Capturas inspecionadas; solo legado
não se encaixa perfeitamente nas guias ideais e culturas podem sobrepor vizinhos.
Isso é diagnóstico visível para redesenho, não kit modular final.
Sem benchmark móvel ou teste físico de notch/DPI/gestos.

`tools/audit_art_alignment.py`: medição somente de leitura, Pillow já usado no
pipeline de auditoria, sem nova dependência de jogo/CI. Alpha >=192 nos recortes
legados: range do pixel mais baixo **1 px** galinha idle, **8 px** galinha walk,
**1 px** cão atenção. São pixels-fonte do atlas, não escala normalizada nem
anotação anatômica dos pés. Mesmo range pequeno não comprova loop ou volume.
Relatório JSON em `.local/g0_5r/legacy_alignment.json`; revisão obrigatória.

A casa antiga continua inadequada para a porta proposta; sprite humano e kit
modular nativos não produzidos. O laboratório tem UI técnica simples, sem alegar
ser HUD final. Alvos e fontes em aparelho real ainda pedem validação.
Som final ausente; synth atual permanece placeholder. Packs históricos e
revisão de IP/distribuição permanecem conforme registros anteriores.

## Reproduzir

```powershell
$godot = 'C:/Users/guilh/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'
$python = 'C:/Users/guilh/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
./tools/check.ps1 -Godot $godot -Python $python
& $python tools/audit_art_alignment.py
./tools/capture_art_lab.ps1 -Godot $godot
Start-Process (Resolve-Path '.local/g0_5r/index.html')
& $godot --path game res://scenes/art/art_lab.tscn --resolution 1920x1080
& $godot --path game res://scenes/art/art_lab.tscn --resolution 1080x1920
```

No editor, F6 em `scenes/art/art_lab.tscn`. Instruções detalhadas e próximo piloto:
`G0_5R_IMPLEMENTATION_PLAN.md`. Capturas/logs/mockup não versionados.

Outros comandos: Get-Content e rg para leitura, git status/branch/log/diff,
`git switch -c foundation/g0-5r-art-consolidation`, Copy-Item da referência
para .local, Get-FileHash SHA256, Godot headless --editor --quit e --quit-after 3,
teste direto art_standard_tests.gd, git diff --check e commit local.
Nenhum download de packs, treinamento, publicação ou comunicação a terceiros.

## Arquivos criados/alterados

- `README.md`
- `docs/ANIMATION_GUIDE.md`
- `docs/ART_BIBLE.md`
- `docs/ART_PRODUCTION_PLAN.md`
- `docs/ASSET_PIPELINE.md`
- `docs/AUDIO_PRODUCTION_PLAN.md`
- `docs/DECISIONS.md`
- `docs/G0_5R_ASSET_MATRIX.csv`
- `docs/G0_5R_DIAGNOSIS.md`
- `docs/G0_5R_EXECUTION_RECORD.md`
- `docs/G0_5R_IMPLEMENTATION_PLAN.md`
- `docs/MODULAR_PLOTS_SPEC.md`
- `docs/PROJECTION_GRID_GUIDE.md`
- `docs/ROADMAP.md`
- `docs/SKIN_CONTRACTS.md`
- `docs/UX_FRAMING_STANDARD.md`
- `docs/VISUAL_SCALE_STANDARD.md`
- `docs/audio_catalog_g05r.csv`
- `game/data/art/visual_standard.json`
- `game/scenes/art/art_lab.gd`
- `game/scenes/art/art_lab.gd.uid`
- `game/scenes/art/art_lab.tscn`
- `game/scripts/visual/art_lab_model.gd`
- `game/scripts/visual/art_lab_model.gd.uid`
- `game/scripts/visual/art_lab_view.gd`
- `game/scripts/visual/art_lab_view.gd.uid`
- `game/tests/art_standard_tests.gd`
- `game/tests/art_standard_tests.gd.uid`
- `game/tests/capture_art_lab.gd`
- `game/tests/capture_art_lab.gd.uid`
- `tools/audit_art_alignment.py`
- `tools/capture_art_lab.ps1`
- `tools/check.ps1`

## Próxima decisão humana

Aprovar/revisar contratos 32×16/escala humana, encaixes, linguagem e orçamento
do piloto. Se autorizado, produzir um humano + casa/porta + base modular e
normalizar uma família; comparar em dispositivo antes de substituir.
Quantidades, custos e expansão econômica continuam sem decisão.
Parado no G0.5-R aguardando orientação.
