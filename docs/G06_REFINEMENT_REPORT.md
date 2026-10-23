# G0.6 — refinamento da cena Fazenda Viva

2026-10-23. Base `cc1e874`, branch `foundation/g0-6-style-lock`.

**G0.6 técnico: PASS. G0.6 artístico: PENDING HUMAN APPROVAL.**
PASS técnico significa cena independente executável e checks locais passando;
não certifica qualidade comercial, arte nativa, licença de release ou aparelho real.

## Antes / depois

| Aspecto | v2 preservada | G0.6 |
|---|---|---|
| Estrutura | posições pontuais, caminhos grandes e cerca isolada | malha 32×16, anel/alamedas, cerca em duas sequências conectadas |
| Casa | sprite com caminho aproximado | identidade preservada; entrada ligada à circulação por stamps de terra |
| Horta | quatro bases separadas e estados simulados | mesmos quatro centros/sockets; alamedas regulares e perímetro organizado |
| Animal | canvas 12×14 | canvas 20×23 fixo nas três poses; sem deformação/simulação de caminhada |
| Vegetação | dois exemplares de uma árvore | frutíferas, conífera, arbustos, flores e pedras em planos curados |
| Caminho | tiles grandes com pedras repetidas | tile arenoso autoral sem borda, juntas cobertas, malha compartilhada |
| HUD | título/subtítulo permanentes e toolbar | cabeçalho compacto, acessos de menu, status e ferramentas; sem novo modal agrícola |
| Altura do viewport de mundo PC | 67,8% | 80%; status integrado ao cabeçalho, sem sobrepor a vegetação |
| Altura do viewport de mundo retrato | 76,5% | 78,75%; ferramentas continuam com alvo 144 px na captura 1080 |
| FX | colheita do atlas de culturas | plantio/rega/colheita/recompensa/UI em atlas separado, sem fruto errado |
| Áudio | ausente na amostra | integração com slots aprovados e buses; permanece silencioso por falta de masters |

Capturas `.local/g06/index.html`: 21 PNGs reais, 1920×1080 e 1080×1920,
comparação com v2 renderizada no mesmo processo, detalhes 6× de casa/horta/animal,
menu, três instantes de colheita e três poses da galinha. A galeria permite
reproduzir a sequência de capturas; não é gravação contínua nem mockup retocado.

## Avaliação visual efetuada

As primeiras capturas revelaram quadriculado verde entre tiles de caminho e
perímetro cortado no celular. Material de chão corrigido por nova geração de arte,
posições/perímetro compactados; nada foi corrigido por redesenho geométrico.
Conífera posicionada em outro plano para evitar alinhamento vertical com frutífera.
Porta recebe ligação contínua e os terminais das cercas têm coordenadas comuns.
Existe abertura intencional entre as sequências. Todos os canteiros ficam visíveis
e recebem ação no enquadramento normal; vegetação não cobre sua informação.

O resultado é apresentado para julgamento do diretor. Ainda há repetição da grama
herdada, bordas de terra duras, contato/sombra da casa herdado e diferenças de
densidade entre fontes. Não chamar esses pontos de acabamento comercial concluído.
Falta avaliar uma borda orgânica de caminho, sombras autorais compatíveis, terminais
de cerca e redução de microdetalhes nas culturas em pixel nativo.

## Interação, movimento e áudio

Mesmo modelo local e árbitro de gestos G0.4 por composição, sem editar os legados.
Tap colhe/planta/rega; paint deduplica IDs; hold inspeciona; pan/pinch cancelam
ações. Interação não espera FX. No máximo 16 efeitos simultâneos. Fontes, valores
de HUD e crescimento acelerado continuam demonstração, sem autoridade econômica.

Galinha usa as três poses originais com 2,4 / 0,12 / 0,55 s e pés/pivô constantes
em dados. Não há escala pulsante, deslocamento artificial ou walk cycle alegado.
FX de folhas e brilhos evolui por desenhos; recompensa é apenas visual. Movimento
reduzido congela idle e deslocamento do efeito. Pontos de áudio plant/water/harvest/
button e ambience reutilizam `review_audio.gd`; reward tem slot preparado no catálogo.
Sem arquivo aprovado = silêncio. Não foram criados tons synth ou trilha substituta.

## Qualidade dos materiais / próximos passos artísticos

Todos os novos PNGs são ART_REVIEW e `release_approved=false`. UI herdada é apenas
FINAL_CANDIDATE; tipografia padrão é PLACEHOLDER. Inventário completo de novos e
reutilizados em `G06_PROVENANCE.md` e `g06_assets_manifest.json`.

O gerador entregou raster em alta resolução, não uma matriz nativa garantida. A
adaptação fixa por tipo é explícita e não mudou entre poses. Para biblioteca final:

1. Artista/editor de pixel art deve redesenhar/normalizar casa, planta, animal,
   vegetação e tiles no contrato, com arquivo editável e alpha limpo.
2. Medir bounds, pés e sombra por frame; aprovar variações de volume e loop.
3. Produzir transições de terreno e terminais de cerca, sombra de contato autoral
   e kit modular de bordas. Água/poço não foram incluídos: referências não exigem
   copiar todos os seus objetos; não havia arte adequada aprovada.
4. Definir fonte licenciada; validar dp, insets e legibilidade em aparelho físico.
5. Produzir música/SFX masterizados segundo `AUDIO_PRODUCTION_PLAN.md`; realizar
   escuta prolongada, loops e mix. Nenhum áudio final disponível nesta sessão.

Estimativa de trabalho humano, não orçamento: normalização/polimento desta família
3–5 dias de pixel artist; tiles/bordas/sombras 1–2; animação/QA de contato 1–2;
integração/QA móvel 1–2. Som/música conforme plano sonoro existente, em separado.

## Validação técnica e limites

329 checks G0.6: bounds de atlas, projeção/inversa, ocupação sem conflito de casa/
árvores/canteiros, terminais de cerca, enquadramento, HUD sem cortes/sobreposição,
mouse/toque via viewport real, colher/plantar/regar, arrasto, pinça sem ação,
câmera, repetição rápida, FX limitados, modal, movimento reduzido e silêncio seguro.
Regressões G0.3/G0.4/G0.5/G0.5-R/v2 continuam no check completo.
Sem errors de parsing/runtime no run final. Captura gráfica via Compatibility/RX7600;
não constitui benchmark Android nem certificação de 30/60/120 fps em aparelhos.

Sem blocker de execução local. Pendências acima são de produção/avaliação humana;
não foram escondidas por placeholders. G0.4/G0.5/G0.5-R/v2, PNGs anteriores,
contratos extensos e entrada F5 ficaram preservados. Sem G1, progressão, economia,
backend, multiplayer, exportação pública ou push. Parar nesta revisão.
