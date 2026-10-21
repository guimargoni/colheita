# Asset audit report — G0.2

Audit date: 2026-10-21. Scope: the three original archives present in `guimargoni/colheita`. Base: `origin/foundation/game-design`; work branch: `foundation/g0-bootstrap-audit`. No G0.3 or G1 work was performed.

Technical delivery: **G0.1 PASS; G0.2 PASS**. The director has technically accepted G0.1 and G0.2. Visual direction and asset licensing still require human review; technical acceptance is not permission to proceed or ship art. License uncertainties block promotion of affected assets, not a local audit.

## Inventory and reproducibility

| Pack / author | Files | Graphics | Useful contents actually present |
|---|---:|---:|---|
| Farm RPG FREE / Maeve | 15 | 15 PNG | avatar idle/walk, chick/egg, two chicken palettes, male/female brown cow, house components, furniture, chest, fence, paths, spring crops, maple tree, grass transitions |
| Harvest Sumer Free / SnowHex | 9 | 8 PNG | three terrain sheets, fences/ladders, trees/stumps, objects/tools/fruit/potions, four-frame leaves, composed background |
| Super Pixel Effects Free v3.1.0 / Will Tice, unTied Games | 6,134 | 5,923 PNG | 103 effect types, two canvas sizes per type, individual frames and corresponding atlases/rectangle metadata, guide/license/changelog/list |
| Total | **6,158** | **5,946 PNG** | 212 text files; no audio, fonts, Aseprite/PSD sources or other graphics formats in these archives |

The 5,923 VFX images represent **5,717 individual frames + 206 atlases**, not thousands of independent effects. Frame/atlas duplicates and large/small alternates must not inflate content counts. `docs/asset_file_inventory.csv` records every extracted file with relative archive path, size and SHA-256, including text/license files. `docs/assets_manifest.csv` records every graphic, dimensions, category, proposed grade, use, legal status and hash. `asset_pack_licenses.csv` preserves pack-level provenance; `asset_archive_hashes.json` fingerprints originals. `asset_audit_summary.json` contains exact machine counts.

All 5,946 graphics were fully decoded. No corrupt/unreadable image was detected. Every VFX atlas rectangle was checked against image bounds. The original archive hashes match bytes read directly from Git HEAD. Original names and included licenses were preserved without editing. No assets were trained on, sent to an image generator or used for imitation of the original Colheita Feliz.

## Dimensions, sheets and animation candidates

| Family | Sheet dimensions | Grid / animation evidence |
|---|---|---|
| Maeve avatar | Idle 128×96; Walk 192×96 | 32×32 candidate frames; three rows; 4 idle / 6 walk poses per row. Direction ordering/pivots need a slicing review. |
| Maeve chick/egg | 64×48 | 16×16 grid, four columns, chick poses and egg row; rows are not one continuous animation. |
| Maeve chickens | 64×32 each | 16×16, four columns × two rows; visual pose changes. Duration not supplied. |
| Maeve cows | 128×96 each | 32×32 candidate frames, four columns × three rows. More transparent canvas than chickens; do not rescale bodies blindly to fill slots. |
| Spring Crops | 224×128 | mixed 16px cells with growth stages, seed/produce/container icons. Four visible crop families, visually consistent with strawberry, onion, potato, carrot; IDs and exact stage counts are unapproved hypotheses. Growth stages are discrete states, not automatically idle animations. |
| House / Interior / Chest | 224×112 / 192×144 / 32×32 | mixed components, props and possible variants; no animation metadata. Chest has multiple appearances; timing/rectangles not documented. |
| Maeve grass / path / maple | 192×64 / 80×64 / 160×48 | 16px terrain basis, irregular props and tree states; not uniform animation strips. |
| SnowHex Set 1.0 / 1.1 / 1.2 | 288×224 / 288×144 / 256×144 | mixed 16px terrain edges, flowers, small plants; overlapping versions/variants require deduplication before atlas authoring. |
| SnowHex fences / trees / props | 192×119 / 160×80 / 80×32 | mixed objects; fence sheet height is not divisible by 16, so do not auto-slice the entire file into a rectangular grid without review. |
| SnowHex leaves / background | 128×16 / 1920×1760 | leaf filename specifies four frames; 32×16 canvas per frame is a candidate, not 16px-wide frames. Background is a composed reference, not ready interactive terrain. |
| unTied effects | exact per-file dimensions in manifest; atlas widths reach 5120px | 206 sequences with authoritative `spritesheet.txt` rectangle counts; 15 FPS stated by included guide. Canvas dimensions vary per effect and size. Never interpret large atlases as huge terrain tiles. |

No dedicated complete farm plot set (prepared/wet/locked/etc.), processing building family, guardian animal or full UI kit was found. Terrain ground patches can inform a later prototype but are not an approved plot-state family. Farm plot contact sheet is therefore absent rather than fabricated. The free SnowHex archive does not include the chickens advertised elsewhere on the broader product page. The broader paid Maeve catalog is likewise not part of this inventory.

## Visual classification and recommended base

Grade totals count image files, including individual animation frames: **A 13; B 4,698; C 1,235; Reject 0**. Grade is separate from license status. No asset was rejected solely for taste. No file failed decoding; no permanent technical discard was warranted. Unknown/conflicting legal scope remains quarantined even when its art grade is A.

- **A — ship candidate:** Maeve animals, crops, house, grass/path, maple tree and props. Clear silhouettes, lively warm reds/browns, consistent dark contours and compact 16px basis make this the strongest *candidate* base for the requested farm. Legal FREE scope still needs confirmation. An A grade does not assert complete animations or exact slice coordinates.
- **B — adapt:** avatar, SnowHex terrain/trees/fences/props/leaves, unTied impacts/magic bursts/smoke and symbols. Maeve avatar needs direction/anchor review. SnowHex has brighter yellow-green ground, chunkier rounded tree masses, lighter outlines and orange soil; harmonize palette, contour/shadow weight and ground saturation before mixing with Maeve. Effects require intensity/scale tuning; English raster text needs localization or replacement with text rendered in the UI.
- **C — prototype only:** SnowHex composed background and unTied explosions, fire, lightning, fantasy spell, sci-fi and splatter families. Sweeping combat effects, blood-like red splatters, lasers, death/status symbols and bright energy rings conflict with restrained cozy feedback at default size. This is an intentionally conservative family-level triage; isolated sparkle/heal elements may later be promoted after manual selection. Original material is retained.
- **Reject:** none assigned. Any later rejection must record a concrete reason per file/family and retain provenance.

Maeve is recommended for a review, not definitively selected. SnowHex could alternatively support a brighter woodland direction, but would require adapting Maeve livestock and architecture to its softer contours and saturated greens. Choosing one dominant ground/tree family is preferable to mixing both at random. The current bootstrap deliberately shows neutral text and no farm arrangement.

## Compatibility and mapping to future systems

| System | Candidates and combinations | Conflict / missing work |
|---|---|---|
| Ground and decoration | Maeve grass + paths + house + fences + maple; coherent within its own pack | complete plot states, water/shore, expansion boundaries and mobile ground contrast need production |
| Crops/inventory/shop | Maeve spring sheet stages + seed/produce icons | only a small starter set; not the beta target of 24 crops; wet/care/pest feedback and item mapping absent |
| Animals | Maeve chick/egg, two chicken palettes, brown cow sexes | only chicken/cow families; baby/sex/color variants are not new species; no feed/production interaction contracts |
| Forest theme | SnowHex terrain + trees + fences + leaves work together | Maeve house roof/animal outlines are darker; colors and shadows need adaptation; no complete alternate farm theme exists |
| Harvest/help/celebration | small unTied coin/heart/sparkle bursts and modest smoke/impact subsets | tune to 16px world density; avoid flashes covering crop silhouettes; symbol family is not a complete UI |
| Social/guardian | symbol alerts/checkmark/thumbs-up can inform feedback | original friend portraits, feed icons and dog alert/chase/bite family missing |
| UI | embedded crop/prop icons and selected unTied symbols | panels/buttons/9-slice states, accessible icons, touch targets, original branding and localized type missing |
| Buildings | Maeve farmhouse component sheet | six processing building families and their idle/production states missing |

## Missing art production list

Create or lawfully acquire complete plot states; crop stage families through the target catalog; pests/weeds/watering/fertilizer feedback; guardians with idle/alert/chase/bite; additional production animals and collection states; mills/bakery/dairy/workshops; placeable decorations with consistent anchors; alternate terrain/themes including water; original UI and branding; audio/SFX/music and licensed fonts. Define outline weight, pixels-per-unit, common anchors and shadow direction with the director before mass integration. Do not produce these during G0.2.

## Contact sheets and creative review

Generated **42 private PNG pranchas**, grouped by pack/category, with checkerboard transparency, filenames, dimensions and A/B/C labels. All 23 non-VFX graphics appear; every effect/size/color sequence is represented by first/middle/last frames. This is static pose review, not frame-perfect animation playback QA. Every full atlas and non-frame source is linked in the local HTML; the inventory records all individual frames. No contact sheet is intended for public redistribution.

1. Open the repository folder, then double-click `.local/asset_audit/index.html` in a browser.
2. Compare the pack 1 animals/crops/buildings/terrain sheets with pack 2 terrain/trees/fences. Click a sheet to inspect at full resolution; follow source-file links for the original atlas.
3. Inspect VFX category pages, noting that large/small versions and start/end poses are deliberate duplicates for comparison.
4. Record approval or requested changes for base palette, outline weight, tile density, tree silhouette, crop readability and acceptable VFX intensity. The director can approve, request adaptation or reject with a reason. No approval is assumed.
5. Run the Godot boot separately using `docs/DEVELOPMENT.md`; this audit does not add a visual prototype to the game.

To regenerate on a clean clone, obtain the original packs from their authors, keep them private in the root, install `tools/requirements-audit.txt`, and run `python tools/audit_assets.py`. Extraction/contact sheets are ignored and need no engine import. `docs/DEVELOPMENT.md` gives exact commands and paths for this machine.

## Licensing risks and blockers

See `ASSET_LICENSE_RECORD.md` and pack-level CSV for source URLs, authors, included evidence paths and unresolved permissions. Maeve's FREE license scope is unconfirmed; SnowHex has a bundled non-commercial restriction conflicting with newer public terms; unTied requires credit, excludes standalone redistribution and delegates to full external terms that must be archived before release. All three prohibit AI training in the available evidence. No third-party art exists in `game/assets/`.

The original archives were already tracked before this task. They remain byte-identical, and `.gitignore` does not erase repository history. This is a pre-existing redistribution exposure requiring an owner decision before publishing the repository. No new pack, extracted file or contact sheet was added to Git. No source file/history was deleted to hide it.

**Current technical blockers: none after normal-permission validation.** Release promotion blockers: license clarifications/full terms, existing source archive distribution, creative approval, verified slices/animation directions. CI workflow is configured but has not run on GitHub in this local task. Human visual direction and licensing review remain pending. G0.3 and G1 are not started.
