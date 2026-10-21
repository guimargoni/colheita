# ColheitaFeliz — codename

A modern social farming game inspired by the *feeling* of classic Orkut-era farm games: plant, wait, harvest, decorate, visit friends, help them, cause harmless trouble, try to steal a little produce, and let farm guardians protect what is yours.

> **Important:** this is an original project. The working name is a codename. We are not reproducing proprietary code, artwork, branding, text, sounds or UI from the historical game.

## Current status

**Foundation / pre-production.**

The repository currently contains source asset packs plus the design and architecture foundation for AI-assisted development.

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

## Next gate

**G0 — Foundation**

1. Bootstrap the Godot project.
2. Audit/unpack the supplied art packs.
3. Generate contact sheets and approve the visual subset.
4. Build a single polished farm-screen visual prototype.
5. Establish backend dev environment and CI.

See [ROADMAP.md](docs/ROADMAP.md) for acceptance criteria.
