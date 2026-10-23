# G0.6 — registro de execução

2026-10-23. Branch `foundation/g0-6-style-lock`, base limpa `cc1e874`
(`foundation/g0-5r-art-sample-v2`). Nenhuma alteração prévia não commitada foi
encontrada. Sem merge, conflito, push ou modificação de fontes anteriores.

## Arquivos criados

- `game/scenes/art/g06/g06.tscn`, `g06.gd`, `g06.gd.uid`: cena independente e HUD.
- `game/scripts/visual/g06_grid.gd`, `.gd.uid`: projeção, ocupação e profundidade.
- `game/scripts/visual/g06_view.gd`, `.gd.uid`: renderer de sprites/tiles/FX.
- `game/data/art/g06/reference.json`: fixture de quatro canteiros, escala,
  fontes, posições, sockets e durações. Não é catálogo de economia.
- `game/assets/art/g06/garden_kit_v1.png`, `action_fx_v1.png`, `path_v2.png`,
  e os três `.png.import`: fontes originais e configuração de importação.
- `game/tests/g06_tests.gd`, `.gd.uid`: checks da cena, input e grade.
- `game/tests/capture_g06.gd`, `.gd.uid`: captura gráfica antes/depois/detalhes.
- `tools/build_g06_data.py`, `catalog_g06.py`, `capture_g06.ps1`, `gallery_g06.py`:
  regeneração determinística dos dados, proveniência e materiais de avaliação.
- `docs/G06_PROMPTS.json`, `g06_assets_manifest.json`, `G06_PROVENANCE.md`,
  `G06_GRID_SCALE.md`, `G06_REFINEMENT_REPORT.md`, `G06_TEST_GUIDE.md` e este registro.

## Arquivos alterados

- `README.md`: acesso F6 à cena e documentação.
- `docs/ART_BIBLE.md`: aceite conceitual, composição e escala estilizada, mantendo
  a revisão anterior identificada como histórico.
- `docs/DECISIONS.md`: ADR-013 de autorização e fronteira G0.6.
- `docs/ROADMAP.md`: extensão G0.6 autorizada, sem avançar G1.
- `docs/ASSET_PIPELINE.md`: novo manifesto e origem, sem promover packs.
- `tools/check.ps1`: inclui checks G0.6 na rotina completa.
- `tools/check_repository.py`: valida também manifesto G0.6, hashes/proveniência,
  PNGs explicitamente permitidos; mantém quarentena e proibição de release automático.

`.local/g06/` contém 21 PNGs reais, HTML e logs; não versionado. `.godot/`,
extrações, anexos do usuário e outputs intermediários do gerador não foram adicionados.
As três imagens de runtime novas são outputs originais com origem registrada;
nenhum material de terceiros com licença pendente entrou na cena.

## Comandos e ferramentas

Leitura com `Get-Content -Raw`, buscas `rg`/`rg --files`, inspeção `view_image` de
atlases e capturas. Inspeção Git: `git status --short`, `git branch --show-current`,
`git diff`, `git diff --check`. Branch: `git switch -c foundation/g0-6-style-lock`.
Quatro chamadas do image_gen integrado registradas integralmente em `G06_PROMPTS.json`.
`Copy-Item` preservou fontes ao criar cópias novas. Nenhum PNG foi editado via Python;
Pillow somente leu dimensões/alpha/bounds. Sem nova dependência instalada.

Com Python local (caminho no guia):

```powershell
& $python tools/build_g06_data.py
& $python tools/catalog_g06.py
& $python tools/check_repository.py
& $python tools/gallery_g06.py
```

Godot 4.7.2 stable, sem addon, Compatibility:

```powershell
& $godot --headless --path game --editor --quit
& $godot --headless --path game --script res://tests/g06_tests.gd
./tools/check.ps1 -Godot $godot -Python $python
./tools/capture_g06.ps1 -Godot $godot -Python $python
```

O wrapper de captura inicia processo gráfico oculto (`Start-Process -WindowStyle
Hidden`) com limite de 60 s, sem headless. Galeria sem servidor e sem retoque.
Validação integral final em `.local/g06/check.log`; saída/erros de captura no mesmo
diretório. Uma primeira execução da política detectou prompt de caminho ausente;
registro completado antes da validação final. Nenhuma exceção à política foi criada.

Preservação: `git diff --exit-code cc1e874 --` aplicado a `game/project.godot`,
cenas experience/pilot, scripts art_sample/art_lab, renderers legados, diretórios
de imagens G0.5/v2, dados v2 e `visual_standard.json`: sem diferenças. O Git registra
somente adições isoladas e alterações de documentação/checks listadas acima.

## Resultado final

| Validação | Resultado |
|---|---|
| Política de repositório | PASS; 5.946 gráficos /6.158 fontes históricos preservados |
| Fundação | PASS |
| G0.3 | PASS, 480 checks |
| G0.4 | PASS, 15 checks |
| G0.5 | PASS, 418 checks |
| G0.5-R | PASS, 1.148 checks |
| Amostra v2 | PASS, 154 checks |
| G0.6 | PASS, 329 checks |
| Capturas gráficas | PASS, 21 PNGs reais nas duas resoluções |
| Parsing/runtime final | sem erros reportados |

**G0.6 técnico: PASS. G0.6 artístico: PENDING HUMAN APPROVAL.**
Sem blocker local. Normalização nativa/alpha/pivôs/sombras, fonte, áudio final,
teste físico de celular e aprovação humana permanecem no relatório. Sem alegação
de benchmark móvel ou qualidade comercial já alcançada. Não avançar para G1.
