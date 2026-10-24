# Architecture & Product Decisions

## ADR-017 — Authorize G1.3 local economy and crop progression only

Status: explicitly authorized by director on 2026-10-24 after functional G1.1/G1.2
acceptance. G1.3 experience remains PENDING HUMAN APPROVAL.

The new G1.3 brief supersedes previous stop-at-G1.2 instructions solely for this
local development slice. Add configurable seed purchase, deliberate product sale,
coin ledger, harvest XP, levels and existing-crop unlocks. Keep G1.2 milestone/tag,
all earlier code/scenes/art and saves intact. Independent schema 3/provider/scene,
branch `feature/g1-3-economy-progression`, no automatic migration or push.

The client sends quantities/item IDs and operation IDs, never trusted prices,
coin deltas or XP. Commit wallet, inventories, progression, ledger and idempotency
receipts together through the existing single-writer local store. Local DEV remains
untrusted; no claim of online security or importable authoritative offline wealth.
No production backend/database changes, so no migration is introduced.

Economy values are provisional, simulated at 5/20/60 minutes/day. Existing-crop
unlocks only; animals/buildings/decorations/processing/land remain planned data.
No G1.4/G2, expansion, payments, premium, ads, visits, theft or animal production.
Artistic finish, final audio, physical mobile and online security remain pending.
Implementation and evaluation: `G13_TECHNICAL_REPORT.md`, `G13_TEST_GUIDE.md` and
`G13_BALANCE.md`. Stop for human evaluation after this gate.

## ADR-016 — Preserve human-approved G1.2 mechanics milestone

Status: accepted by explicit director instruction, 2026-10-24.

Record human validation of G1.2 mechanics at implementation commit `5300061`.
Preserve runtime unchanged and create local annotated tag
`milestone/g1.2-mechanics-approved` on the documentation acceptance commit.
See `G12_HUMAN_APPROVAL.md` for scope and historical test evidence.

This acceptance excludes artistic finish, final audio, physical mobile testing
and online security. Asset review/release flags and licensing restrictions remain
unchanged. Balance is provisional, local saves/time remain untrusted and no
production release or new gate is authorized. No push or changes to earlier gates.

## ADR-015 — G1.2 care systems and discoverable contextual growth

Status: authorized 2026-10-24 after G1.1 validation; G1.2 mechanics subsequently
human validated on the same date, within the exclusions in ADR-016.

Implement owner-local watering, bounded scheduled weeds/pests, recovery, three
functional fertilizers and the reserved disabled Fertilizer of Love. Add a single
contextual timer near the selected plot, hover/hold access and direct care gestures.
Preserve all G1.1 code/scenes/saves with an independent schema2/provider/scene.
Local DEV authority remains untrusted; future server owns time, stock, rewards,
RNG and social authorization. No G1.3/G2, premium currency, purchases, friends,
theft, expansion or definitive economy. No push.

Provisional moderate consequence: up to 6% recoverable time delay from one weed
and one pest occurrence per cycle, no death or loss of yield. Dryness has no
punishment; water benefits are bounded. Fertilizer limits/prices are not final;
fixture stocks are finite, no grants on restart. Super needs explicit one-use
arming; Love stays nonapplicable until social authorization exists. Record actual
three-profile simulations and art/audio debt; technical PASS cannot approve UX/art.

## ADR-014 — Authorize G1.1 local development farming only

Status: explicitly authorized by director, 2026-10-24; human validation pending.

The G1.1 brief supersedes historical stop-at-G0 instructions solely for this slice.
Implement timestamp growth, three editable crops, seeds/products, minimal harvest,
versioned local persistence, injectable clock and duplicate-command protection.
The explicitly requested minimal harvest/inventory cycle is part of G1.1 even
though the original roadmap listed full care/harvest in G1.2. It does not authorize
G1.2, definitive economy/progression, G1.3, monetization or G2.

Use an isolated scene and branch from G0.6; preserve all earlier gates and main
entry. Device clock/save are untrusted development only, behind FarmService;
future server remains authoritative. No fake security. Fertilizers are definitions
and pure bounded previews, no application/price/offer. Four plots are a fixture,
not a cap. Closer shared plot borders and coherent path replacement are recorded
art debts, nonblocking for G1.1. Wheat may use disclosed placeholder foliage until
original art exists. No source-pack promotion, new release approval or push.

## ADR-013 — G0.6 conceptual style lock, isolated scenic refinement

Status: director-approved conceptual direction, 2026-10-23; finish/release pending.

The director preferred sample v2 and explicitly authorized G0.6. Cozy Pixel Art —
Fazenda Viva becomes the conceptual reference. Build an independent four-plot
scene with shared ground grid, connected paths/fence runs, stronger stylized
animal scale, layered vegetation, responsive HUD and authored action FX. Preserve
G0.4/G0.5/G0.5-R/v2, project entry and original image bytes. New references guide
composition/quality only; no pixel copying or source-pack promotion. G0.6 may
reuse safe local interaction/audio boundaries, without production economy, save,
progression, multiplayer, full farm or G1. Artistic approval stays human; no push.

## ADR-012 — Independent Cozy art sample v2

Status: user-authorized small art round, 2026-10-23; artistic approval pending.

After G0.5-R the director explicitly authorized a new executable four-plot sample
using its Art Bible. Implement a separate scene/branch, preserve all old gates,
main scene and images. Use original generated sprites, separated soil/plants,
authored harvest frames and a compact UI study. Reuse only compatible original
grass and existing local gesture/simulation code. No actual economy, expansion,
persistence, multiplayer or G1. Record generation/import limitations honestly;
the generator did not deliver certified native pixel grids. Do not replace
production art or promote source packs. Await human evaluation; no push.

## ADR-011 — G0.5-R consolidation and expandable art contracts

Status: user-authorized preparation; artistic implementation pending human review.

Cozy Pixel Art — Fazenda Viva guides moderate detail and readable forms. The
attached mockup is a direction reference, not a literal layout, runtime atlas or
approval to replace current assets. Preserve all previous gates and main scene.
Propose a native 32×16 projection/32px character standard in an isolated lab;
the G0.5 128×64 geometry has a 4:1 bridge but old PNGs are not automatically
normalized. No production sprites are replaced or promoted in this revision.

Farm layout must support dozens of plots and future regions/skins. Access,
cultivation and skin are separate. Final/initial counts and unlock costs stay
undecided; lab loads are disposable QA fixtures, not product limits. The lab
only inspects; no progression, unlock purchase or new gameplay is implemented.
Stop at G0.5-R, await human validation, no G1 and no push.

## ADR-010 — Preserve approved G0.4 interaction, authorize G0.5 art study

Status: director-authorized scope, 2026-10-22; G0.5 artistic approval pending.

The G0.5 brief explicitly chooses modernized isometric A and direct G0.4 interaction.
The previous procedural art, UI and synthesized audio remain placeholders.
Preserve G0.4 in its own checkpoint commit before extending it. G0.5 is a small
four-plot art sample, not a reduction of the intended initial sixteen plots or
authorization to implement G1. It reuses the session-only simulation and gesture
arbiter, without economy, persistence, server or multiplayer.

Existing packs lack sufficient runtime clearance; use original AI-assisted outputs
with exact prompts, hashes, service terms and human review status. Never train on
packs or present geometry/synth as final production art/audio. The tool available
produces raster art but no mastered music; use the brief's permitted audio
specification fallback and silent missing-stream integration. Art/release approval
remains human. Missing UX_GAME_FEEL/FARM_VISUAL_SCALE are recorded as absent,
not inferred as approved documents. No gate after G0.5 is started.

## ADR-001 — Godot 4 + GDScript
Status: accepted

Use Godot 4.x stable and GDScript as the primary client stack.

Why:
- project is 2D and content/UI heavy;
- rapid AI-assisted iteration matters more than language familiarity;
- GDScript keeps Godot's broad platform path, including web as a future option;
- C# remains usable for tools/services outside the Godot client if ever useful.

## ADR-002 — Async social, not realtime multiplayer
Status: accepted

Friend visits, help, nuisance, stealing and pet defense are persisted server commands over snapshots. No always-on multiplayer session is required.

Why:
- matches the historic interaction model;
- drastically lowers backend complexity/cost;
- works well across different schedules/time zones;
- improves mobile reliability.

## ADR-003 — Server-authoritative economy
Status: accepted

Currencies, inventory, rewards, timers, theft, purchases and progression are calculated/validated by backend logic.

Why:
- cheating otherwise becomes trivial;
- social theft requires trusted shared state;
- enables support/auditing.

## ADR-004 — Supabase backend
Status: proposed/accepted for implementation spike

Use Postgres/Auth/Edge Functions as the first backend architecture. Re-evaluate only if a measured blocker emerges.

## ADR-005 — Internal codename only
Status: accepted

The repository/project may temporarily use ColheitaFeliz as an internal codename. Public branding must be original and receive naming/trademark review before release.

## ADR-006 — Asset packs are source material, not art direction
Status: accepted

We will intentionally combine, adapt, redraw and replace assets to achieve one coherent visual language. License must be verified before release use.

## ADR-007 — PC-friendly development, touch-safe UX from day one
Status: accepted

Development and frequent test builds can target desktop first, while all normal gameplay interactions must be designed to remain viable on phone/tablet.

## ADR-008 — G0 bootstrap and private asset quarantine
Status: accepted implementation boundary, 2026-10-21

G0.1 uses Godot 4.7.2 stable, Compatibility renderer, a neutral boot screen, one composition autoload and one minimal content service. No gameplay, network backend, platform SDK, fake economy or G0.3 scene is implemented. Additional services wait for actual consumers.

G0.2 extractions and contact sheets stay ignored under `.local/asset_audit/`, outside Godot. Original tracked archives are preserved byte-for-byte; their pre-existing repository/history redistribution risk is documented. No art is promoted to runtime. Visual grades are recommendations, not creative approval or legal clearance. Maeve FREE scope and SnowHex conflicting terms remain unresolved. Direction approval belongs to the human creative director. No gates are skipped.

## ADR-009 — G0.3 direction comparison, without art approval
Status: accepted scope; final direction pending creative director, 2026-10-21

The director explicitly authorized G0.3 as an A/B comparison after technically accepting G0.1/G0.2. The earlier G0.1/G0.2 boundary is historical; it does not imply G0.3 approval. A uses a consistent 2:1 isometric ground projection; B uses a front-facing oblique projection. Both use the same small fixture and original procedural placeholders, without importing unresolved-license packs. A shared renderer permits a controlled projection comparison; it is not a committed production art pipeline.

The menu/HUD, preview panels, camera, decorative animation and plot inspection exist only for art-direction evaluation. No authoritative economy, planting, inventory, animal production, multiplayer, monetization or event implementation is authorized. Audio is deferred. G0.3 stays unapproved until the director evaluates composition/readability on desktop and portrait and chooses a direction or requests changes. No G1 work is started.
