# Development Roadmap

This roadmap is gate-based. A gate ends in a playable build and human acceptance, not merely merged code.

## Phase 0 — Foundation

### G0.1 Repository bootstrap
Deliver:
- Godot project;
- folder structure;
- coding conventions;
- base autoload/service pattern;
- local config template;
- CI;
- test harness.

Acceptance:
- clean clone opens and runs;
- test command documented;
- no secrets committed.

### G0.2 Asset audit
Deliver:
- unpack/source inventory;
- screenshots/contact sheets;
- license/source record for every pack;
- style grading: A/B/C/Reject;
- mapping of usable art to game systems;
- missing-art list.

Acceptance:
- no asset reaches shipping folder without license status.

### G0.3 Visual prototype
Current director-authorized scope: compare two executable farm screens before choosing the final direction: A, classic modernized isometric; B, premium oblique/top-down. Both have 16 initial plots, the same curated farm elements, a comparison menu, static HUD and mouse/touch camera navigation. Use original placeholders where asset licensing remains unresolved. No definitive gameplay systems.

Delivery: `G0_3_VISUAL_COMPARISON.md` and `G0_3_TEST_GUIDE.md`; exact desktop 1920×1080 and portrait 1080×1920 captures are reproducible locally. G0.3 remains awaiting creative-director acceptance, not automatically passed by technical checks.

Acceptance:
- camera/scale looks good at 1080p and common phone aspect;
- crop plot is readable;
- basic UI direction approved by creative director.

### Director-authorized pre-production extensions (G0, 2026-10-22)

G0.4 preserves the selected A direction and direct local interactions; its art,
UI and synth audio are placeholders. Technical checkpoint: `G0_4_EXECUTION_RECORD.md`.
G0.5 establishes Art Bible and a four-plot authored sprite sample, UI Kit, audio
production specification and real desktop/mobile comparison. See
`G0_5_QUALITY_REPORT.md`. Artistic/release approval remains with the director.
These extensions do not authorize G1 or production economy/multiplayer.

G0.5-R consolidates Cozy Pixel Art — Fazenda Viva after the director withheld
artistic approval. Deliver art contracts, scale/projection/modular plots/skins,
animation and audio specifications plus an isolated inspection lab. The mockup
does not fix layout or plot counts. Extensible farm/locked regions are visual QA
only; no actual unlock/progression or definitive art replacement. Review the
contracts and pilot plan before authorizing any further implementation.

### G0.6 — Style lock e cenário de referência

Explicitamente autorizado em 2026-10-23 após preferência pela amostra v2.
Cozy Pixel Art — Fazenda Viva aceita conceitualmente; acabamento artístico
continua pendente. Cena independente `scenes/art/g06/g06.tscn`, quatro canteiros,
grade/escala documentadas, casa conectada a caminhos, cercas, vegetação, animal
legível, HUD e FX. Comparação real PC/retrato com v2 preservada. Relatório e
critérios: `G06_REFINEMENT_REPORT.md`; guia: `G06_TEST_GUIDE.md`.
Aceite técnico não aprova arte nem autoriza G1, fazenda completa ou economia.

## Phase 1 — Farm Core

### G1.1 Plot interaction
- plot grid;
- select plot;
- plant;
- growth states;
- server-time abstraction;
- visual feedback.

Director extension 2026-10-24 (ADR-014): also include the explicitly requested
minimal seeds → timestamp growth → harvest → product stock cycle, local DEV
save and injectable clock. Three crops, future fertilizer model only, no care/
economy/multiplayer progression. Scene `scenes/farm/g11/farm.tscn`, docs
`G11_ARCHITECTURE.md` / `G11_TEST_GUIDE.md`. Local time is not anti-cheat.
This does not authorize G1.2/G1.3/G2. Await human validation of this slice.

### G1.2 Care + harvest
- watering;
- weeds/pests;
- fertilizer hook;
- harvest;
- inventory;
- animation/audio feedback.

Explicit director authorization 2026-10-24 (ADR-015), following human validation
of G1.1: optional watering, recoverable weeds/pests, local functional fertilizers,
one-use Super protection, contextual growth card, persistence and profile simulations.
Love is reserved, no friends or purchases. Independent `scenes/farm/g12/farm.tscn`;
`G12_TEST_GUIDE.md` includes a Windows test launcher. G1.2 mechanics were human
validated on 2026-10-24; see `G12_HUMAN_APPROVAL.md`. Artistic finish, final audio,
physical mobile testing and online security remain pending. That acceptance alone
did not authorize a new gate; the subsequent G1.3 brief is recorded separately below.

### G1.3 Economy
- seed shop;
- sell from inventory;
- coins;
- XP/levels;
- unlock rules;
- transaction feedback.

Director authorization 2026-10-24, ADR-017: independent local G1.3 scene/provider/
schema 3, configurable seed shop, manual product sale, coin ledger, harvest XP,
levels and crop unlocks. Provisional balance simulations, real PC/portrait captures
and test launcher: `G13_TEST_GUIDE.md`. Previous scenes/saves and approved G1.2
milestone remain untouched. G1.3 functionality was accepted in the subsequent
G1.4 brief (ADR-018); art/audio, physical mobile and online security remain pending.

### G1.4 Land expansion
- locked plots/areas;
- unlock purchase/requirements;
- persistence.

G1.4 delivery, 2026-10-26 (ADR-018): independent schema 4/scene/provider,
coin/level/prerequisite rules, protected confirmation, persistent unlock ledger,
compact adjacent plots, tests, simulations and PC/portrait captures. Historical
audit/pillars integrated selectively from `origin/foundation/game-design` at
`1d1dd8e`. See `G14_TEST_GUIDE.md` and `G14_TECHNICAL_REPORT.md`.
G1.4 technical PASS; experience PENDING HUMAN APPROVAL. Stop; no G1.5/G2.

**G1 exit criterion:** the game is fun enough as a tiny solo farm for 15–20 minutes.

## Phase 2 — Online + Social Core

### G2.1 Accounts/backend
- Supabase dev environment;
- auth;
- canonical profile/farm;
- migrations;
- authoritative command API.

### G2.2 Visit farms
- friend/follow model;
- farm snapshots;
- visit navigation;
- privacy/block rules.

### G2.3 Helpful actions
- water/help/remove nuisance;
- caps;
- activity feed.

### G2.4 Mischief and theft
- add nuisance;
- steal eligible mature crop;
- protected owner share;
- cooldowns;
- server logs;
- anti-abuse rules.

### G2.5 Guardians
- pet ownership;
- feed/care;
- assigned guardian;
- defense resolution;
- bite/chase feedback;
- owner bounty/log.

**G2 exit criterion:** two real accounts can create a memorable “you stole from me / my dog caught you / I helped you” loop.

## Phase 3 — Living Farm

### G3.1 Animals
- feed;
- timed production;
- collection;
- animal storage/placement.

### G3.2 Decorations
- placement mode;
- move;
- rotate if supported;
- collision/occupancy;
- store;
- inventory/storage;
- undo.

### G3.3 Themes
- whole-farm scenario skins;
- preview;
- equip;
- ambient audio hooks.

### G3.4 Processing
- production buildings;
- recipes;
- queues;
- collect output.

### G3.5 Orders
- rotating order board;
- turn-ins;
- reward calculation.

**G3 exit criterion:** farm identity and mid-term goals feel substantially richer than the original core loop.

## Phase 4 — Progression + Retention

### G4.1 Achievements/collections/mastery
### G4.2 Daily/weekly quests
### G4.3 Inbox + gifts
### G4.4 Seasonal event framework
### G4.5 Economy balancing tools
### G4.6 Notification hooks

**G4 exit criterion:** a player has compelling goals across today, this week and the next month.

## Phase 5 — Polish + Beta

### G5.1 Onboarding
### G5.2 Accessibility/settings/localization
### G5.3 Performance on low/mid Android hardware
### G5.4 Error/reconnect flows
### G5.5 Telemetry/crash reporting
### G5.6 Moderation/support/admin tooling
### G5.7 Closed beta balancing

**G5 exit criterion:** strangers can install, understand, enjoy and recover from normal errors without developer help.

## Phase 6 — Release

### PC/Steam path
- Steamworks onboarding;
- platform auth adapter;
- achievements if desired;
- store assets;
- controller/Steam Deck QA if targeted;
- privacy/legal pages;
- release candidate.

### Android path
- Google Play console;
- signing;
- billing if monetization is enabled;
- notification setup;
- device matrix QA;
- store listing;
- staged rollout.

### iOS path
- Apple developer setup;
- macOS/Xcode export pipeline;
- Sign in with Apple if required by auth choices;
- App Store review requirements;
- device QA.

## Milestone discipline
For each gate Codex must output:
- files changed;
- commands/tests run;
- known limitations;
- exact manual QA steps;
- screenshots/video where workflow supports it;
- whether the gate is PASS or BLOCKED.

Do not start the next gate while the current gate has blocker defects.

## Registro de execução G1.5 — 2026-10-26

Autorização exclusiva conforme ADR-019, sem inferir aprovação humana do G1.4. Cena isolada, catálogo histórico ampliado, feijão multicolheita, flores e evento original demonstrativo implementados. **G1.5 técnico: PASS; G1.5 experiência: PENDING HUMAN APPROVAL.** Relatórios `G15_TECHNICAL_REPORT.md`, `G15_ART_REPORT.md`, `G15_BALANCE.md` e roteiro `G15_TEST_GUIDE.md`. Não iniciar G1.6 ou G2 automaticamente. G1.4 mantém aprovação humana formal pendente.
