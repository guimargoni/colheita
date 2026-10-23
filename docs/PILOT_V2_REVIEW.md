# Fazenda Viva — amostra artística independente v2

2026-10-23. Branch `foundation/g0-5r-art-sample-v2`, base `258bdad`.
Nova rodada expressamente autorizada pelo diretor após G0.5-R. **Arte ainda não
aprovada.** Nenhuma substituição definitiva, expansão de catálogo, economia, save
ou G1. Cena F5, G0.4, G0.5 e laboratório G0.5-R preservados.

## O que avaliar

Composição pequena: casa térrea de formas mais simples e porta ampla, dois
exemplares de árvore, cerca, vegetação, chão/caminho, quatro canteiros, morango e
cenoura em estados diferentes, galinha em idle/blink/atenção e interface navy/papel.
A disposição não reproduz o mockup. Quatro é tamanho desta amostra, não limite ou
quantidade inicial/final da propriedade. Contratos de expansão continuam intactos.

Solo e plantas agora são sprites separados. As plantas usam quatro sockets por
canteiro; não há preço, bônus de skin ou calendário. Modelo e árbitro de gestos
G0.4 são reutilizados por composição, sem modificar os scripts antigos.
Tap colhe/planta/rega; arrasto deduplica; hold inspeciona; pan e pinch não agem
nos canteiros. Colheita troca estado imediatamente e toca três desenhos authored
com duração 120/160/220 ms, encerrando o feedback em até 700 ms. Ações não esperam.
FX da cenoura omite a primeira imagem com morango para evitar fruto errado.

## Classificação de entrega

| Material | Classe | Condição |
|---|---|---|
| Botões, painel e ícones novos | FINAL_CANDIDATE | alternativa funcional para avaliação, não aceite/release |
| Casa, árvore, cerca, flores, animal e caminho | ART_REVIEW | proporção/pivô/projeção/pixels precisam validação |
| Solo, culturas e três quadros de colheita | ART_REVIEW | separação funciona; limpeza nativa e bordas ainda pendentes |
| Grama discreta G0.5 reutilizada | ART_REVIEW | origem própria documentada; serve como fundo de prototipagem |
| Novo losango de grama | Reject para repetição | contorno forte criava grade ruidosa, preservado na fonte |
| Fonte Godot e moeda/XP fictícios | PLACEHOLDER | tipografia/valores não são direção definitiva |
| Áudio final | NOT_PRODUCED | amostra intencionalmente silenciosa; plano existente continua válido |
| Três packs históricos | LICENSE_BLOCKED | nenhum arquivo usado, enviado a gerador ou treinado |

Prompts/arquivos/termos/hashes em `PILOT_V2_PROVENANCE.md`,
`PILOT_V2_PROMPTS.json` e `pilot_assets_manifest.json`. Fontes integrais novas:
environment/crops_fx 1254×1254 RGBA, árvore isolada 1122×1402 RGBA e UI
1536×1024 RGBA. Built-in image_gen, sem
CLI, chave ou download externo. `release_approved` permanece false em tudo.

## Comparação com os critérios G0.5-R

- Linguagem: massas mais simples, menos microdetalhes, paleta coerente e porta
  maior são mudanças concretas desta alternativa. Preferência/qualidade final é humana.
- Grade: projeção lógica 32×16, buffer-fonte nearest com zoom inteiro e câmera
  arredondada. Isso não certifica os pixels das imagens geradas como nativos.
- Import: gerador não respeitou grade/resolução exatas. Recortes manuais e tamanho
  lógico fixo por sprite, descritos no JSON. **Ainda há redução e ajuste de proporção
  de raster**, especialmente piso/solo. Não alegar cumprimento integral do padrão
  “arte nova no canvas nativo”. Não houve retocar PNG por código para esconder isso.
- Proporções: casa tem canvas lógico 96×100, árvore 64×80, galinha 12×14. Casa/
  galinha desviam ligeiramente dos alvos iniciais. Sem humano original, relação
  humano/porta continua por validar. Não se corrigiu isso diminuindo zoom por objeto.
- Modularidade: solo separado e sockets são demonstrados, mas o kit completo de
  bordas/vizinhança e transições não foi produzido nem testado como final.
- Animação: três poses novas de galinha e três desenhos de FX, timing específico.
  Não há walk final, anotação anatômica/alpha por frame nem certificação de loop.
- UI: molduras raster com texto e foco reais; fundos simples e foco usam Theme
  nativo, uso técnico de formas escaláveis. Mundo não usa polígonos procedurais.
  UI compacta, porém margem para títulos/status deixa mapa ~68% da altura no PC
  e ~76% no celular; meta desktop >=80% ainda não atingida nesta bancada de avaliação.
- Interação: botões móveis 144 px no canvas 1080 (~48 dp a 3×); alvos de canteiro
  ampliados com atribuição ao centro mais próximo. DPI e ergonomia físicos pendentes.

## Materiais que ainda precisam produção artística

1. Exportar/limpar casa/árvore/galinha no canvas nativo do contrato, com densidade
   comum e pivôs de contato medidos. Gerador raster atual ajuda na direção, mas
   não garantiu esse controle; editor de pixels/animador ou ferramenta dedicada
   de sprites deve fazer a etapa. Entregar PNG e fonte editável, sem cópia comercial.
2. Produzir humano de referência e validar porta/animais juntos antes de aprovar escala.
3. Produzir kit de solo/bordas/caminhos exatamente 2:1, sem margens que criem frestas
   ou linhas duplas, e verificar máscaras. Os recortes atuais são protótipo.
4. Limpar alpha/fringes, cores e frames do animal; depois desenhar movimento se
   autorizado. Efeitos não precisam de mais quadros por regra, e sim por gesto.
5. Selecionar fonte licenciada, revisar disabled/foco/contraste e reduzir área fixa
   desktop; testar celular físico, safe-area e toque real.
6. Produzir som pelo plano já existente se vier a fazer parte do próximo escopo.

Não substituir essas lacunas por geometria ou apresentar a geração como arte final.
Não iniciar uma fazenda inteira ou novas culturas para aumentar volume.

## Evidências técnicas

Teste específico `pilot_tests.gd`: **154 checks PASS** em desktop/retrato, incluindo
recortes dentro dos PNGs, estados, clique/toque pelo viewport real, colheita em três
quadros, plantio durante FX, arrasto sem duplicação, rega/crescimento, pan/pinch,
modal, controles e limites de efeitos sob 80 ciclos rápidos. Regressões e parsing
executados por `tools/check.ps1`. Teste estrutural não aprova estética.

Dez capturas reais de Godot/Compatibility em RX 7600: normal, colheita em
40/180/360 ms e painel, em 1920×1080 e 1080×1920. Sem retoque ou cena promocional.
O relógio da simulação é congelado só pelo script de captura para reproduzir os
instantes. Executável normal anima livremente. Não houve benchmark físico móvel.

**Técnico: executável para revisão. Artístico/release: PENDENTE.**
Limitações nativas acima permanecem abertas e impedem declarar qualidade final
definitiva aprovada. Guia: `PILOT_V2_TEST_GUIDE.md`; arquivos/comandos:
`PILOT_V2_EXECUTION_RECORD.md`. Parar nesta amostra, sem G1.
