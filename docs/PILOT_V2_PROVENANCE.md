# Amostra independente v2 — proveniência

2026-10-23. Quatro PNGs originais gerados pelo image_gen integrado, sem imagens de
packs ou mockup externo como inputs. Prompts textuais em `PILOT_V2_PROMPTS.json`;
hashes/dimensões/status em `pilot_assets_manifest.json`. Modelo específico não
exposto. Não houve treino, cópia de arte histórica ou uso de licenças pendentes.

Fontes da ferramenta preservadas sob
`C:/Users/guilh/.codex/generated_images/01a15fca-1b40-7bf0-9361-e1db11aceaf7/`:

| Fonte | Output original | Status |
|---|---|---|
| environment_v1.png | exec-eda7547a-fb9e-476b-944b-45eb6eabab0b.png | ART_REVIEW |
| crops_fx_v1.png | exec-e0217e9b-5d62-4e09-a5d9-9487cb70d07b.png | ART_REVIEW |
| ui_v1.png | exec-b2ec8c72-d05b-4382-8096-1471b5de9a93.png | FINAL_CANDIDATE, não aprovada |
| tree_v2.png | exec-24b36711-d8e0-472c-ba84-a16c5e36ac49.png | ART_REVIEW |

Tree v2 usa apenas environment_v1.png, gerado nesta rodada, como referência de
estilo. Foi produzido isoladamente para remover fragmentos herdados da composição
do atlas. O original permanece preservado; nenhum pack ou mockup foi enviado.

Cópias integrais em `game/assets/art/g05r_pilot/`; sem retoque ou recorte destrutivo.
Atlas e alpha foram preservados. Os recortes e tamanhos de apresentação fixos
constam em `game/data/art/pilot/sample_v2.json` e no UI Kit. Não há dependência de
arquivos fora do checkout para executar. As fontes G0.5/G0.5-R ficaram intactas.

Reuso compatível nesta amostra: `game/assets/art/g05/terrain_atlas_v1.png`,
original próprio já registrado no manifesto G0.5. Foi preferido ao novo losango
de grama, cujas bordas navy produziram grade ruidosa nas capturas. O novo losango
permanece preservado no atlas, mas não é usado: **Reject para piso repetitivo**,
motivo técnico/artístico registrado, sem descarte por gosto. O reuso continua
ART_REVIEW, não arte de release aprovada. Não houve reuso de packs terceiros.

Base de termos: registro consultado em 2026-10-22, `G0_5_ASSET_PROVENANCE.md`,
incluindo [termos OpenAI](https://openai.com/policies/row-terms-of-use/).
Outputs originais são atribuídos ao usuário conforme contrato aplicável; não
inferir exclusividade, proteção autoral automática ou direitos sobre terceiros.
Revisão do contrato da conta/IP/plataforma antes de release permanece humana.
Origem por IA deve continuar declarada. Nenhum PNG recebe CC0 por conveniência.

FINAL_CANDIDATE significa pronto para avaliação de uma alternativa visual, não
aceite humano nem liberação pública. Nenhum `release_approved` é true. Placeholder:
fonte padrão do Godot, dados fictícios de HUD; áudio final ausente. Nenhum arquivo
de áudio externo ou de fonte novo. Preservar avisos do Godot ao exportar.

O gerador não respeitou exatamente a resolução/grade solicitada nem garantiu
pixels nativos 32×16. O protótipo usa recortes e apresentação fixa, sem mudar
tamanho de objeto por frame. Isso não certifica densidade, modularidade de borda
ou alinhamento de pés; limpeza artística é pendente. Não editar por geometria
procedural para mascarar divergências. Caches/capturas ficam ignorados em `.local/`.
