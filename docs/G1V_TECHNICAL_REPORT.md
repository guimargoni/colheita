# G1.V — Relatório técnico e pendências

2026-10-26. Base `c326268`, branch `experiment/g1v-visual-gamefeel`.

**G1.V técnico: PASS. G1.V direção visual: PENDING HUMAN DECISION.**

## Implementação

Cena exclusiva `game/scenes/farm/g1v/farm.tscn`, launcher `JOGAR_G1V_TESTE.cmd`. Controller de apresentação derivado por cópia do G1.5, retirando layout/estúdio/acento legados e substituindo UI/renderização. Não houve refatoração de domínio/serviços/economia. Reutiliza schema 5, FarmStore, serviço de culturas, gestos, regras e cuidados existentes. Dados econômicos, custos de expansão e catálogos G1.5 ficam byte a byte iguais.

Saves somente `user://g1v_fast.json` e `user://g1v_local.json` por padrão. Override explícito `--g1v-save=` serve para uma rodada adicional, não deve apontar para save principal. Fixture só é preparada quando a revisão é zero: conquista 32 XP por cultivo/venda e compra/planta culturas via comandos, com relógio controlado anterior à sessão, restaurando depois o relógio original. Não há recompensa emitida por animação, debug grant permanente nem reset automático de saves existentes. Falha de save permanece visível e não é substituída silenciosamente.

Renderer estende G1.5 e mantém projeção, posições/hit map e renderização nearest em buffer com escala inteira. Solo e casa imóveis; plantações/vegetação têm pivô e fases; galinha decorativa preexistente reintroduzida com seus frames, sem produção animal. Partículas desenhadas via CanvasItem, trajetória analítica por tempo decorrido, arrays limitados, ghosts de colheita com prazo de 380 ms. Nenhum delay impede o serviço de processar novas ações. Texto XP é delta real entre snapshots. Contadores usam interpolação exponencial de tempo.

Kit de Controls nativos reutilizável: superfícies A/B, estados de botão, foco e resposta curta por Tween. Ícones de linha originais em código, thumbnails dos sprites e cartões. Compra em quantidade, venda parcial e selecionada continuam; service recalcula preços e recompensas. Shell de painéis tem scrim e transições curtas; referência modal é liberada ao fechar e controles em saída são desativados. Tooltip continua contextual, com estilo compartilhado. Intensity e reduced motion não modificam estado lógico; preferências nesta sessão, sem persistência nova.

Áudio usa adaptador e slots legados aprovados para clique, harvest, buy, sell, water, unlock e UI. Nenhum master pendente é carregado. Não há dependência externa, áudio sintético final, fonte baixada, arte comercial copiada ou treinamento.

## Validação executada

- Importação headless do editor e smoke da cena sem erro de parsing.
- Suite completa dos gates anteriores até G1.5 PASS; G1.V inicialmente 68 checks nessa rodada.
- Suite G1.V ampliada: 88 checks PASS, quatro resoluções (1920×1080, 1080×1920, 1280×720, 720×1280). Mouse/toque, hit map, A/B sem mutação, compra em lote/venda parcial, replay durante recuperação, partículas limitadas/expiração/trajetória analítica, movimento reduzido, câmera sem ações e painéis.
- 12 capturas GPU reais e 144 frames para dois GIFs. Material privado ignorado, com scripts reproduzíveis. Inspeção visual de fazenda e loja em retrato/desktop.
- Benchmark PC: quatro amostras de 240 frames após aquecimento, RX 7600, Compatibility. Métodos/limites em `G1V_PERFORMANCE.md`; sem alegar medição mobile.
- Verificação Git de preservação do runtime anterior, integridade do repositório e whitespace. Lista de arquivos e comandos em `G1V_EXECUTION_RECORD.md`.

## Limites e pendências

Sem blocker técnico conhecido para o experimento local. O salto visual pretendido e o conforto do movimento exigem avaliação do diretor jogando. A/B diferem principalmente em superfícies e luz, não representam novo mundo híbrido produzido. UI nativa ainda precisa de refinamento artístico e de acessibilidade em aparelho real. A arte mantém ART_REVIEW e restrições de distribuição anteriores.

Rig de folhagem, limpeza de sprites, volume/contato dos animais, fontes e áudio final precisam produção dedicada; lista em `G1V_VISUAL_COMPARISON.md`. Micro-rotação no buffer nearest pode mostrar degraus; avaliar a 1×. Não houve dispositivo físico, prova de densidade/safe area, benchmark móvel intermediário, stress de dezenas de terrenos ou segurança online. Save/relógio continuam manipuláveis e não autoritativos. Capturas/GIF não aprovam game feel.

Nenhum avanço para G1.6/G2; nenhum aceite humano de G1.4/G1.5 inferido.
