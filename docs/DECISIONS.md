# Architecture & Product Decisions

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
