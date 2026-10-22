# Asset-first production policy — Director decision

Status: APPROVED creative direction, 2026-10-21

## Non-negotiable
The shipped game must NOT retain primitive procedural drawings, placeholder geometry, placeholder synthesizer tracks, or programmer-art user interfaces merely because they work. G0.3/G0.4 procedural art and sound are prototypes, not approval for final content.

## Production precedence
1. Review existing artist-made licensed assets for quality, consistency and commercial release rights.
2. If suitable, integrate carefully and document provenance.
3. If unsuitable or missing, create original sprites/spritesheets, tiles, icons, VFX and sound/music using legitimate original production (including AI-assisted workflows subject to license/provenance review), then art-direct and polish.
4. Use programmatic drawing/synthesis only for temporary placeholders, debugging visuals, procedural positioning/motion, subtle enhancements, particles, camera, scalable shapes, transitions and other genuine technical use cases.

## Required art source
- Environment: authored coherent isometric/oblique tilesets, crops by growth stages, buildings, foliage, pets, livestock, decorations.
- UI: designed button/panel/icon assets, responsive layout, hover/pressed/disabled states.
- VFX: authored pixel effects where appropriate, selectively mixed with engine particles.
- Audio: mastered loop-ready background tracks, licensed and tested for comfort; authored sound-effect files for planting, harvest, water, coins, menus and pets. Procedural test music/SFX must be flagged as temporary.
- Ambient movement: authored animation cycles where possible; code controls timing/positioning/variation.

## Quality gates
- No placeholder promoted to release without explicit director review.
- Demonstrate one coherent sample scene and UI kit, including crops, farmhouse, tree, chicken/pet, harvest VFX, music/SFX, desktop and mobile.
- Maintain per-asset license and origin manifest, including prompts/source where relevant.
- No generative-model training on packs forbidding AI training.
- Confirm commercial-use and game-embedding rights before distribution.
- Audit pixel density, palette, shadows, perspective, outlines, pivot points, frame timings, looping and audio loudness.
- Capture and review gameplay on PC/mobile with and without sound.
- Gameplay must remain fluid; visuals/audio never block input.

## Immediate G0.4 note
Preserve the current direct click/drag interaction prototype; do not mistake its polygonal trees/buildings, basic UI, synthesized audio and test effects for approved art direction. Final art production is a separate milestone prior to wide content implementation.
