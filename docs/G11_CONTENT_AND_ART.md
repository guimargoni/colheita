# G1.1 — catálogo provisório e pendências visuais

2026-10-24. Nenhum asset novo, gerado ou extraído. Nenhuma licença promovida.
Cozy Pixel Art — Fazenda Viva preservada; fontes e gates anteriores intactos.

## Três culturas, valores ajustáveis

| Cultura | Tempo normal | Tempo com teste 60× | Produção | Preço semente / venda / XP / nível |
|---|---|---|---|---|
| Cenoura | 120 s | 2 s | 2 | 2 /3 /1 /1 |
| Morango | 900 s | 15 s | 3 | 5 /4 /3 /1 |
| Trigo | 7.200 s | 120 s | 4 | 8 /5 /5 /1 |

Todos os valores são **provisórios para teste**, não balanceados. Preço/venda/XP/
nível são só definição, sem compra, venda, saldo ou progressão. Cada plantio usa
uma semente; primeira fixture concede 12 de cada para desenvolvimento. Não há
restock automático, loja ou botão de grant. Seeds e products ficam separados.
Tempos e estágios estão em `game/data/farming/crops.json`; alterações só afetam
duração de novos ciclos. Frações de estágio: cenoura 0/0,35/1; morango 0/0,4/1;
trigo 0/0,3/1. Cuidado não é obrigatório; rega fica para outro gate autorizado.

## Materiais reutilizados

| Material | Origem / classificação |
|---|---|
| Casa, flores e poses da galinha | `g05r_pilot/environment_v1.png`, ART_REVIEW |
| Árvores | `g05r_pilot/tree_v2.png`, ART_REVIEW |
| Solo, cenoura e morango | `g05r_pilot/crops_fx_v1.png`, ART_REVIEW |
| Trigo (folhagem temporária de cenoura) | mesmo atlas, **PLACEHOLDER**, indicado no seletor e catálogo |
| Botões/ícones/painel | `g05r_pilot/ui_v1.png`, FINAL_CANDIDATE, não release |
| Grama | `g05/terrain_atlas_v1.png`, ART_REVIEW |
| Cerca, arbustos, conífera e pedras | `g06/garden_kit_v1.png`, ART_REVIEW |
| VFX de plantio/colheita e marcador de maduro | `g06/action_fx_v1.png`, ART_REVIEW |
| Caminho | `g06/path_v2.png`, ART_REVIEW |
| Fonte padrão / áudio final | fonte PLACEHOLDER; áudio NOT_PRODUCED |

Todos os caminhos acima relativos a `game/assets/art/`. Hashes, origem, termos e
prompts nos manifests G0.5/v2/G0.6 e seus registros de proveniência. Fontes não
foram modificadas. Três packs de terceiros continuam bloqueados/quarentenados,
sem uso, treino ou redistribuição adicional. Não há nova autorização de release.

## Pendências aprovadas pelo diretor — não bloqueiam G1.1

1. **Canteiros mais próximos**, quase adjacentes, formando área contínua. Modelo,
   coordenadas e renderer aceitam posições adjacentes, mas a fixture de referência
   mantém composição G0.6. O atlas atual tem moldura completa por canteiro e pode
   mostrar borda dupla quando unido: produzir bordas compartilhadas/terminais e
   validar hit map. Não mascarar esse trabalho com geometria procedural.
2. **Substituir artisticamente o caminho de terra atual**, coerente com cenário,
   com transições naturais e encaixes; nenhuma tentativa de redesenho neste gate.

Produzir ainda: trigo em três estágios reconhecíveis, fase intermediária distinta
de morango e fontes nativas normalizadas. Os três estados de morango/trigo existem
no modelo mesmo onde o desenho se repete; marcador de maturidade e inspeção textual
ajudam a leitura, sem alegar que o placeholder já é arte final. A composição e
galinha usam a escala G0.6; câmera, sombras e limitações nativas continuam documentadas.
