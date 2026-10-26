# G1.V — Comparação de apresentação e game feel

2026-10-26. Base `c326268`, branch `experiment/g1v-visual-gamefeel`.

**G1.V direção visual: PENDING HUMAN DECISION.** A Art Bible oficial não foi alterada. O objetivo é testar apresentação nativa do Godot sem substituir a arte nem reescrever a agricultura.

## O que está sendo comparado

| Aspecto | A — Pixel art modernizada | B — Híbrido moderno |
|---|---|---|
| Cenário, sprites, escala, câmera e lógica | Mesmos do G1.5 | Mesmos do G1.5 |
| Interface | Cantos discretos de 5 px, borda mais marcada, sombra curta | Cantos de 16 px, borda leve, sombra difusa |
| Cor | Paleta navy/teal/papel, textura do mundo preservada | Mesma base com gradação aquecida e bordas discretamente frias |
| Movimento e interações | Brisa, reação, coleta e transições comuns | Mesmos gestos e tempos, para comparação controlada |
| Texto e controles | Nativos, legíveis e com foco | Nativos, legíveis e com foco |

B não é uma nova biblioteca de personagens/cenário 2D. A demonstração testa sobretudo a interface híbrida sobre os sprites existentes. O shader não desfoca texturas nem muda perspectiva. Não há evidência suficiente para decretar uma opção superior.

## Evidência visual entregue

`.local/g1v/index.html`: 12 capturas reais do Godot, pares A/B em PC e retrato, fazenda/loja/inventário. Dois GIFs reais mostram colheita com sprite de saída, partículas, rega, fertilizante e transição da loja. Frames sem retoque ou interpolação de imagem. A captura não substitui o teste interativo de resposta ao toque.

Os painéis passam a ter thumbnails reais das culturas e cartões por item, em vez de bordas raster ornamentadas em grandes formulários. Compra em quantidade e venda parcial/selecionada permanecem. O HUD usa barra fina de XP; métricas ficam ocultas por padrão. O viewport reservado ao mundo é 80% da altura em 1920×1080 e 75% em 1080×1920; controles flutuantes e cartão contextual ainda podem encobrir parte dele. Isso não certifica área útil em aparelho físico.

## Linguagem de movimento

Brisa com fases por terreno e posição; transformação perto do pivô sem animar solo, cercas ou casa. Elasticidade curta após ação bem-sucedida. Prontidão usa tint suave; saída de sprite de até 380 ms; partículas de ação de aproximadamente 350–560 ms. Nenhum callback visual concede item ou espera animação para liberar ação. XP flutuante usa delta real do serviço, não recompensa inventada. Moedas e XP do HUD interpolam por tempo decorrido.

Árvores/arbustos usam rotação muito pequena no contato. É aproximação procedural experimental, não rig final de folhagem. Galinha usa os desenhos e durações legados, sem simular caminhada deslizando um idle. Poucas folhas ambientais e no máximo 96 partículas de ação. Partículas CPU com trajetória analítica foram escolhidas para este pequeno cenário Compatibility; não justificaria manter um sistema GPU paralelo agora. Intensidade e movimento reduzido são centralizados no renderer e kit.

## Custos e riscos

A pode evoluir com os sprites atuais, mas rotações pequenas em buffer nearest podem produzir degraus perceptíveis: avaliar a 1× e nos aparelhos alvo. B facilita cartões, tipografia e sombras nativas, mas pode evidenciar a diferença de densidade entre UI suave e mundo pixelado. B não resolve por shader os problemas de desenho, alpha ou volume dos atlases.

Estimativas de planejamento, não orçamento contratado: integrar a opção escolhida com tokens/componentes e QA completo pode exigir 3–5 dias de desenvolvimento/UI para A, 4–7 para B; a nova biblioteca artística de mundo híbrido, se desejada depois, é trabalho separado e não estimado por este experimento. Refinamento de animação/folhagem e exportação consistente precisam de artista. Nenhuma troca global foi autorizada.

## Materiais ainda necessários

- Folhagem em camadas ou sprites separados para mover folhas sem tronco.
- Poses/frames de galinha com contato e volume revisados; não produzir sistema animal.
- Estágios finais de culturas, alpha limpo e densidade nativa consistente; sprites atuais mantêm ART_REVIEW.
- Revisão dos ícones originais de linha e tipografia final conforme a opção aprovada.
- Masters autorizados de clique, colheita, compra, venda, água, desbloqueio e transição. Integração preserva slots aprovados; ausência resulta em silêncio, sem synth promovido a áudio final.

## Avaliação humana

Comparar beleza, conforto depois de várias coletas, clareza da maturidade, leitura em retrato, resposta a arrasto, ruído de partículas e coerência UI/mundo. Testar intensidade 0/65/100% e movimento reduzido. Escolher A/B/combinação ou solicitar nova rodada; não confundir aprovação visual com segurança online, balanceamento ou aprovação formal dos gates anteriores.
