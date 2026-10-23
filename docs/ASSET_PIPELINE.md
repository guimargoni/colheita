# Asset Pipeline and Audit

Independent Cozy pilot v2: `pilot_assets_manifest.json` adds original review/candidate
outputs without changing the historical inventories or their approvals. Prompts and
terms are in `PILOT_V2_PROMPTS.json` / `PILOT_V2_PROVENANCE.md`. The checker validates
both runtime manifests; candidate status never implies `release_approved`.

G0.5-R adds the destination matrix `G0_5R_ASSET_MATRIX.csv`, audio catalog
`audio_catalog_g05r.csv` and proposed metadata in `game/data/art/visual_standard.json`.
These are review/production contracts, not new release approvals. Existing PNGs,
hashes and license statuses remain unchanged. The user's mockup is an external
reference, privately preserved under `.local/g0_5r/`, never runtime/source art.

## Goal
Use every high-quality asset that genuinely helps the game while preserving a coherent visual language and legal clarity.

Current repository source packs:
- `Farm RPG FREE 16x16 - Tiny Asset Pack.rar`
- `Harvest Sumer Free Ver. Pack.rar`
- `Super Pixel Effects Gigapack (Free Version) v3.1.0.zip`

These are **unreviewed sources**, not automatically approved shipping assets.

## Required audit record
Create `assets_manifest.csv` with:
- source_pack;
- source_url;
- author;
- license_name;
- license_text_location;
- commercial_use_allowed;
- attribution_required;
- redistribution_allowed;
- modification_allowed;
- file_path;
- category;
- dimensions;
- tile_size;
- animation_frames;
- visual_grade;
- intended_use;
- notes.

Use UNKNOWN until verified. Unknown-license assets must not be shipped.

## Visual grading

### A — ship candidate
Matches target scale/palette/readability with minor or no modification.

### B — adapt
Good art but needs palette harmonization, outline changes, animation cleanup, scaling or redraw.

### C — prototype only
Useful for mechanics/prototyping, but style mismatch prevents final use.

### Reject
Poor readability, unclear license, technically unusable, or strongly inconsistent.

## First contact sheet
Codex should unpack packs locally and generate contact sheets grouped by:
- terrain;
- farm plots;
- crops;
- trees;
- buildings;
- animals;
- characters;
- decorations;
- UI/icons;
- particles/VFX.

The creative director should approve visual direction using the contact sheets before mass integration.

## Pixel rules
Final rules are established after first audit, but likely:
- nearest-neighbor filtering;
- integer or controlled scaling;
- no accidental smoothing;
- consistent pixels-per-tile;
- coherent outline weight;
- standardized shadow direction;
- consistent anchor/origin rules.

## Asset naming
Runtime:
`category_entity_variant_state_frame.ext`

Examples:
- `crop_carrot_stage_01.png`
- `animal_cow_brown_idle_00.png`
- `guardian_dog_black_bite_03.png`
- `deco_fence_wood_corner_ne.png`

Do not expose source-pack naming to gameplay code.

## Atlases
Pack sprites into atlases only after:
- original slices are verified;
- pivots are correct;
- animation naming is stable.

Keep source and generated artifacts clearly separated.

## Animation minimums
Where quality permits:
- crops: multiple growth states + mature sparkle/wind;
- animals: idle + production/interaction;
- guardian: idle + alert + chase/bite;
- buildings: idle ambience;
- decorations: selected hero items animated;
- UI: small feedback transitions.

## Missing art strategy
Order of preference:
1. reuse an A-grade licensed asset;
2. adapt B-grade licensed asset;
3. create a new matching asset;
4. commission/recreate an entire inconsistent family rather than patching dozens of mismatched sprites.

## AI-generated art
May be used for original production where licensing/platform terms permit. Generated outputs should still be art-directed, reviewed and normalized to the project pixel rules.

Never ask an image model to reproduce a proprietary original Colheita Feliz asset exactly.

## Legal note

G0.5: source-pack inventory remains `assets_manifest.csv`, entirely quarantined.
New original runtime outputs are tracked in `runtime_assets_manifest.json` with
hashes, origin, terms and review status. See `G0_5_ASSET_PROVENANCE.md` and
`ART_BIBLE.md`. No source-pack clearance is implied by these original additions.
The repository checker allows only recorded files and Godot import metadata;
original art is never automatically promoted to release approval.

“Free” in a filename is not proof of commercial licensing. Record the actual license/source before release use.
