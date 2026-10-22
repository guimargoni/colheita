# Art Bible — Cozy Pixel Art · Fazenda Viva

G0.5-R, revisão 0.2, 2026-10-22. Direção de trabalho estabelecida pelo usuário;
**implementação final, sprites, UI e áudio continuam aguardando avaliação humana**.
G0.5 foi aprovado tecnicamente, não artisticamente. Versão anterior preservada no
Git em `11e5ab1:docs/ART_BIBLE.md`; suas medidas eram de um estudo legado.

## Referência e limites

Mockup `Mockup_Colheita_Feliz_G05R.png` foi efetivamente analisado fora do
repositório, no anexo/Temp informado pelo usuário. Registro e hash em
`G0_5R_DIAGNOSIS.md`; cópia privada ignorada em `.local/g0_5r/`.
Não é runtime asset, layout aprovado, sprite-sheet para recortar nem autorização
de redistribuição. Suas etiquetas e números são referência, não regras de gameplay.

A direção combina silhuetas simples, arquitetura expressiva, vegetação em massas,
cores naturais, volume claro e detalhe moderado. Evitar hiper-realismo, filigrana
por toda superfície, ruído retro e mistura de densidades. Usar a referência para
qualidade/proporção, sem reproduzir literalmente composição, UI ou obra comercial.

**Quatro canteiros são apenas a amostra histórica.** A fazenda deve acomodar dezenas
de espaços, parcela inicialmente disponível, regiões bloqueadas e expansão/
personalização. Quantidades inicial/final e custos permanecem sem decisão.

## Sistema visual único

- Chão 2:1 com célula-fonte proposta 32×16; personagem de referência 32 px de altura.
- Footprint, canvas, pivô, sombra, encaixe e interação separados em metadados.
- Arte nova no canvas nativo, sem resize individual para remediar proporções.
- Buffer de mundo com câmera arredondada, nearest e apresentação inteira.
- Prédios/cercas/caminhos/canteiros usam a mesma malha; sem perspectiva convergente.
- Casa expressiva de volumes simples e porta compatível com personagem.
- Bordas e solo modulares separados das plantas; estados e skins não mudam hit map.

Padrões completos: [escala](VISUAL_SCALE_STANDARD.md),
[projeção/grade](PROJECTION_GRID_GUIDE.md), [canteiros](MODULAR_PLOTS_SPEC.md),
[skins](SKIN_CONTRACTS.md), [animação](ANIMATION_GUIDE.md) e
[UI/câmera](UX_FRAMING_STANDARD.md). Fonte estrutural proposta:
`game/data/art/visual_standard.json`; não representa assets finais existentes.

## Paleta, luz e superfícies

Paleta de trabalho (seleção própria orientada pela referência, não amostragem
de sprites comerciais): natureza #A4BD79/#5D995C/#277365; terra #AA734C/#D79553;
reboco #F0D5A8; telha #C85537/#A13C31; estrutura #665A51; água/UI
#56AAC7/#218AAD e acento #F2C34E; texto/contorno navy #203D4A, papel #FFF2D5.
Validar contraste da UI em fundos reais antes de congelar códigos.

Luz superior esquerda, sombra para baixo/direita, 18–28% de opacidade, contato
firme no solo. Três a cinco tons principais por material, contorno colorido
1 px na matriz-fonte (2 px só onde silhueta exige). Sem brilho plástico geral.
Saturação maior em frutos/ações; superfícies repetidas de baixo contraste.

Grama com poucas touceiras, sem flores uniformes por toda tile. Flores nas bordas,
árvores com três massas de folhagem e tronco legível; copa não encobre canteiro ativo.
Água futura azul/teal em camadas simples, reflexos contidos; frames conforme gesto,
não número universal. Ainda não produzida. Estações/eventos repetem luz/projeção,
alteram vegetação/ornamento; Halloween tem blink/brilho gentil sem sacrificar leitura.

## Movimento, UI e som

Animação parte da intenção e contato, usa durações individuais e eventos ocasionais;
sem escalar o corpo inteiro como substituto de respiração desenhada. Medir alpha,
pivô, pés e volume por frame. Os animais G0.5 têm desvios ainda não corrigidos.
FX curtos e não bloqueantes; opção de movimento reduzido.

UI temática compacta: ícones simples, papel/navy/teal, acento dourado contido.
Moeda/nível no topo, ferramentas contextuais embaixo, acessos secundários recolhíveis.
Fonte de produção ainda por escolher; não copiar fonte/ícones da referência.
Contraste alvo 4,5:1 para texto, foco visível, alvos 48 dp, safe-area real.
Fazenda visível alvo >=80% desktop / >=75% mobile, fora modais temporários.

Áudio acolhedor, natural, suave e memorável: produção e mix em
`AUDIO_PRODUCTION_PLAN.md`. Todo synth atual é placeholder; não há trilha final.

## Aprovação e preparação

Laboratório isolado: `scenes/art/art_lab.tscn`, sem alterar entrada principal.
Usa comparadores G0.5, régua, guias, layouts extensos e paleta técnica. Não apresenta
arte reduzida nem linhas de debug como conteúdo final. UI da bancada não é o HUD final.

Critérios humanos: escala humana/porta/animal coerente; nenhum salto de pivô;
solo contínuo em adjacência; leitura de disponível/bloqueado/cultivo/vazio; 95%
de acerto em 20 ações intencionais; zoom/pan sem ação acidental; contraste e conforto
em aparelho real; origem/licença e identidade aprovadas por família.

Matriz de destino: `G0_5R_ASSET_MATRIX.csv`. Etapas, custos e dependências:
`G0_5R_IMPLEMENTATION_PLAN.md`. **Nenhuma substituição artística definitiva
antes dessa validação. Não avançar para G1.**
