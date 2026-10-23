# ColheitaFeliz — codename

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
