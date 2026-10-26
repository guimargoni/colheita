# G1.5 — arte, identidade e proveniência

2026-10-26. Cozy Pixel Art — Fazenda Viva. **ART_REVIEW, release_approved=false.**
Nenhum asset anterior foi alterado/promovido. Não foram usados pixels de jogos,
packs em licença pendente, imagens históricas ou treinamento de IA.

## Atlas original

`game/assets/art/g15/cultures_v1.png`, 1448×1086 RGBA. Uma chamada ao **image_gen
integrado**, identificador específico do modelo não exposto. Referência de estilo:
somente o atlas próprio `g05r_pilot/crops_fx_v1.png`, inspecionado antes da geração.
Prompt integral em `G15_PROMPTS.json`; hash em `g15_assets_manifest.json`.
Fonte original preservada, sem edição de PNG:
`C:/Users/guilh/.codex/generated_images/01a15fca-1b40-7bf0-9361-e1db11aceaf7/exec-ff937674-b09c-46e2-96a5-a30683f96f49.png`.

Origem: output original assistido por IA para o proprietário do projeto; não
atribuir CC0, exclusividade ou proteção autoral automática. Termos/embedding/IP
seguem a revisão de produção já descrita em `PILOT_V2_PROVENANCE.md`; a classificação
interna não concede autorização nova de release ou substitui revisão humana.

São 12 desenhos: feijão (broto, crescimento, vagens, recuperação), rosa (broto,
botões, flor aberta, variante) e abóbora original (broto, verde, madura apagada,
madura iluminada). Cada espécie tem silhueta própria; não é simples recoloração.
Somente feijão usa a pose de recuperação; rosa permanece cultivo de uma colheita.
A abóbora alterna olhos apagados/acesos em ritmo 2,6 s /0,45 s. Movimento reduzido
mantém a pose apagada e prontidão legível. Não escalar a planta inteira como animação.

Regiões/canvases/pivôs/sockets estão em `data/farming/g15/art.json`. O PNG integral
foi copiado preservando bytes/alpha. Pillow foi usado somente para medir alpha e
dimensões, nunca para desenhar, recortar destrutivamente ou editar a imagem.
Renderer usa AtlasTexture/regiões, nearest e escala lógica por família. Não é
export nativo certificado: o gerador não respeitou uma grade regular perfeita.
Recortes foram medidos individualmente; poses maduras da abóbora compartilham
canvas/pivô lógicos. Solo/bordas e mapa de interação continuam separados das plantas.

## Avaliação pendente

- Aprovar densidade de pixels, contorno, alpha, proporções e leitura no celular.
- Normalizar no canvas nativo: há alpha residual muito fraco fora das massas;
  o atlas de avaliação não deve ser promovido sem limpeza artística.
- A estaca do feijão não tem continuidade perfeita na pose madura: requer revisão.
- Verificar estabilidade de folhas/volume entre os dois frames da abóbora.
- Fonte, caminho, bordas e arte legada de trigo/morango continuam pendentes.
- Feedback de colheita reutiliza FX originais G0.6; clipes específicos ainda podem
  ser produzidos. Áudio final não foi criado; os slots anteriores seguem preparados
  e silenciosos sem masters aprovados.

Capturas reais de Godot em `.local/g15/`; nenhuma composição final foi retocada.
Esta entrega é material executável para avaliação, não aprovação artística.
