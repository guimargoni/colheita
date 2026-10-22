# Produção artística — primeira amostra

## Revisão G0.5-R

O plano abaixo preserva o orçamento histórico da amostra G0.5, sem aprovação
artística. A direção vigente é Cozy Pixel Art — Fazenda Viva, consolidada na
Art Bible 0.2. Aplicação futura segue `G0_5R_IMPLEMENTATION_PLAN.md` e a matriz
`G0_5R_ASSET_MATRIX.csv`. Escala/projeção/modularidade devem passar por piloto
antes de redesenhar famílias inteiras. Não substituir todos os sprites agora.

2026-10-22. Escopo fechado: um pátio, casa, árvore, cerca, quatro canteiros,
cenoura/morango, galinha/cachorro, FX, UI Kit e conceito Abóbora Amaldiçoada.
Não expandir catálogo antes de avaliação do diretor.

## Estado e decisão de sourcing

Os três packs originais continuam em quarentena conforme `ASSET_LICENSE_RECORD.md`.
Maeve tem bons candidatos, mas o escopo FREE não foi esclarecido. SnowHex tem
termos conflitantes; Will Tice tem condições de distribuição e proibição de treino.
Nenhum pack foi enviado a modelo, usado para treino ou integrado à cena G0.5.
Sem alternativa existente com qualidade **e** autorização clara, foram produzidas
cinco pranchas originais pelo imagegen disponível, a partir de texto próprio.
O gerador não conhece os packs deste repositório através deste trabalho.

| Classe | Material atual | Próxima ação |
|---|---|---|
| Arte final candidata | nenhum asset promovido | só após QA e diretor |
| Arte em revisão | 5 texturas originais G0.5, incluindo UI/FX e grama calma | revisar, limpar e normalizar |
| Placeholder | geometrias e synth G0.3/G0.4; fonte/HUD estático | manter só para comparação |
| Bloqueado por licença | packs históricos auditados | esclarecimento escrito dos autores |
| Não produzido | água, personagens humanos, áudio final, estações completas | fora da pequena amostra |

Manifesto runtime com hashes: `runtime_assets_manifest.json`. Prompts exatos:
`G0_5_ART_PROMPTS.json`, `G0_5_UI_PROMPT.json` e `G0_5_TERRAIN_PROMPT.json`. Pranchas preservadas sem
retoque programático; recortes e pivôs são feitos pelo Godot. Arquivos originais
gerados também continuam no diretório de saídas do imagegen da máquina.

## Trabalho antes de promover a amostra

Estimativa de esforço humano, não orçamento cotado: dia = 6 h produtivas.

| Trabalho | Arte | Técnica | Critério de saída |
|---|---:|---:|---|
| Revisão do diretor e ajuste da linguagem | 0,5–1 dia | 0,25 dia | uma direção assinada |
| Limpar densidade, contornos, alpha e grama | 2–3 dias | 0,5 dia | matriz comum, gramado calmo |
| Normalizar cultura/base/sombras | 1–2 dias | 0,5 dia | 4 estados sem salto de pivô |
| Galinha e cão: volume, pés, loop | 1,5–3 dias | 0,5 dia | <=1 px de wobble |
| Desenhar ciclos FX conforme gesto e timing | 1–2 dias | 0,5 dia | resposta legível sem bloquear |
| UI: bordas, fonte, contraste e ícones | 1–2 dias | 1 dia | mobile sem cortes e >=44 dp |
| Halloween, brilho e colheita especial | 0,5–1 dia | 0,25 dia | identidade sazonal consistente |
| QA físico e proveniência de release | 0,5 dia | 1–2 dias | direitos e aparelhos registrados |

Total indicativo: 8–14,5 dias de arte e 4,5–5,5 técnicos, parcialmente paralelizáveis.
Revisões maiores após decisão criativa podem alterar essa faixa. Não extrapolar
este custo para dezenas de culturas sem medir a primeira família aprovada.

## Ordem de execução futura

1. Diretor avalia executável/capturas/atlases e escolhe o que manter.
2. Artista faz paint-over e normaliza pixels/pivôs em Aseprite/Krita ou equivalente.
3. Exporta PNG RGBA lossless, sem mipmap; atualiza hash, recortes e autoria.
4. Técnico compara antes/depois na mesma câmera e roda checks.
5. QA em celular real, revisão de licença/IP e aceite explícito por asset/família.

Ferramentas sugeridas são opções de pipeline, não novas dependências do jogo.
Não produzir arquitetura de exportação/packing definitiva antes dessa aprovação.
