# ColheitaFeliz — codename

A modern social farming game inspired by the *feeling* of classic Orkut-era farm games: plant, wait, harvest, decorate, visit friends, help them, cause harmless trouble, try to steal a little produce, and let farm guardians protect what is yours.

> **Important:** this is an original project. The working name is a codename. We are not reproducing proprietary code, artwork, branding, text, sounds or UI from the historical game.

## Current status

**Foundation / pre-production.**

G0.1 bootstrap and G0.2 audit are implemented locally. Godot 4.7.2 stable / GDScript boots without third-party art or backend configuration. The director has technically accepted G0.1 and G0.2; visual direction and asset license review remain pending.

## Start here

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

Work stops here. G0.3 and G1 have not started. See [ROADMAP.md](docs/ROADMAP.md) for later gates; no later work is authorized by this delivery.
