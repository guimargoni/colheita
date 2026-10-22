# Architecture & Product Decisions

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
