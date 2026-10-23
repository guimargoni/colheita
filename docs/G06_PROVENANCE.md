# G0.6 — origem e inventário dos materiais

2026-10-23. Direção conceitual aceita pelo diretor; **nenhum asset liberado para
release**. Manifesto dos três PNGs novos: `g06_assets_manifest.json`, com SHA256,
dimensões reais, origem, prompt, condição de licença e `release_approved: false`.

## Produção original

image_gen integrado, quatro chamadas, sem CLI, chave, treino ou packs de terceiros.
Prompts integrais: `G06_PROMPTS.json`. Modelo específico não exposto pela ferramenta.
Fontes integrais preservadas em
`C:/Users/guilh/.codex/generated_images/01a15fca-1b40-7bf0-9361-e1db11aceaf7/`:

| Chamada | Output original | Destino / decisão |
|---|---|---|
| terrain | exec-79022b07-107e-4b0e-a3ad-31fc615a4d74.png | estudo anterior preservado fora do runtime; halos/gutters a revisar |
| clean | exec-99bdbdf3-4b56-4718-b19b-18db3d9f9291.png | `game/assets/art/g06/garden_kit_v1.png`; ART_REVIEW |
| fx | exec-bad6e09a-372a-4b7f-bc69-861ec2fdf03b.png | `game/assets/art/g06/action_fx_v1.png`; ART_REVIEW |
| path | exec-265c024c-76a3-4d0d-a650-618b3d67602f.png | `game/assets/art/g06/path_v2.png`; ART_REVIEW |

Terrain usa somente `environment_v1.png` original do projeto como referência de
paleta/estilo. Clean edita somente o output terrain. FX usa somente o atlas próprio
`crops_fx_v1.png` como referência. Path vem de texto original, sem imagem de input.
Os dois anexos do diretor foram observados como referências de composição e
qualidade; não foram recortados, enviados como input ao gerador ou versionados.
Nenhuma conclusão sobre autoria/licença dos anexos é presumida.

PNG/alpha integrais copiados, sem retoque, threshold ou edição por Python. Pillow
foi usado somente para ler dimensões, alpha e bounds. O renderer usa recortes e
adaptação fixa de cada tipo para o canvas lógico. Não houve blur ou filtro de
suavização; nearest no mundo. Isso **não equivale a pixel art nativa normalizada**.

## Reuso auditado nesta cena

| Arquivo | Uso | Estado herdado / licença registrada |
|---|---|---|
| `g05r_pilot/environment_v1.png` | casa, flores e três poses da galinha | ART_REVIEW; `PILOT_V2_PROVENANCE.md` |
| `g05r_pilot/tree_v2.png` | duas árvores frutíferas | ART_REVIEW; mesmo registro |
| `g05r_pilot/crops_fx_v1.png` | solo e culturas separadas | ART_REVIEW; mesmo registro |
| `g05r_pilot/ui_v1.png` | botões e ícones | FINAL_CANDIDATE, não aprovado; mesmo registro |
| `g05/terrain_atlas_v1.png` | grama discreta | ART_REVIEW; `G0_5_ASSET_PROVENANCE.md` |
| Fonte padrão Godot | texto de UI | PLACEHOLDER; avisos/licença do engine preservados |
| Áudio | slots originais vazios, integração segura | NOT_PRODUCED; nenhum master adicionado |

Os três packs históricos permanecem em quarentena/licença pendente, sem promoção,
cópia ao runtime ou treino de IA. Seus manifests e fontes ficaram intactos.

## Materiais não promovidos

- Grama do novo kit: Reject para fundo contínuo; gerador entregou losango em vez
  de textura quadrada seamless. Não descartar a fonte.
- Caminho do kit: Reject para corredor contínuo; a borda verde repetia uma grade.
  Substituído **somente nesta cena** pelo novo path_v2, de areia até a borda.
- Swatch de sombra: não utilizável. A edição solicitou removê-lo; não improvisar
  uma sombra procedural como arte final. Contato atual usa sombras/base dos sprites.
- Kit de vegetação/cerca: revisão de alpha, densidade e pivôs ainda necessária.
  RGB invisível de aura não constitui sombra aprovada; nenhum shader mascara falhas.

Termos/origem seguem o registro já consultado em `PILOT_V2_PROVENANCE.md` e
`G0_5_ASSET_PROVENANCE.md`. Não atribuir CC0, exclusividade ou proteção automática.
Revisão humana do contrato aplicável, IP e embedding antes de distribuição permanece
pendente. Classificação de avaliação não é aprovação jurídica nem autorização de
publicação. Não houve push, export público ou inclusão de asset de licença desconhecida.
