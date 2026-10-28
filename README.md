# ColheitaFeliz — versão integrada local

**Fundação visual v2:** padrão/Halloween, skin da casa, HUD ilustrado e capacidade de 16 parcelas.
Troque em **Ajustes → Aparência**. [Guia, compatibilidade e avaliação humana](docs/VISUAL_V2_REPORT.md).
Capturas e vídeos reais em `.local/visual_v2/index.html` (evidência, não jogo).

Dê dois cliques em **JOGAR_COLHEITAFELIZ.cmd**. Godot 4.x estável necessário.
Para experimentar duas contas e tempo acelerado: **JOGAR_COLHEITAFELIZ.cmd -TwoPlayers -Fast**.

[Como jogar, testar o social e limitações](docs/INTEGRATED_DELIVERY.md).
[Balanceamento provisório](docs/INTEGRATED_BALANCE.md).
[Especificação vinculante](docs/INTEGRATED_PRODUCT_SPEC.md).

Uma cena principal reúne fazenda, animais, produção, decoração e social com servidor local separado.
Arte 2D estilizada original em revisão; operação pública, áudio final e celular físico pendentes.
Galeria `.local/integrated/index.html` mostra capturas reais, não o jogo interativo.

<details>
<summary>Histórico dos gates e instruções anteriores, preservados para referência</summary>

# ColheitaFeliz — codename

G1.4: dê dois cliques em **JOGAR_G14_TESTE.cmd** para jogar o teste 60×.
Toque nos terrenos com **+** para revisar e confirmar uma expansão.
[Guia](docs/G14_TEST_GUIDE.md), [relatório](docs/G14_TECHNICAL_REPORT.md),
[balanceamento](docs/G14_BALANCE.md) e [integração histórica](docs/G14_HISTORICAL_INTEGRATION.md).
G1.3 aceito funcionalmente; G1.4 aguarda avaliação humana. Arte, áudio final,
celular físico e segurança online continuam pendentes. Parar no G1.4.

G1.3: double-click **JOGAR_G13_TESTE.cmd** for the isolated accelerated economy
scene (installed Godot 4 stable required). Buy seeds in **Loja**, harvest into stock
and XP, deliberately sell in **Inventário**; **Menu** shows the economic ledger.
[How to play](docs/G13_TEST_GUIDE.md), [technical report](docs/G13_TECHNICAL_REPORT.md),
[provisional balance and simulations](docs/G13_BALANCE.md).
G1.3 functionality was subsequently accepted by the director in the G1.4 brief.
Art/audio, physical mobile and online security remain pending. Previous scenes/saves remain preserved.

G1.2: double-click **JOGAR_G12_TESTE.cmd** to play the isolated accelerated care
scene (requires installed Godot 4 stable). [How to play](docs/G12_TEST_GUIDE.md),
[technical report](docs/G12_TECHNICAL_REPORT.md), [balance](docs/G12_BALANCE.md),
[art/audio review](docs/G12_ART_AND_AUDIO.md). HTML galleries contain screenshots,
not the interactive game. G1.1 and all previous scenes/saves remain preserved.
[G1.2 mechanics: human-approved milestone](docs/G12_HUMAN_APPROVAL.md), 2026-10-24.
Artistic finish, final audio, physical mobile testing and online security remain pending.

G1.1 local development: open `game/scenes/farm/g11/farm.tscn` and press F6 for
three crops, timestamp growth, saved seeds/products and direct harvest.
[Manual tests](docs/G11_TEST_GUIDE.md), [architecture and limitations](docs/G11_ARCHITECTURE.md),
[provisional content/art](docs/G11_CONTENT_AND_ART.md). F5 and all G0 scenes stay
preserved. Local time/save are not anti-cheat or production online authority.

A modern social farming game inspired by the *feeling* of classic Orkut-era farm games: plant, wait, harvest, decorate, visit friends, help them, cause harmless trouble, try to steal a little produce, and let farm guardians protect what is yours.

> **Important:** this is an original project. The working name is a codename. We are not reproducing proprietary code, artwork, branding, text, sounds or UI from the historical game.

## Current status

**Foundation / pre-production.**

G0.1/G0.2 are technically accepted. The director selected direction A and the G0.4 direct interaction prototype. **G0.5 is an executable four-plot art sample awaiting artistic review**, with original AI-assisted sprites, UI Kit and seasonal concept; no final audio, production economy or multiplayer. Godot 4.7.2 stable / GDScript, no backend setup. F5 opens G0.5; earlier scenes remain available. Source-pack licenses remain unresolved.

- [G0.5 test guide and capture commands](docs/G0_5_TEST_GUIDE.md)
- [Art Bible](docs/ART_BIBLE.md), [quality and limitations](docs/G0_5_QUALITY_REPORT.md)
- [Original runtime provenance](docs/G0_5_ASSET_PROVENANCE.md)
- [Art](docs/ART_PRODUCTION_PLAN.md) and [audio production plans](docs/AUDIO_PRODUCTION_PLAN.md)

## Start here

New independent Cozy art sample v2: F6 on `game/scenes/art/pilot/pilot.tscn`.
[Review/limitations](docs/PILOT_V2_REVIEW.md), [test guide](docs/PILOT_V2_TEST_GUIDE.md).
Prior G0.4/G0.5/G0.5-R and the F5 entry remain unchanged. No final art approval.

G0.5-R: [consolidated direction](docs/ART_BIBLE.md),
[diagnosis](docs/G0_5R_DIAGNOSIS.md), [scale standard](docs/VISUAL_SCALE_STANDARD.md)
and [lab/implementation plan](docs/G0_5R_IMPLEMENTATION_PLAN.md). F6 on
`game/scenes/art/art_lab.tscn` opens the isolated expandable-grid inspection lab;
F5 and all prior prototypes stay preserved. Artistic approval remains pending.

- [AGENTS.md](AGENTS.md) — operating rules for Codex/AI contributors
- [GDD](docs/GDD.md) — living game design document
- [Technical Architecture](docs/TECHNICAL_ARCHITECTURE.md)
- [Roadmap](docs/ROADMAP.md)
- [Original Game Research](docs/ORIGINAL_GAME_RESEARCH.md)
- [Asset Pipeline](docs/ASSET_PIPELINE.md)
- [Asset Manifest](docs/assets_manifest.csv)
- [Decisions](docs/DECISIONS.md)

## Product pillars

- **Grow:** simple, satisfying farming with real-world timers.
- **Express:** a farm that becomes visually unique.
- **Visit:** meaningful asynchronous social interaction.
- **Mischief:** stealing/nuisance that creates stories without griefing.
- **Protect:** collectible guardian pets with real gameplay value.
- **Progress:** land, crops, animals, production, collections and seasonal goals.
- **Return:** the farm keeps living while the player is away.

## Technical direction

- Godot 4.x
- GDScript
- Supabase/Postgres backend
- Server-authoritative economy and timers
- Async-first social architecture
- Desktop development with touch-safe UX
- Steam / Android as leading release candidates; iOS supported by the same core architecture

## G0.3 visual comparison — awaiting creative approval

- [Comparison, estimated costs and limitations](docs/G0_3_VISUAL_COMPARISON.md)
- [Exact run commands, controls and review checklist](docs/G0_3_TEST_GUIDE.md)
- [Files, commands and technical validation](docs/G0_3_EXECUTION_RECORD.md)
- F5 opens the comparison menu; A and B are also separate scenes under `game/scenes/comparison/`.
- Original procedural placeholders only; generated captures remain local under `.local/g0_3/`.

## G0.6 — Fazenda Viva

Independent four-plot reference: open `game/scenes/art/g06/g06.tscn` and press F6.
[Review and limitations](docs/G06_REFINEMENT_REPORT.md), [grid/scale](docs/G06_GRID_SCALE.md),
[manual tests and real PC/mobile captures](docs/G06_TEST_GUIDE.md). Conceptual style
accepted; artistic finish pending human approval. F5 and prior scenes are preserved.

## G0.1 / G0.2 delivery

- [Open, run, test and review contact sheets](docs/DEVELOPMENT.md)
- [Asset audit report](docs/ASSET_AUDIT_REPORT.md)
- [License evidence and unresolved permissions](docs/ASSET_LICENSE_RECORD.md)
- [All changed files, commands and checks](docs/G0_EXECUTION_RECORD.md)
- [Foundation direction review and commit record](docs/FOUNDATION_DIRECTION_REVIEW.md)
- [Audio direction](docs/AUDIO_DIRECTION.md)
- [Live operations and events](docs/LIVE_OPS.md)
- [Monetization and economy](docs/MONETIZATION_ECONOMY.md)

The three original archives remain byte-identical. Their presence in repository history predates this audit and carries redistribution risk. Extraction and contact sheets stay local and ignored; no third-party art is in game/assets/.

G0.3 is prepared for the creative director, not approved. G1 has not started. See [ROADMAP.md](docs/ROADMAP.md); no later gate is authorized by this delivery.

## G1.5 — culturas históricas e multicolheita

Para jogar no Windows, execute `JOGAR_G15_TESTE.cmd` (Godot, tempo acelerado, save independente). Alternativa: abra `game/scenes/farm/g15/farm.tscn` e pressione F6.

[Guia de teste](docs/G15_TEST_GUIDE.md) · [Relatório técnico](docs/G15_TECHNICAL_REPORT.md) · [Catálogo histórico](docs/G15_HISTORICAL_CATALOG.md) · [Balanceamento](docs/G15_BALANCE.md) · [Arte](docs/G15_ART_REPORT.md).

Capturas locais: `.local/g15/index.html`. Aprovação da experiência pendente; G1.4 continua aguardando sua validação humana formal.

## G1.V — Fazenda Viva

Execute `JOGAR_G1V_TESTE.cmd` para a demonstração visual com save isolado e cena já preparada. Use **A / B** para comparar apresentações e **Ajustes** para intensidade/movimento reduzido. Não altera os saves G1.1–G1.5.

[Como jogar](docs/G1V_TEST_GUIDE.md) · [Comparação visual](docs/G1V_VISUAL_COMPARISON.md) · [Relatório técnico](docs/G1V_TECHNICAL_REPORT.md) · [Desempenho](docs/G1V_PERFORMANCE.md). Capturas e GIFs reais locais em `.local/g1v/index.html`; direção pendente de decisão humana.

</details>
