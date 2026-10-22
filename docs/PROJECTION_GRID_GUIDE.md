# Perspectiva, grade e câmera

G0.5-R. Proposta validada estruturalmente no Godot 4.7.2; aceite artístico pendente.
Chão ortográfico 2:1, célula-fonte 32×16, eixos +x para baixo/direita, +y para
baixo/esquerda. Altura vertical em pixels-fonte; não inclinar paredes para simular
perspectiva convergente. Edges do chão sobem 1 px a cada 2 horizontais.

`p(x,y,z)=(16*(x-y),8*(x+y)-z)`; inversa para chão z=0:
`x=screen.x/32+screen.y/16; y=screen.y/16-screen.x/32`.
Pivô é o contato com o chão, nunca centro do retângulo de textura. Seleção usa
footprint projetado; copa, telhado, partículas e sombra não aumentam propriedade.
Empate em aresta usa região semiaberta; identificação por coordenada estável,
nunca por índice de linha multiplicado pela largura atual da fazenda.

## Conexão e profundidade

Canteiro 2×2 tem base 64×32; centros adjacentes diferem (32,16) ou (-32,16).
Não incluir margem transparente na largura de ocupação. Caminho ocupa célula;
cerca é uma aresta com terminais compartilhados; prédio tem sockets de porta.
Ordenar chão antes de entidades, depois contato x+y e desempate estável por id.
Prédios altos/árvores devem poder ocultar parcialmente o sprite, mas nunca esconder
o estado ou alvo de canteiro em modo interação: futuro fade/occlusion passa por QA.

## Renderização e migração

Laboratório: SubViewport em baixa resolução, ampliado por inteiro, offset de
câmera arredondado. Sem alterar project.godot ou o renderer anterior. Isso valida
a estrutura pixel-perfect; **a arte G0.5 reduzida para comparação não vira arte
pixel-perfect de origem**. Preview legacy tem um adaptador fixo por tipo, é
rotulado provisório e não deve ser usado para importar a produção final.

Futuro asset normalizado deve ser exportado no canvas do contrato, escala de
Node2D=1, sem stretch individual. Zoom muda a apresentação do mundo inteiro.
Não substituir todos os sprites nem refatorar as cenas aprovadas neste gate.

## Fazenda extensa

Coordenadas podem crescer/ser negativas; futuras parcelas referenciam regiões
com células e permissões separadas da arte. Não há máximo de canteiros decidido.
Cargas de 4×4, 8×8 e 12×12 são **fixtures de laboratório**, sem quota ou inicial
final; alamedas podem reservar espaços e conectar regiões. Bounds de câmera
derivados da extensão ocupada + sprites, não de um retângulo fixo para quatro.

Enquadramento inicial futuro foca área acessível; expansão não reduz escala dos
objetos para mostrar tudo. Visão geral é modo opcional de inspeção. Em overview,
alvos menores que 48 dp não permitem ações agrícolas; aproximar antes de agir.
Zoom inteiro centrado no ponteiro, pan por mouse/toque, pinça com passos e Home
para geral no laboratório. Limites de pan incluem margem, sem perder a fazenda.
