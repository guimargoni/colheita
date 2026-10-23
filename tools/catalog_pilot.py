"""Provenance for original independent pilot images. Never release-approved."""
import hashlib
import json
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[1]
assets = []
for file, key in [('environment_v1.png','environment'),('crops_fx_v1.png','crops'),('ui_v1.png','ui'),('tree_v2.png','tree')]:
    path = ROOT/'game/assets/art/g05r_pilot'/file
    data = path.read_bytes()
    assets.append({
        'id':'pilot.v2.'+key,'file_path':path.relative_to(ROOT).as_posix(),
        'sha256':hashlib.sha256(data).hexdigest(),'dimensions':list(struct.unpack('>II',data[16:24])),
        'status':'FINAL_CANDIDATE' if key=='ui' else 'ART_REVIEW','release_approved':False,
        'origin':'Original AI-assisted output; original textual brief; no third-party input art',
        'author':'OpenAI imagegen output for project owner; AI origin disclosed',
        'tool':'Built-in image_gen; model identifier not exposed','created':'2026-10-23',
        'license_record':'docs/PILOT_V2_PROVENANCE.md','prompt':'docs/PILOT_V2_PROMPTS.json#'+key,
        'commercial_use_allowed':'SUBJECT_TO_SERVICE_TERMS_AND_RELEASE_REVIEW',
        'redistribution_allowed':'ORIGINAL_OUTPUT_EMBEDDING_SUBJECT_TO_TERMS',
        'modification_allowed':'SUBJECT_TO_SERVICE_TERMS',
    })
(ROOT/'docs/pilot_assets_manifest.json').write_text(json.dumps({'schema_version':1,'assets':assets},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Four original pilot assets recorded; no release approval')
