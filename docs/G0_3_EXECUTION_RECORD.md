# G0.3 — Registro técnico da entrega

Data: 2026-10-21. Branch: `foundation/g0-visual-comparison`, criada a partir da entrega preservada em `foundation/g0-bootstrap-audit` (`713c8ae`). G0.3 foi explicitamente autorizado como comparação pelo diretor; **não aprovado artisticamente**. Nenhum G1 implementado.

## Alterações

- Documento remoto `PRODUCTION_PROGRESSION.md` integrado de `574a33e` após merge-tree sem conflitos, em commit separado `docs: integrate production progression brief`.
- Três cenas: menu, proposta A, proposta B; um controlador compartilhado para UI/câmera e um renderer procedural original para a fazenda.
- Fixture JSON de dados visuais, sem economia ou estado autoritativo.
- Entrada principal passa do boot neutro para o menu de comparação. O boot anterior e seus testes são preservados.
- Checks incluem testes da comparação; ferramenta de captura GPU reproduz menu/vista geral/foco em duas resoluções e cria galeria local.
- Documentação de comparação/custos, instruções e limites; README, roadmap e decisões atualizados sem aprovar a direção.

## Comandos executados e resultados

Os caminhos são relativos a `D:\Projetos\ColheitaFelizProMax\colheita`, salvo executáveis. Nenhuma dependência nova foi instalada.

1. `git status --short --branch`, `rg --files`, `Get-Content` dos documentos e leitura integral dos CSVs pelo parser Python: estado e documentação conferidos. `git show origin/foundation/game-design:<path>` para documentos remotos; busca na árvore não encontrou documentos dedicados de UX/perspectiva.
2. `git fetch origin`: falha de resolução de rede no sandbox; repetição com acesso normal autorizado atualizou a referência para `574a33e`.
3. `git merge-tree --write-tree HEAD origin/foundation/game-design`: sem conflitos. `git switch -c foundation/g0-visual-comparison`; `git merge --no-ff origin/foundation/game-design -m 'docs: integrate production progression brief'`: apenas documentação nova integrada, sem alteração/perda dos gates anteriores.
4. Criação/edição dos scripts, cenas e docs via arquivos UTF-8; `godot --headless --path game --editor --quit` identificou dois erros de inferência de tipos na primeira implementação. Tipos corrigidos; importações seguintes passaram. Capturas iniciais expuseram sobreposição de HUD/cercas e invasão de HUD pelo zoom; correções foram feitas antes da captura final. Layout retrato recebeu alvos maiores antes da entrega.
5. Check final executado com:

```powershell
$godot = 'C:\Users\guilh\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
$python = 'C:\Users\guilh\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
./tools/check.ps1 -Godot $godot -Python $python
```

Resultado: **PASS** para checks do repositório (incluindo hashes originais), importação/parsing, testes G0.1, **480 verificações G0.3** e boot do menu. G0.3 verifica as quatro combinações de projeção/resolução, input sintético de mouse/toque/pinça, seleção, zoom/pan, botões dentro da tela, ausência de sobreposição e alvos retrato de 132 px. O processo do editor usa as pastas normais de configuração, com acesso autorizado; nenhuma configuração global de safe-save foi desabilitada.

6. Captura final:

```powershell
./tools/capture_visuals.ps1 -Godot $godot
```

Resultado: **PASS**, dez PNGs pelo renderer Compatibility/OpenGL em AMD Radeon RX 7600, incluindo visões gerais/foco A/B e menu. Capturas inspecionadas visualmente, sem retoque. Dimensões dos PNGs conferidas pelo cabeçalho binário via Python stdlib; manifesto local `.local/g0_3/capture_manifest.json`. Nenhuma câmera/captura depende dos packs auditados. A galeria `.local/g0_3/index.html` foi gerada; artefatos continuam ignorados.

7. `git diff --check`, `git check-ignore .local/g0_3/index.html .local/g0_3/captures/proposal_a_1920x1080.png`; inspeção do diff/staging: sem imagens, áudio, arquivos compactados ou caches novos versionados. Nenhum asset ou extração original foi modificado.

## Limites e aprovação

Testes em retrato são renderização 1080×1920 e eventos sintéticos, não teste de aparelho físico. Não se mediu performance/consumo em mobile, safe areas ou multitouch real. O renderer é um estudo de composição com placeholders; produção pixel final, otimização e pipeline definitivo dependem da escolha artística. Nenhuma licença pendente foi liberada. G0.3 aguarda avaliação do diretor conforme `G0_3_TEST_GUIDE.md`; sem avanço para G1. CI remota não executada, sem push/PR.

## Arquivos criados/alterados nesta implementação

Lista inclui os arquivos desta implementação e a documentação de progressão integrada, relativa à base `713c8ae`. Capturas/logs/galeria permanecem somente sob `.local/g0_3/` e não estão nessa lista.

- README.md
- docs/DECISIONS.md
- docs/DEVELOPMENT.md
- docs/G0_3_EXECUTION_RECORD.md
- docs/G0_3_TEST_GUIDE.md
- docs/G0_3_VISUAL_COMPARISON.md
- docs/PRODUCTION_PROGRESSION.md
- docs/ROADMAP.md
- game/data/visual/comparison_fixture.json
- game/project.godot
- game/scenes/comparison/comparison.gd
- game/scenes/comparison/comparison.gd.uid
- game/scenes/comparison/comparison_menu.tscn
- game/scenes/comparison/proposal_a.tscn
- game/scenes/comparison/proposal_b.tscn
- game/scripts/visual/farm_study.gd
- game/scripts/visual/farm_study.gd.uid
- game/tests/capture_visuals.gd
- game/tests/capture_visuals.gd.uid
- game/tests/comparison_tests.gd
- game/tests/comparison_tests.gd.uid
- tools/capture_visuals.ps1
- tools/check.ps1
