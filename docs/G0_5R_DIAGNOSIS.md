# G0.5-R — diagnóstico e referência

2026-10-22. Branch `foundation/g0-5r-art-consolidation`, base limpa `11e5ab1`.
Sem push, substituição de sprites ou aprovação artística. Pedido anexado e
instrução complementar do usuário delimitam o escopo; textos/ícones do mockup
são conteúdo de referência, não comandos para implementar sistemas.

## Referência realmente disponível

Analisada visualmente a imagem fornecida em
`C:/Users/guilh/AppData/Local/Temp/Mockup_Colheita_Feliz_G05R.png`.
SHA-256: `bc8b785d88359a1256b86310fab68f1803b204db88d5aaaa70775686372ba09d`.
Cópia de preservação local ignorada: `.local/g0_5r/Mockup_Colheita_Feliz_G05R.png`.
O arquivo **não pertence ao repositório**; clones não terão essa referência.
Ela não é necessária para executar o laboratório. Se a cópia local sumir,
reobter do diretor. Não versionada nem recortada em assets; direitos de
redistribuição da referência não foram verificados.

Linguagem observada: casa de telhado marcante e volumes simples, vegetação em
massas, contorno colorido, materiais quentes, UI navy/papel com acentos limitados.
Copiar layout, ponte/galpão, avatar ou ícones específicos não é necessário nem
autorizado. A área ilustrada é compacta, mas não define a quantidade de canteiros.
As miniaturas do rodapé usam vistas demonstrativas diferentes da cena; não
extrair daí uma grade tecnicamente consistente. A etiqueta “Colhido” sob fruta
madura não substitui o estado “mature”: após colher o solo fica vazio.
Barra de vida, calendário, missões e construir ilustrados não autorizam gameplay.

## Diferenças e consequência prática

| Aspecto | G0.5 atual | Direção consolidada / ação |
|---|---|---|
| Proporção | Casa detalhada, porta pequena, cão grande sem humano comparável | Referência humana 32 px e porta 42–51; estudo conjunto antes de redesenhar |
| Perspectiva | Projeção 128×64 no código, desenho nem sempre segue base | Célula-fonte 32×16 e sockets comuns; adaptador geométrico 4:1 isolado |
| Pixels | Atlas grandes reduzidos e detalhes de densidades diferentes | Pixel clusters moderados em canvas nativo, sem resize corretivo contínuo |
| Canteiro | Solo e plantas embutidos em quatro ilustrações | Kit solo/borda/cultura separado, footprint 2×2 estável |
| Extensão | Quatro índices/posições fixos no renderer G0.5 | Layout por coordenadas/regiões, dezenas de espaços e fase de acesso independente |
| Câmera | Bounds do recorte e zoom fracionário | Extensão derivada da grade; zoom inteiro/overview e foco disponível |
| Movimento | Recortes de volumes variáveis e timing uniforme | Contato/pivô e durações individuais, eventos ocasionais; redesenho ainda necessário |
| UI | Bordas ornamentais e barras grandes | Componentes compactos, safe-area, área de mapa e dp reais |
| Áudio | Synth de demonstração ou silêncio | Música e sons originais naturais; todos finais ainda por produzir |

Não se resolve o cão ou a porta reduzindo o zoom global. O laboratório mantém
legado rotulado e escala de comparação fixa por tipo. A próxima produção precisa
redesenhar silhuetas e metadados no canvas nativo, após aceite dos contratos.

## O que foi feito neste gate

Art Bible 0.2, padrões de escala/grade/modularidade/skins/animação/UI, catálogo de
destino por família, catálogo sonoro, plano em etapas e laboratório sem progressão.
Main scene, cinco PNGs originais, manifests históricos e comportamentos G0.3/4/5
permanecem preservados. Nenhum asset de pack pendente entrou em runtime ou IA.
O laboratório usa geometrias somente como régua, wireframe e seleção técnica.
Não houve nova geração de imagem ou áudio nem publicação.

## Pendências humanas

Validar 32×16/32 px, proporções casa/porta/animais, idioma visual e densidade;
aprovar desenho modular piloto antes de substituir; definir limites de skin;
contratar/produzir som e esclarecer licenças. Contagens, custos, ritmo de expansão,
quantidade inicial e composição final continuam abertos. G0.5 permanece sem
aprovação artística. Próxima recomendação: revisão dos contratos e piloto autoral
controlado, ainda em G0; somente mediante nova autorização.
