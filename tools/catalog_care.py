"""Record original G1.2 output provenance, never release approval."""
import hashlib
import json
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
source = ROOT/'game/assets/art/g12/care_atlas_v1.png'
raw = source.read_bytes()
asset = {'id':'g12.care.atlas.v1','file_path':source.relative_to(ROOT).as_posix(),
         'dimensions':list(struct.unpack('>II',raw[16:24])),'sha256':hashlib.sha256(raw).hexdigest(),
         'status':'ART_REVIEW','release_approved':False,
         'origin':'Original AI-assisted output; own crop atlas used as style reference only',
         'author':'OpenAI image_gen output for project owner; AI origin disclosed',
         'tool':'Built-in image_gen; specific model identifier not exposed','created':'2026-10-24',
         'license_record':'docs/G12_ART_AND_AUDIO.md','prompt':'docs/G12_PROMPTS.json#care_atlas',
         'commercial_use_allowed':'SUBJECT_TO_SERVICE_TERMS_AND_RELEASE_REVIEW',
         'redistribution_allowed':'ORIGINAL_OUTPUT_EMBEDDING_SUBJECT_TO_TERMS',
         'modification_allowed':'SUBJECT_TO_SERVICE_TERMS'}
(ROOT/'docs/g12_assets_manifest.json').write_text(json.dumps({'schema_version':1,'assets':[asset]},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('G1.2 original atlas recorded; release approval remains false')
