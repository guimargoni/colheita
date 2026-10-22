# Padrão de escala — Cozy Pixel Art / Fazenda Viva

G0.5-R, 2026-10-22. **Contrato proposto, pendente de validação humana.** Fonte
estrutural: `game/data/art/visual_standard.json`, schema 1, `cozy.iso.v1`.
Os assets G0.5 são comparadores legados e não passam a atender este padrão por
serem exibidos no laboratório. Altura humana é referência métrica; sprite humano
original ainda não existe. Não adotar a régua do mockup como medição dos PNGs atuais.

## Unidade e proporções

Uma unidade de altura = **32 pixels-fonte** de personagem em pé, sem chapéu/VFX.
Uma célula de chão = losango 32×16; são medidas diferentes. Altura visual não
determina ocupação. Footprint é em células inteiras, independente de zoom ou skin.

| Tipo | Altura visual alvo | Footprint proposto | Canvas máximo / pivô de chão |
|---|---|---|---|
| Personagem | 32 px / 1,0 u | 1×1 | 32×48 / (16,44) |
| Cachorro sentado | 18–22 px / 0,55–0,70 u | 1×1 | 32×32 / (16,28) |
| Galinha | 10–13 px / 0,30–0,40 u | 1×1 | 24×24 / (12,20) |
| Árvore | 64–96 px / 2–3 u | 2×2 | 96×112 / (48,96) |
| Casa piloto | 96 px / 3 u, a validar | 4×4 | 160×176 / (80,136) |
| Porta | 42–51 px / 1,3–1,6 u | encaixe na fachada | medida separada da casa |
| Cerca | 15–21 px / 0,45–0,65 u | aresta de 1 célula | 48×40 / (24,30) |
| Canteiro | solo 64×32; plantas até 48 px acima | 2×2 | 72×64 / (36,48) |

Canvas é reserva máxima, não promessa de preencher todos os pixels. A altura
acima do chão é separada de sombra/profundidade. Na casa, o canvas
reserva também a metade frontal do footprint abaixo do pivô central;
altura 96 px não é a altura total desse retângulo de reserva. Uma cerca
ocupa aresta (1×0), não célula agrícola. Árvores podem exceder footprint no alto,
sem bloquear visualmente plantas maduras no enquadramento de interação.
As proporções casa/porta precisam de estudo autoral: a casa G0.5 tem porta pequena
demais para simplesmente reduzir o PNG. **Redesenhar proporções**, não corrigir
com escalas diferentes a cada objeto/frame.

## Metadados por tipo/asset

Campos obrigatórios: id estável, categoria, logical_canvas, footprint, pivot,
visual_bounds, reference_height, snap_points, shadow, interaction, directions,
animation, allowed_presentation_scales, skin_contract, status e release_approved.
Limites visuais são [x,y,w,h] dentro do canvas, incluindo silhueta e sombra;
pivô em pixels do canvas. Encaixes e sombra usam deslocamento relativo ao pivô.
Em frames futuros: rect, duration_ms, pivot, content_bounds, feet_contact,
shadow_anchor e motivo de variação intencional. Sem esses dados não promover animação.

Encaixes piloto: pés/raiz (0,0); mão (-8,-18); porta (-14,-12), saída de caminho
(-14,4); cerca (-16,-8)/(16,8); canteiro N/E/S/W (0,-16)/(32,0)/(0,16)/(-32,0)
e quatro sockets de cultura. Validar medidas da fachada no desenho antes de fixar.

## Adaptação técnica e QA

G0.5 usa 128×64 = 4× a célula proposta. Conversão geométrica é exata dividindo
coordenadas projetadas por 4; **não** reduz automaticamente os pixels desenhados,
as portas ou os pivôs. G0.3/G0.4/G0.5 ficam intactos; o laboratório usa outro modelo.
Escalas de apresentação inteiras 1×…6×, câmera arredondada no buffer-fonte,
nearest e sem mipmap. UI tem escala própria, sem ampliar fontes bitmap do mundo.

Teste estrutural valida bounds, pivô, campos, footprints e sockets. Teste de pixel
real ainda exige o sprite normalizado e o canal alpha: pés <=1 px de variação,
sem mudar volume involuntariamente; nenhuma imagem existente foi certificada assim.
Inspecionar personagem/porta/cão/galinha juntos em 1×, 3× e 4× antes de aceitar.
