# G1.5 — catálogo histórico documentado, revisão 1

Pesquisa consultada em 2026-10-26. Auditoria-base G1H permanece preservada.
H = descrição contemporânea de comportamento; M = registro comunitário específico,
sem corroboração independente suficiente para congelar valores. Uma fonte de 2009
pode conter atualizações posteriores: não atribuir tudo à versão inicial.

## Fontes e distinções

- **S2**, [Zemarcos, tutorial iniciado em 2009](https://www.blogdozemarcos.com/2009/11/agora-sou-fazendeiro-virtual.html):
  plantio/depósito, flores/presentes e catálogo citado em atualizações.
- **S3**, [FAQ de dezembro de 2009](https://aplicativosdoorkut.blogspot.com/2009/12/colheita-feliz.html):
  estágios e flores no sistema de presentes. Confiança H para a categoria/mecânica,
  não para a regra comercial de uma espécie particular.
- **S5**, [arquivo comunitário de novidades 2010–2011](https://supercolheitafeliz.webnode.com.br/novidades/):
  registros datados de espécies e temporadas. Confiança M; nomes de versões e
  períodos não são intercambiáveis. Páginas foram lidas, sem baixar suas imagens.

## Inventário mais amplo

| Cultura | Categoria | Registro/versão | Confiança | Situação G1.5 |
|---|---|---|---|---|
| Nabo | hortaliça | S2, tutorial clássico | M | documental |
| Beterraba | hortaliça | S5, julho/2010, 2.0 | M | documental |
| Cebola | hortaliça/multicolheita | S5, agosto/2010, 2.0 | M | documental |
| Feijão | hortaliça/multicolheita | S5, agosto/2010, 2.0; três colheitas | M | jogável com parâmetros provisórios |
| Arroz | cereal/multicolheita | S5, agosto/2010, 2.0; quatro colheitas | M | documental |
| Cevada das Terras | cereal/multicolheita | S5, agosto/2010, tema regional | M | documental |
| Hortelã | erva | S5, setembro/2010, 2.0 | M | documental |
| Capim-limão | erva | S5, setembro/2010, 2.0 | M | documental |
| Bromélia | ornamental/multicolheita | S5, setembro/2010, 2.0 | M | documental |
| Rosa vermelha | flor | S5, guias 2.0; S3 para flores em geral | M | jogável com parâmetros provisórios |
| Rosa amarela | flor | S5, junho/2010 | M | documental |
| Flor de Sol | flor | S5, junho/2010 | M | documental |
| Cacau | fruto; forma visual a corroborar | S2, atualização de período incerto | M | documental |
| Noz | fruto; forma visual a corroborar | S2, atualização de período incerto | M | documental |
| Árvore romântica chinesa | árvore de evento | S5, abril/2011, versão posterior | M | documental; não árvore genérica da versão clássica |

Não preencher economia/arte dessas 13 entradas documentais com números inventados:
preço, nível, duração, rendimento e sprite de implementação permanecem indefinidos.
Berinjela constava no inventário inicial G1H, mas não foi localizada na página
consultada nesta rodada; permanece hipótese da auditoria, sem nova confirmação.
Nenhuma lista de recriação moderna ou de Fazenda Feliz foi usada como prova.

## O que é histórico versus nosso protótipo

Feijão com novas colheitas é uma reconstrução funcional apoiada em S5. Os seus
600 s iniciais, 300 s de recuperação, preço, XP e produção são **provisórios nossos**,
substancialmente diferentes das horas descritas pela fonte. Não anunciar números
como originais. Rosa é uma espécie documentada, com arte e economia novas.
Flores aparecem em presentes no FAQ clássico; guias posteriores descrevem venda.
O G1.5 permite guardar/vender por instrução do diretor, preparando `gift_future`
em dados, sem implementar amigos, popularidade ou buquês.

**Abóbora Amaldiçoada** e o evento de demonstração são originais do projeto,
explicitamente modernização demonstrativa autorizada, não recuperação de item
histórico. Cenoura, morango e trigo são os exemplos legados G1.1–G1.4 preservados;
esta pesquisa não os promove a comprovação histórica individual.

Dados jogáveis completos/versionados: `game/data/farming/g15/crops.json`,
`economy.json`, `care.json`, `fertilizers.json`, `events.json`, `art.json`.
Fonte/confiança e estado provisório acompanham os registros. Árvores e os demais
nomes documentais não foram apresentados na loja como funcionalidades prontas.
