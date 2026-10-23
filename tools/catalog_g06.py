"""Hash original outputs and record review status; no source image manipulation."""
import hashlib
import json
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
assets = []
for file, prompt in [('garden_kit_v1.png','clean'),('action_fx_v1.png','fx'),('path_v2.png','path')]:
    source = ROOT/'game/assets/art/g06'/file
    raw = source.read_bytes()
    assets.append({
        'id':'g06.'+source.stem, 'file_path':source.relative_to(ROOT).as_posix(),
        'dimensions':list(struct.unpack('>II',raw[16:24])), 'sha256':hashlib.sha256(raw).hexdigest(),
        'status':'ART_REVIEW', 'release_approved':False,
        'origin':'Original AI-assisted output; original project art as style input only for kit and FX',
        'author':'OpenAI image_gen output for project owner; AI origin disclosed',
        'tool':'Built-in image_gen, model identifier not exposed', 'created':'2026-10-23',
        'license_record':'docs/G06_PROVENANCE.md', 'prompt':'docs/G06_PROMPTS.json#'+prompt,
        'commercial_use_allowed':'SUBJECT_TO_SERVICE_TERMS_AND_RELEASE_REVIEW',
        'redistribution_allowed':'ORIGINAL_OUTPUT_EMBEDDING_SUBJECT_TO_TERMS',
        'modification_allowed':'SUBJECT_TO_SERVICE_TERMS',
    })
(ROOT/'docs/g06_assets_manifest.json').write_text(json.dumps({'schema_version':1,'assets':assets},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Three original G0.6 images recorded; none release-approved')
