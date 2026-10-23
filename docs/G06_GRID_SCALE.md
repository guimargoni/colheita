# G0.6 — grade, encaixe e escala estilizada

Contrato de bancada `cozy.iso.g06`, schema 1. Fonte executável:
`game/data/art/g06/reference.json`; gerador determinístico `tools/build_g06_data.py`.
Não modifica `visual_standard.json`, skins ou fixtures extensas anteriores.

## Grade e ocupação

`p(x,y,z)=(16(x-y),8(x+y)-z)`; inversa no chão
`(sx/32+sy/16, sy/16-sx/32)`. Célula 32×16; posições estruturais em células,
inclusive negativas. Meias células reservadas às alamedas entre canteiros.
Objeto guarda ID, tipo, contato `at`, origem e footprint independentes do canvas.
Intervalos de ocupação semiabertos `[origin, origin+footprint)`. Sem editor de
decoração, persistência, compra, desbloqueio ou limite de fazenda implementado.

Quatro centros `(0,0),(3,0),(0,3),(3,3)`, footprint 2×2 a partir de centro−(1,1).
Passo 3 deixa uma célula entre canteiros. Quatro sockets por solo, compartilhados
por estágios. Solo/cultura separados. Hit area confortável 64×48 no buffer, com
desempate pelo centro mais próximo; não depende de folhas ou altura do telhado.
No retrato normal 4× isso dá 256×192 px. Conversão dp real depende do aparelho.

Casa: footprint 4×4, contato (-3,-3), origem (-5,-5). Entrada desenhada na fachada
usa socket local aproximado (21,-2). Sete stamps de terra sobrepostos conectam
(21,-50) a (48,-24); não há salto ao primeiro nó do anel. Ajuste fino de socket
aguarda fonte nativa. Anel nos eixos x/y=−2/5; alamedas centrais x/y=1,5. O tile
arenoso sem borda ocupa canvas 34×18 para cobrir as juntas da célula 32×16; é uma
adaptação de apresentação explícita, não certificado de autotile seamless final.

Cercas são arestas de duas células, não retângulos agrícolas. Duas direções
desenhadas; terminais de cada sequência coincidem em dados, incluindo os pontos
compartilhados. Existe abertura intencional entre as duas sequências dianteiras.
Não rotacionar a imagem para fingir outra projeção/luz. Posts compartilhados
se sobrepõem no mesmo contato; limpeza de terminais a 1 px é QA artístico pendente.

Chão/caminhos antes dos objetos; objetos, canteiros e cercas em uma fila única,
ordenada por x+y e ID estável em empate. Pivô é contato do chão. Detalhes naturais
ocupam posições curadas fora dos canteiros, sem randomização por frame. Futuro
placement poderá consumir ocupação/sockets; não deve usar a silhueta como colisão.

## Escala G0.6

| Família | Canvas lógico usado | Relação com referência humana 32 px | Intenção |
|---|---|---|---|
| Casa | 96×100 | altura do canvas 3,13 u | presença central; mesma identidade da v2 |
| Árvore frutífera | 64×80 | 2,5 u | copa em massas; raízes fora da horta |
| Conífera | 38×68 | 2,13 u | variedade de silhueta em segundo plano |
| Galinha | 20×23 | 0,72 u | exagero expressivo consistente, maior que v2 12×14 |
| Cultura madura | 20×18 | 0,56 u | fruto destacado, quatro sockets legíveis |
| Arbusto | 40×30 | 0,94 u de canvas | borda baixa, sem competir com objetos interativos |

Essas são dimensões de apresentação, não medidas de alpha nem tamanhos nativos
dos PNGs. Humano é régua abstrata; não existe personagem novo de produção.
O padrão G0.5-R 10–13 px de galinha fica histórico; G0.6 propõe 23 px fixos por
tipo, iguais entre poses, sujeitos a aprovação. Não aplicar aumento arbitrário
em instância, estágio ou frame. Porta mantém o desenho da v2; validação com humano
original em escala nativa ainda necessária. Skins futuras precisam manter sockets,
footprints e interação mesmo se trocarem os pixels.

## Câmera / nitidez

Buffer baixa resolução, nearest, posição arredondada e zoom inteiro 2…6 PC /3…6
retrato. Home enquadra bounds [-134,-150,268,260], zoom normal 3× PC /4× retrato.
Zoom ancorado no ponteiro/pinça; pan limitado; movimento reduzido congela idle e
retira deslocamento de FX sem ocultar estados. UI tem escala independente.
Capturas de aproximação usam 6× de câmera, não upscale posterior.

Native-pixel QA ainda não foi satisfeito: atlas do gerador em alta resolução,
recortes reamostrados por tipo, densidades não rigorosamente iguais. A estrutura
organiza o cenário, mas não normaliza os sprites. Produção final exige editor de
pixel art, fontes editáveis, alpha/bounds/contato por frame e QA 1×/3×/4×.
