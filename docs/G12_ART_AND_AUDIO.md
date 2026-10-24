# G1.2 — arte, áudio e proveniência

2026-10-24. Cozy Pixel Art — Fazenda Viva preservada. Nenhum PNG anterior foi
modificado ou promovido para release. Trigo/etapa de morango, proximidade dos
canteiros e substituição do caminho continuam pendentes conforme G1.1.

## Novo atlas original

`game/assets/art/g12/care_atlas_v1.png`: seis sprites (ervas, dois insetos e quatro
sacos de fertilizante). Output original do **image_gen integrado**, uma chamada,
sem CLI/chave, modelo específico não exposto. Input de estilo: somente o atlas
original próprio `game/assets/art/g05r_pilot/crops_fx_v1.png`. Nenhum pack terceiro,
imagem histórica ou anexo comercial foi enviado ao gerador; nenhum treinamento.

Fonte integral preservada em:
`C:/Users/guilh/.codex/generated_images/01a15fca-1b40-7bf0-9361-e1db11aceaf7/exec-ea15742d-76a9-4389-8dc0-9171da191523.png`.
Prompt completo em `G12_PROMPTS.json#care_atlas`; hash/dimensões reais/condições em
`g12_assets_manifest.json`. Regiões/canvases/pivôs em `data/farming/g12/art.json`.
PNG/alpha integrais copiados, sem edição por Python ou recorte destrutivo.

Classificação: **ART_REVIEW**, `release_approved=false`. Aprovação conceitual do
estilo não aprova os pixels, seus direitos de release ou a densidade nativa.
Termos/origem seguem o registro de serviço já consultado em `PILOT_V2_PROVENANCE.md`;
não atribuir CC0, exclusividade ou proteção autoral automática. Revisão humana de
contrato/IP/embedding permanece necessária antes de distribuição.

O gerador entregou um raster em alta resolução, sem garantia de grade nativa.
Renderer usa recortes e dimensões lógicas fixas, nearest no mundo, adaptação por
tipo explicitamente de avaliação. Ervas e pragas ficam na borda do solo e não
alteram hit map. Produzir export nativo, alpha limpo e contatos medidos antes da
biblioteca final. Não foi usado desenho geométrico para substituir esses sprites.

## Animação e UI

| Feedback | Entrega | Estado |
|---|---|---|
| Rega | gotas authored do atlas G0.6, fade/movimento curto | ART_REVIEW, timing provisório |
| Remoção de ervas/pragas | burst de folhas/brilho herdado G0.6 | PLACEHOLDER de animação específica |
| Fertilização/crescimento acelerado | folhas → brilho authored, sem alterar autoridade | PLACEHOLDER de animação específica |
| Pronto | estrela discreta estática em cada maduro | ART_REVIEW; clipe de prontidão pendente |
| Ferramentas | ícones novos sobre botões de raster existentes | ART_REVIEW, UI candidata herdada |
| Timer contextual | cartão de UI nativa, papel/navy, texto perto de um canteiro | interface técnica; fonte Godot provisória |

Os efeitos são curtos e não bloqueantes. Não escalar animais/culturas inteiros para
fingir desenhos novos. Movimento reduzido preserva feedback textual/estado e tira
deslocamento ambiental. Não há loop artificial de insetos ou animação final alegada.
Carregar save não reexecuta recibos nem FX; reenvio idempotente não emite animação.

## Áudio

Nenhum áudio novo foi produzido, baixado ou sintetizado. Slots de rega/plantio/
colheita continuam no plano anterior. `data/farming/g12/audio_slots.json` prepara
remove_weeds/remove_pests/fertilize/ready, com direção e `NOT_PRODUCED`.
`ui/care/care_audio.gd` adiciona ao player existente apenas arquivo com revisão
APPROVED, embedding comercial e path válido. Sem master aprovado = silêncio.
Não apresentar os synth antigos como finais.

Produzir: água natural suave; folhagem/terra para ervas; sopro/folhas para insetos;
granulado e resolução musical leve para fertilizante; acento opcional de pronto.
Seguir formatos/mix/loops/escuta de `AUDIO_PRODUCTION_PLAN.md`. Nenhum som deve
ser necessário para descobrir tempo restante ou estado de cuidado.

## Pendências de avaliação humana

- Leitura de ervas/insetos a 1×/zoom normal e em aparelho físico.
- Densidade/contorno/alpha dos seis novos sprites, sem promover output bruto.
- Animações dedicadas de remoção/fertilização e transição visual de crescimento.
- Tamanho/posição do cartão sem encobrir canteiros ou sair da tela; conforto real dp.
- Trilha/SFX masterizados, fonte licenciada, trigo/morango, bordas adjacentes e caminho.

Capturas reais em `.local/g12/`, sem retoque. A fixture força ocorrências para
mostrar o pior caso; isso não é a probabilidade normal de todas as plantas infestadas.
Os testes/capturas não fazem export público ou aprovação artística automática.
