"""Dependency-free repository policy and manifest checks (not a full secret scanner)."""
import csv
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
errors = []
def check(value, message):
    if not value: errors.append(message)

required = ['autoload','scenes/boot','scenes/farm','scenes/social','scenes/shop','scenes/inventory','scenes/profile','scenes/settings','scripts/domain','scripts/services','scripts/api','scripts/ui','scripts/utils','data/crops','data/animals','data/items','data/levels','data/quests','assets/art','assets/audio','assets/fonts','tests']
for folder in required: check((ROOT/'game'/folder).is_dir(), 'Missing game/'+folder)
for folder in ['migrations','functions','seed']: check((ROOT/'backend/supabase'/folder).is_dir(), 'Missing backend '+folder)
for p in (ROOT/'game/assets').rglob('*'): check(not p.is_file() or p.name == '.gitkeep', 'Unapproved runtime asset: '+str(p))
rows = list(csv.DictReader((ROOT/'docs/assets_manifest.csv').open(encoding='utf-8-sig')))
fields = ['source_pack','source_url','author','license_name','license_text_location','commercial_use_allowed','attribution_required','redistribution_allowed','modification_allowed','file_path','category','dimensions','tile_size','animation_frames','visual_grade','intended_use','notes']
check(bool(rows), 'Empty manifest')
for row in rows:
    check(all(row.get(f) for f in fields), 'Incomplete manifest row '+row.get('file_path','?'))
    check(row.get('visual_grade') in ['A','B','C','Reject'], 'Invalid visual grade')
    check(bool(re.fullmatch(r'\d+x\d+', row.get('dimensions',''))), 'Invalid dimensions')
    check(row['file_path'].startswith('.local/asset_audit/extracted/'), 'Asset escaped quarantine')
check(len({r['source_pack'] for r in rows})==3, 'Expected three packs')
inventory = list(csv.DictReader((ROOT/'docs/asset_file_inventory.csv').open(encoding='utf-8')))
check(len(rows)==sum(Path(r['archive_path']).suffix.lower() in ['.png','.jpg','.jpeg','.gif','.bmp','.webp'] for r in inventory), 'Graphics inventory mismatch')
check(len({r['file_path'] for r in rows})==len(rows), 'Duplicate manifest path')
summary = json.loads((ROOT/'docs/asset_audit_summary.json').read_text(encoding='utf-8'))
check(summary['graphics'] == len(rows) and summary['files'] == len(inventory), 'Summary mismatch')
for archive, digest in json.loads((ROOT/'docs/asset_archive_hashes.json').read_text()).items():
    source = ROOT/archive
    if source.exists():
        check(hashlib.sha256(source.read_bytes()).hexdigest() == digest, 'Original archive changed: '+archive)
# Ignore rules do not untrack archives already in repository history.
tracked = subprocess.check_output(['git','ls-files'],cwd=ROOT,text=True).splitlines()
for path in tracked:
    check(not path.startswith(('.local/','assets_source/','game/config/local.cfg')), 'Private work tracked: '+path)
# Inspect current first-party text, including not-yet-tracked files. No secret values printed.
patterns = [r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----', r'(?<![A-Z0-9])AKIA[A-Z0-9]{16}', r'gh[pousr]_[A-Za-z0-9]{30,}', r'sbp_[a-f0-9]{40}']
for parent in ['game','tools','docs','.github']:
    for p in (ROOT/parent).rglob('*'):
        if not p.is_file() or '.godot' in p.parts or p.suffix not in ['.gd','.tscn','.godot','.cfg','.py','.ps1','.md','.yml','.csv','.json']: continue
        content=p.read_text(encoding='utf-8-sig')
        for pattern in patterns: check(not re.search(pattern,content), 'Potential secret in '+str(p.relative_to(ROOT)))
        check(not any(line.endswith((' ','\t')) for line in content.splitlines()) or p.suffix=='.md', 'Trailing whitespace: '+str(p.relative_to(ROOT)))
if errors:
    print('\n'.join(sorted(set(errors))))
    raise SystemExit(1)
print(f'Repository checks PASS: {len(rows)} graphics, {len(inventory)} source files; structure, metadata, quarantine, baseline secret patterns')
