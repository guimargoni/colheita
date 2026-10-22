# G0.5 — relatório de qualidade e limitações

2026-10-22. **Avaliação artística pendente do diretor.** Nenhum avanço para G1.
Direção A e interação G0.4 são premissas autorizadas no pedido; não há aprovação
implícita dos sprites, UI ou áudio final.

## Preservação e preparação

Encontrado G0.4 inteiro não commitado sobre `298d833`. Preservado em `e2f075f`
na branch `foundation/g0-4-experience`, com relatório e 15 checks novos. Corrigidos
somente problemas indispensáveis: rótulos móveis excedendo botão, hover repetido
e encerramento dos players. Depois criada `foundation/g0-5-art-bible`.
Integrado `origin/foundation/game-design` em `85cc8a9`, após `merge-tree` sem
conflitos: trouxe apenas `ASSET_FIRST_PRODUCTION_POLICY.md`, sem sobrescrever
os trabalhos locais. Nenhum merge com conflito foi realizado.

Lidos AGENTS, GDD, arquitetura, roadmap, pipeline, política, direção sonora,
progressão, decisões e relatórios/direção existentes. Os arquivos pedidos
`UX_GAME_FEEL.md` e `FARM_VISUAL_SCALE.md` **não existem no checkout nem na árvore
remota inspecionada**; a Art Bible contém propostas novas de escala/UX, não uma
atribuição fictícia a documentos ou decisões anteriores.

## Entrega executável

Casa, árvores, cerca, grama/caminho, quatro canteiros com cenoura/morango e estágios,
galinha idle/walk, cão idle/atenção, quatro sprites de FX com animação runtime,
UI Kit com estados reais e conceito sazonal. Renderer principal usa texturas
originais; geometria antiga só no modo antes, sem promoção para arte final.
Modelo/gestos G0.4 reutilizados sem rede, carteira, inventário econômico ou save.
Cinco PNGs originais e metadados de import são as únicas novas artes versionadas.

Som final não produzido. Há brief detalhado e integração com slots aprováveis;
ausência cai em silêncio. SFX synth G0.4 opcionais, rotulados temporários.
Não se declara identidade audiovisual definitiva sem audição/avaliação humana.

## Evidências técnicas

Godot 4.7.2 stable, Compatibility; checks locais em Windows:

| Verificação | Resultado |
|---|---|
| Estrutura, segredos básicos, quarentena e hashes | PASS, 5.946 gráficos/6.158 fontes preservados |
| Foundation/serviço mínimo | PASS |
| G0.3 regressão | PASS, 480 checks |
| G0.4 regressão | PASS, 15 checks |
| G0.5 regressão | PASS, 418 checks |
| Editor/import e boot | PASS, sem erros de parsing ou runtime no conjunto |
| Capturas GPU 1920×1080 / 1080×1920 | PASS, 8 PNGs reais |

G0.5 verifica mouse/toque através do viewport, plantar/regar/colher, arrasto rápido
sem dupla ação, pinch sem mutação, pan, limites de FX sob 100 ciclos rápidos,
IDs/pivôs de seleção, câmera inalterada na comparação, modais, disabled e controles
sem sobreposição em 1920×1080, 1080×1920 e 720×1280. Targets móveis de botões
>=132 px lógicos. Nenhum teste equivale a aprovação estética ou aparelho físico.

Amostra RX 7600: mediana ~5,5–5,8 ms e p95 ~6,0–6,7 ms por frame em execução gráfica,
incluindo cadência do driver/GPU. Apenas 60 amostras após aquecimento por resolução,
com layout de retrato no PC; não benchmark Android, memória térmica ou garantia 60 fps.
Logs reais ficam em `.local/g0_5/capture*.log`; resultados podem variar na regeneração.

## Limitações registradas

- Densidade de pixels não totalmente uniforme, antialias e sombras embutidas pedem
  limpeza humana antes de release. Ampliação não transforma o atlas em pixel art final.
- Casa/árvore são detalhadas; bichos têm proporção mais caricata. Diretor precisa
  decidir se a diferença é carisma compatível ou pede redesenho da família.
- Atlas não cumpriu grade rígida do ambiente; recortes manuais não destrutivos.
  Frames animais variam em volume e pés; não passam automaticamente em <=1 px.
- FX são quatro sprites authored com fade/movimento, não ciclos desenhados completos.
  Água de cenário, humano, noite e estações completas não produzidos.
- HUD estático e fonte padrão de avaliação; UI com bordas ornamentais pede decisão
  sobre sobriedade. Contraste sobre gramado, disabled e safe-areas precisam QA humano.
- Documentos UX/escala citados ausentes; áudio final e revisão auditiva pendentes.
- Direção da câmera/toque em hardware físico, leitor de tela e plataforma móvel
  não validados. Nenhuma exportação/loja pública realizada.
- Outputs originais têm proveniência/termos registrados, mas revisão de IP,
  contrato da conta, release e packs históricos permanecem humanos.

## Status

**G0.5 técnico: PASS para avaliação da amostra**, com alternativa de áudio por
especificação conforme pedido. **G0.5 artístico/release: PENDENTE**. Os limites
acima impedem declarar arte final ou direção audiovisual definitiva aprovada.
Próxima ação é avaliação do diretor, não produção de mais culturas nem G1.

Detalhes de arquivos/comandos: `G0_5_EXECUTION_RECORD.md`; roteiro:
`G0_5_TEST_GUIDE.md`; custos: planos de produção.
