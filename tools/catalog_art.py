"""Record original outputs; never promotes art to release approval."""
import hashlib
import json
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[1]
entries = []
for family in ['environment', 'crops', 'animals', 'ui', 'terrain']:
    path = ROOT / f'game/assets/art/g05/{family}_atlas_v1.png'
    data = path.read_bytes()
    assert data[:8] == b'\x89PNG\r\n\x1a\n'
    width, height = struct.unpack('>II', data[16:24])
    prompt = {'ui': 'G0_5_UI_PROMPT.json', 'terrain': 'G0_5_TERRAIN_PROMPT.json'}.get(family, 'G0_5_ART_PROMPTS.json')
    entries.append({
        'id': f'art.g05.{family}.v1',
        'file_path': path.relative_to(ROOT).as_posix(),
        'sha256': hashlib.sha256(data).hexdigest(),
        'dimensions': [width, height],
        'status': 'ART_REVIEW', 'visual_grade': 'B',
        'origin': 'Original AI-assisted output; textual brief only; no pack inputs',
        'author': 'AI-generated with OpenAI imagegen, art direction for project owner',
        'tool': 'Built-in image_gen; model identifier not exposed',
        'created': '2026-10-22', 'prompt': f'docs/{prompt}#{family}',
        'license_record': 'docs/G0_5_ASSET_PROVENANCE.md',
        'commercial_use_allowed': 'SUBJECT_TO_SERVICE_TERMS',
        'redistribution_allowed': 'ORIGINAL_OUTPUT_GAME_EMBEDDING_SUBJECT_TO_TERMS',
        'modification_allowed': 'SUBJECT_TO_SERVICE_TERMS',
        'attribution': 'Disclose AI origin; no third-party pack attribution applies',
        'release_approved': False,
    })
manifest = {'schema_version': 1, 'scope': 'Runtime originals; source-pack CSV remains quarantined', 'assets': entries}
(ROOT / 'docs/runtime_assets_manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('Recorded five original outputs as ART_REVIEW, never release approved')
