# AGENTS.md — ColheitaFeliz

## Mission
Build a polished, social farming game inspired by the emotional loop of classic Orkut-era farm games, while using original code, original branding, and only assets whose licenses permit use.

The human owner is the creative director and primary tester. AI agents/Codex act as implementation team.

## Non-negotiable product pillars
1. Farming must feel immediately understandable and satisfying.
2. Social visits must matter: help, mischief, theft attempts, defense, reciprocity and visible history.
3. The farm must become deeply personal through layout, cosmetics, themes, animals and progression.
4. Returning after time away should create anticipation, not punishment.
5. Economy must reward regular play without becoming pay-to-win.
6. Every interaction must feel polished: animation, sound, feedback, transitions and clear UI.
7. Mobile and desktop must share one gameplay/economy model.

## Technical baseline
- Engine: Godot 4.x stable.
- Language: GDScript.
- Backend: Supabase (Postgres, Auth, Edge Functions, Storage, Realtime where useful).
- Economy-critical mutations are server authoritative.
- Client may predict visuals, but cannot grant itself currency/items/XP.
- All time-based gameplay uses trusted server time for authoritative results.
- Prefer asynchronous social play over realtime multiplayer unless a feature truly requires realtime.
- PC first for development ergonomics, but every UI/system must remain touch-compatible.

## Repository rules
- Never commit proprietary/unknown-license art into shipping folders until its license is documented.
- Keep source asset packs under `assets_source/` only if redistribution is permitted.
- Runtime-ready art belongs in `game/assets/`.
- New features require data-driven definitions where reasonable.
- Avoid hardcoding crop, animal, item, level or economy values in scene scripts.
- Write migrations for database changes.
- Include automated tests for economy math and backend mutation rules.
- Do not silently change GDD rules. If implementation requires a design change, update the relevant design document in the same PR.

## Definition of done for a gameplay feature
A feature is not done merely because it works. It must have:
- success/error/loading states;
- keyboard/mouse + touch-safe interaction;
- animation/audio hooks;
- persistence;
- analytics event hooks;
- localization-ready strings;
- abuse/cheat considerations;
- tests for critical logic;
- documentation where the behavior is not obvious.

## Development gates
Do not skip gates without an explicit decision in docs/DECISIONS.md.

### G0 — Foundation
Project boots, coding standards exist, asset audit exists, backend local/dev setup exists.

### G1 — Farm Core
Single-player vertical slice: plots, planting, growth, watering/care, harvest, inventory, selling, XP, level-up, land unlock.

### G2 — Social Core
Accounts, friends/following, visit farm, help, add nuisance, theft attempt, pet defense, activity log.

### G3 — Living Farm
Animals, producers, decorations, themes/skins, storage, achievements, quests, daily/weekly loops.

### G4 — Content + Economy
Balanced content catalog, events, cosmetics, sinks/sources, retention loops, anti-abuse controls.

### G5 — Beta Readiness
Onboarding, settings, accessibility, telemetry, crash/error handling, save recovery, moderation/support tools.

### G6 — Platform Release
Steam and/or Android first release candidate; iOS follows when platform pipeline is ready.

## Coding guidance
- Prefer composition over deep inheritance.
- Keep scene scripts small.
- Domain logic goes in services/resources, not UI nodes.
- Separate authoritative domain DTOs from presentation models.
- Keep network calls behind a service layer.
- Never trust client-provided prices, rewards, timers, ownership, cooldown completion or theft success.
- Use deterministic IDs/keys for content definitions.
- Keep save/network formats versioned.

## AI workflow
For each milestone:
1. Read GDD + architecture + roadmap.
2. Inspect current repo before changing anything.
3. Implement the smallest complete vertical increment.
4. Run tests/checks.
5. Provide a concise changelog and exact manual test steps for the creative director.
6. Stop at the milestone boundary unless explicitly told to continue.

## Creative direction
The goal is not a sterile simulator. The target feeling is:
- colorful;
- playful;
- nostalgic without looking old;
- expressive;
- slightly mischievous;
- cozy but socially competitive;
- readable at small mobile sizes;
- premium pixel-art presentation.

## Legal/IP guardrail
Mechanics may be reinterpreted, but do not copy original game code, logos, text, art, sounds, proprietary names, branded event content or exact UI assets unless rights are confirmed. Treat “ColheitaFeliz” as an internal codename until naming clearance is done.
