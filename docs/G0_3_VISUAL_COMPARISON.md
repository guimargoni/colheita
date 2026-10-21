# G0.3 — Comparação de direção visual

Status: **PRONTO PARA REVISÃO CRIATIVA; G0.3 NÃO APROVADO**. G0.1/G0.2 continuam aprovados tecnicamente. G1 não foi iniciado. Branch de trabalho: `foundation/g0-visual-comparison`.

## O que foi entregue

Duas cenas executáveis e um menu interno no Godot 4.7.2 stable. Ambas usam a mesma fazenda de 16 canteiros, casa, sete árvores, cercas, caminhos, vaca, duas galinhas, cachorro e casinha, galinheiro, apiário e flores. A seleção de um canteiro só destaca seu contorno e informa seu número; não planta, cresce, colhe, concede itens ou modifica moedas. O HUD mostra moedas/nível de uma fixture visual e permite abrir pranchas simples de Loja, Amigos e Inventário. Nenhum backend, multiplayer, transação, persistência ou sistema definitivo foi criado.

A paleta é comum: verde-sálvia/oliva, paredes creme, telhado terracota, madeira quente e contraste escuro no HUD. A mesma quantidade de elementos facilita comparar projeção e leitura. Fumaça discreta, balanço das plantas/copas, abelhas, borboletas, respiração dos animais e cauda do cachorro dão vida sem eventos de gameplay. **Pausar/Animar** permite avaliar composição sem movimento.

O trabalho é um estudo de composição com **placeholders procedurais originais**. Ainda não é arte pixel final nem prova de que os sprites de um pack funcionem na projeção escolhida. O rótulo premium descreve a direção pretendida, não uma aprovação de qualidade final. Não há imagem, áudio ou fonte externa importada; a fonte utilizada é a padrão do Godot.

## Leitura da documentação e decisões de escopo

Foram relidos AGENTS, README e toda a documentação disponível em `docs/`, incluindo arquitetura, roadmap, GDD, auditoria/licenças, registros anteriores, áudio, monetização e eventos; os dois CSVs extensos foram lidos integralmente pelo parser de inventário. O fetch trouxe `574a33e`, que adiciona `PRODUCTION_PROGRESSION.md`. Esse documento foi lido e integrado sem conflitos após a verificação `git merge-tree`, preservando G0.1/G0.2.

Não há arquivo separado de direção de UX ou perspectiva na referência remota `574a33e`. Os critérios vieram do GDD (§25–28), Event UX, Purchase UX, Production Progression (inclusive Confirmation gate) e do briefing explícito do diretor para A/B. Não foi inventada uma aprovação documental ausente.

- UX: acesso direto aos dois estudos, navegação com mouse/toque, controles persistentes, zoom/foco de canteiros e camadas de HUD protegidas do pan.
- Progressão: composição compacta; o apiário, galinheiro e pasto são apenas volumes ilustrativos. Reserva contínua à direita com cerca de 14% da área-base; não há botão de compra/desbloqueio.
- Áudio: silencioso neste estudo. A direção pastoral continua referência para produção futura; não foi gerado nem adquirido áudio.
- Economia/eventos: nenhum saldo real, preço, moeda premium, recompensa, cronômetro ou evento funcional. Nada foi balanceado ou monetizado.

## Comparação

| Critério | A — Isométrica clássica modernizada | B — Oblíqua/top-down premium |
|---|---|---|
| Projeção | Diamantes 2:1, `x=(u−v)×57`, `y=(u+v)×28,5−altura`. Paredes, chão, telhado, cercas e canteiros usam a mesma transformação. | Plano mais frontal, `x=u×74+v×7`, `y=v×55−altura`. Perspectiva oblíqua leve, volumes verticais, maior face superior do canteiro. |
| Sensação | Diorama acolhedor, profundidade, relação forte entre casa e jardim; narrativa espacial mais próxima da intenção clássica. | Fazenda organizada e serena; hierarquia direta entre caminhos, culturas e áreas funcionais. |
| Canteiros | Losangos separados e elevados; a diagonal cria ritmo e favorece o aspecto de pequena propriedade. Compressão vertical exige atenção às silhuetas. | Faces maiores e alinhamento legível, especialmente para distinguir estágios e famílias de plantas. |
| Desktop 1920×1080 | Conjunto completo enquadrado ao lado do cartão A; expansão visível. Foco Canteiros aumenta as plantas e recorta bordas intencionalmente. | Conjunto completo, leitura de cima para baixo; B usa mais altura e menos largura do quadro. |
| Celular 1080×1920 | Visão geral preserva toda a propriedade e reduz os canteiros; o foco é necessário para avaliar detalhes/toques. No foco, as bordas da fazenda ficam fora de quadro e podem ser exploradas por pan. | Melhor área útil por canteiro no foco e menos ambiguidade nas fileiras. Também precisa de zoom para a interação confortável em uma tela física pequena. |
| Reaproveitamento potencial | Maeve é top-down/oblíqua; casa, terrenos e cercas não devem ser inclinados artificialmente para fingir isometria. Boa parte precisa ser redesenhada/reprojetada. | Mais próxima da orientação de Maeve; plantas, animais e props podem demandar menos redesenho, **se** sua licença for esclarecida. Tiles e sombras ainda precisam de normalização. |
| Oclusão e colocação futuras | Mais trabalho com ancoragem, máscaras, ordenação de objetos altos e hit areas em losangos. | Ordenação/picking mais simples; ainda exige pivôs e testes de sobreposição. |
| Expansão futura | Ampliação em diagonais tem presença visual forte, mas exige revisar enquadramento móvel e camadas altas. | Reserva lateral fácil de interpretar; risco de virar grade extensa e monótona se abandonar a composição compacta. |
| Risco principal | Alto custo de arte coerente; misturar sprites frontais com terreno iso quebraria a direção. | A geometria pode parecer funcional demais; detalhamento, materiais, iluminação e animações precisam sustentar a proposta premium. |

**Conclusão para decisão, não escolha definitiva:** A favorece o diorama e a identidade espacial clássica; B é a opção de menor atrito para leitura móvel e para um eventual aproveitamento legal do catálogo Maeve. Recomenda-se comparar primeiro os focos dos canteiros no celular, depois o conjunto no desktop. A direção final pertence ao diretor.

## Custos estimados para evoluir cada direção

Estimativas internas de esforço, não cotação de mercado nem medição de produtividade. Unidade: dia-pessoa de 8h. Consideram uma primeira tela visual refinada com casa, terreno/cercas/caminhos, árvores, quatro famílias de plantas em quatro estágios, dois animais e cachorro, pequeno conjunto de props e HUD responsivo; não contemplam G1, catálogo completo, backend, áudio, pagamentos ou eventos. Hipótese: um artista 2D experiente e um desenvolvedor Godot, com feedback criativo em duas rodadas. Reservar aproximadamente 40% de incerteza adicional se o escopo mudar.

| Trabalho | A | B | Motivo |
|---|---:|---:|---|
| Guia visual, paleta, escala e silhouettes | 3–5 dias de arte | 2–4 dias de arte | A exige definir uma família iso completa; B pode aproveitar a orientação já auditada como referência. |
| Arte final original / redraw, estágios, animais e props | 15–24 dias de arte | 9–16 dias de arte | A pede reconstrução de volumes/ângulos; B reduz o problema de perspectiva, mesmo sem licença para integrar packs. |
| Pipeline de sprites, pivôs, sorting, picking e câmera/HUD | 6–10 dias técnicos | 4–7 dias técnicos | A tem maior risco de oclusão e hit testing; controles deste estudo não são o sistema definitivo. |
| Revisão visual, dispositivos e correções | 3–5 dias de arte + 2–3 técnicos | 2–4 dias de arte + 2–3 técnicos | Inclui leitura de canteiros, sobreposições e escala móvel; não inclui publicação em lojas. |
| Total de esforço (somável, não prazo corrido) | **21–34 dias de arte + 8–13 técnicos** | **13–24 dias de arte + 6–10 técnicos** | Atividades podem ter alguma sobreposição; prazo real depende de aprovações e disponibilidade. |

Licenças aprovadas podem reduzir o redraw de B, mas não foi descontada uma economia ainda incerta. A liberação de um pack frontal não elimina o custo de reprojeção de A. A arte procedural atual é material de estudo, não compromisso com uma técnica de produção final.

## Licenças e proveniência

Nenhum PNG dos três packs foi copiado para `game/` nem carregado por código. Não há carregamento opcional da pasta `.local/asset_audit`. A referência ao catálogo Maeve é de categoria/composição e viabilidade de perspectiva, não traçado ou cópia de pixels. Todas as formas foram construídas em GDScript para este estudo. Nenhum modelo de imagem foi usado, nenhum treinamento realizado e nenhum asset do Colheita Feliz histórico foi imitado diretamente.

`docs/ASSET_LICENSE_RECORD.md` permanece a fonte das pendências: escopo FREE de Maeve, conflito de termos SnowHex, termos completos/atribuição unTied e arquivos compactados preexistentes no histórico. O estudo executa sem nenhum desses packs ou extrações. Capturas novas são renderizações de placeholders originais e ficam como artefatos locais ignorados; nenhuma contact sheet antiga foi versionada ou alterada. Nenhuma licença de terceiros foi reclassificada como aprovada.

## Capturas e avaliação visual

Dez PNGs são gerados **pelas cenas reais no Godot**, via SubViewport com GPU: menu, visão geral A/B e foco A/B em cada resolução. Animações são congeladas no mesmo instante (`2 s`) para comparação. Tamanhos exatos: 1920×1080 e 1080×1920. Galeria local: `.local/g0_3/index.html`; imagens em `.local/g0_3/captures/`.

- `proposal_a_1920x1080.png`, `proposal_b_1920x1080.png`: desktop, visão geral.
- `proposal_a_1080x1920.png`, `proposal_b_1080x1920.png`: retrato, visão geral.
- Os mesmos nomes com `_detail.png`: foco nos canteiros.
- `proposal_menu_1920x1080.png` e `proposal_menu_1080x1920.png`: acesso às propostas.

As dez capturas foram inspecionadas e os quadros ajustados para separar mapa e HUD. A vista de detalhe recorta objetos periféricos intencionalmente, sem desenhar a fazenda por cima dos controles. Não há pós-pintura, mockup externo ou embelezamento das capturas. O teste em 1080×1920 é renderização/simulação de aspecto; **não substitui teste em um aparelho físico**, área segura de notch ou validação de gestos reais Android/iOS.

## Como testar

Consulte `docs/G0_3_TEST_GUIDE.md` para comandos completos. Importe `game/project.godot` no Godot e pressione **F5**: escolha A ou B no menu. **Comparar** volta ao menu; **A ↔ B** alterna a direção. Arraste o mapa, use roda/+/−, botão de visão geral (casa) e **Canteiros**. Com toque: arraste com um dedo e use pinça com dois; botões aceitam toque emulado pelo Godot. Clique/toque em um canteiro para ver o contorno, abra os três painéis e confirme que nada altera o HUD. **Pausar** congela a ambientação.

## Validação e limites

- `tools/check.ps1`: estrutura/metadados/hashes/quarentena/padrões básicos de segredos, parsing/importação do editor, testes G0.1 e boot do menu.
- `game/tests/comparison_tests.gd`: 480 verificações nas quatro combinações A/B × desktop/retrato; projeção inversa, 16 hit areas, orientação, botões dentro da tela e sem sobreposição, alvos de toque de ao menos 132×132 px no layout 1080 de retrato, recorte do mapa separado do HUD, seleção projetada e roteamento de cliques pelo viewport/GUI real, zoom, pan, soltura fora do mapa, toque, pinça, painéis, pausa e navegação.
- `tools/capture_visuals.ps1`: dez renderizações reais via Compatibility/OpenGL na RX 7600 disponível; requer display/GPU. CI headless não captura imagens.
- Verificação das dimensões dos PNGs e de que artefatos locais permanecem ignorados; `git diff --check`.

Não houve benchmark em hardware móvel, teste físico com multitouch, arte pixel final, save, API ou gameplay. O renderer procedural redesenha a cena para animar e **não é ainda um pipeline de performance aprovado para produção**. Sons ausentes são intencionais neste recorte visual. As pranchas de Loja/Amigos/Inventário avaliam acesso e posição, não seus fluxos definitivos.

**G0.3 permanece aguardando o diretor:** escolher A, B ou solicitar ajustes; aprovar escala e leitura dos canteiros em ambas as telas; aprovar HUD/composição; confirmar orçamento artístico e encaminhar licenças. Nenhuma decisão definitiva de direção ou avanço para G1 é tomada nesta entrega.
