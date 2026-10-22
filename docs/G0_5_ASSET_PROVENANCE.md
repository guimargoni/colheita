# G0.5 — proveniência e direitos

2026-10-22. Complemento aos 5.946 gráficos/6.158 arquivos G0.2.
`assets_manifest.csv` mantém o inventário histórico em quarentena;
`runtime_assets_manifest.json` registra os cinco PNGs novos, hashes SHA-256,
dimensões e status. A união dos dois é o manifesto do projeto. Recortes do
ambiente: `game/data/art/sample.json`; culturas, animais, UI e FX no renderer.

## Outputs originais

Quatro atlas RGBA 1536×1024 e uma textura opaca de gramado em
`game/assets/art/g05/`. Produzidos pelo imagegen integrado (modelo específico
não exposto) com texto original e paleta própria. Não foram enviados packs,
personagens ou screenshots de jogos. Não houve treinamento nesta sessão.
Prompts integrais: `G0_5_ART_PROMPTS.json`, `G0_5_UI_PROMPT.json` e `G0_5_TERRAIN_PROMPT.json`.
PNGs copiados integralmente, sem retoque programático. Recortes, tint e fade
são runtime no Godot; não alteram a fonte original.

Originais da ferramenta preservados em
`C:/Users/guilh/.codex/generated_images/01a15fca-1b40-7bf0-9361-e1db11aceaf7/`:

| Família | Arquivo original |
|---|---|
| environment | exec-40d3c20a-a2a4-494a-bc04-f003f1030abf.png |
| crops | exec-8c35ff71-de24-47dd-90f8-b2552ffa3057.png |
| animals | exec-225f6be6-f04c-4cb1-8997-b6444e4c7a27.png |
| ui | exec-441bc061-a07c-443b-a917-6f6964d21708.png |
| terrain | exec-677d1c2a-a813-4a13-a36d-f2bbf5cb6dca.png |

As cópias runtime bastam para clone limpo. São fontes artísticas originais da
entrega, não contact sheets de packs.

## Termos consultados e revisão

[Termos OpenAI fora de EEE/Reino Unido/Suíça](https://openai.com/policies/row-terms-of-use/),
consultados 2026-10-22, em vigor 2026-01-01, seções Content/Ownership.
Atribuem ao usuário os direitos da OpenAI sobre output na medida permitida
pela lei e avisam que outputs podem não ser exclusivos. Essa é a base documental
para incluir os outputs originais no protótipo e nesta branch. Não é autorização
de uso de packs, garantia de exclusividade ou de proteção autoral em toda jurisdição.
Confirmar contrato da conta, revisão de IP e políticas da plataforma antes de release.
Não declarar origem humana nem marcar CC0 por conveniência.

Todos: **ART_REVIEW / B — adapt**, `release_approved: false`. Autoria assistida
por IA permanece registrada. Revisão visual, controle de semelhança e normalização
manual dependem de pessoas. Não há arte final aprovada nesta entrega.

## Anteriores e outros componentes

Maeve FREE: escopo comercial/redistribuição desconhecido. SnowHex: conflito entre
README não comercial e página pública. Will Tice: atribuição, distribuição e
restrição de treino exigem preservação dos termos. Nenhum foi usado aqui.
Ver `ASSET_LICENSE_RECORD.md`. Fontes históricas não foram alteradas e nenhum
asset adicional desses packs foi versionado.

Fonte padrão embarcada do Godot: sem novo arquivo de fonte; preservar avisos do
engine ao exportar. Synth G0.4 é placeholder original opcional. Nenhum áudio
externo adicionado; slots finais NOT_PRODUCED. Caches, capturas, extrações e
contact sheets ficam em `.godot/`/`.local/`, ignorados. Sem segredos novos.
