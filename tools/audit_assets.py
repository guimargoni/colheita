"""Local-only audit. Requires Pillow; RAR extraction uses system libarchive tar.
Never uploads art or modifies source archives. Outputs are private by .gitignore.
"""
import csv
import hashlib
import html
import json
import math
from pathlib import Path, PurePosixPath
import re
import subprocess
import zipfile
from collections import Counter, defaultdict
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / '.local/asset_audit'
EXTRACTED = WORK / 'extracted'
PACKS = [
    ('Farm RPG FREE 16x16 - Tiny Asset Pack.rar', 'Farm RPG FREE 16x16 - Tiny Asset Pack'),
    ('Harvest Sumer Free Ver. Pack.rar', 'Harvest Sumer Free Ver. Pack'),
    ('Super Pixel Effects Gigapack (Free Version) v3.1.0.zip', 'Super Pixel Effects Gigapack (Free Version)'),
]

def safe_name(name):
    p = PurePosixPath(name.replace('\\', '/'))
    if p.is_absolute() or '..' in p.parts or ':' in name:
        raise ValueError('Unsafe archive member: ' + name)
    return p

def extract():
    EXTRACTED.mkdir(parents=True, exist_ok=True)
    for archive, _ in PACKS:
        source = ROOT / archive
        if source.suffix == '.zip':
            with zipfile.ZipFile(source) as z:
                for item in z.infolist():
                    safe_name(item.filename)
                    if (item.external_attr >> 16) & 0o170000 == 0o120000:
                        raise ValueError('Symlink in archive')
                z.extractall(EXTRACTED)
        else:
            listing = subprocess.check_output(['tar', '-tf', str(source)], text=True)
            for name in listing.splitlines():
                safe_name(name)
            subprocess.run(['tar', '-xf', str(source), '-C', str(EXTRACTED)], check=True)

def classify(pack, rel):
    name = rel.name.lower()
    if pack == 2:
        group = rel.parts[1]
        if group == 'Symbols':
            return 'ui_icons', 'B', 'UI feedback; English text must be localized'
        if group in ['Magic Bursts', 'Smoke Bursts', 'Impacts']:
            return 'particles_vfx/' + group, 'B', 'Restrained harvest/help feedback; normalize scale and intensity'
        return 'particles_vfx/' + group, 'C', 'Prototype reference only; combat/sci-fi intensity conflicts with cozy farm'
    if 'character' in str(rel).lower(): return 'characters', 'B', 'Avatar/NPC; confirm directional rows and pivots'
    if 'farm animals' in str(rel).lower(): return 'animals', 'A', 'Production animals; verify frame slicing before integration'
    if 'spring crops' in name: return 'crops', 'A', 'Growth stages and produce; species/stage mapping needs human approval'
    if 'house' in name: return 'buildings', 'A', 'Farmhouse candidate; no processing building set present'
    if 'tree' in name: return 'trees', 'A' if pack == 0 else 'B', 'Vegetation; SnowHex palette needs harmonization with Maeve'
    if 'road' in name: return 'terrain', 'A', 'Paths; 16px grid candidate'
    if 'grass' in name: return 'terrain', 'A', 'Grass and terrain transitions'
    if 'set 1.' in name: return 'terrain', 'B', 'Mixed terrain/vegetation tileset; palette and autotile adjacency need review'
    if 'fence' in name: return 'decorations', 'A' if pack == 0 else 'B', 'Fences/ladders; normalize outlines and perspective'
    if 'leaf' in str(rel).lower(): return 'particles_vfx/leaves', 'B', 'Four-frame ambient leaves; restrain density'
    if 'harvest bg' in name: return 'reference', 'C', 'Composed background/reference; not a ready farm layout'
    return 'decorations', 'A' if pack == 0 else 'B', 'Props/interiors; select consistent anchors and shadows'

def write_csv(path, rows):
    with path.open('w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)

def main():
    extract()
    licenses = list(csv.DictReader((ROOT / 'docs/asset_pack_licenses.csv').open(encoding='utf-8-sig')))
    inventory, graphics, groups = [], [], defaultdict(list)
    for index, (archive, folder) in enumerate(PACKS):
        base = EXTRACTED / folder
        for p in sorted(base.rglob('*')):
            if not p.is_file(): continue
            rel = p.relative_to(base)
            digest = hashlib.sha256(p.read_bytes()).hexdigest()
            record = {'source_pack': archive, 'archive_path': str(rel).replace('\\','/'), 'bytes': p.stat().st_size, 'sha256': digest}
            inventory.append(record)
            if p.suffix.lower() not in {'.png','.jpg','.jpeg','.gif','.bmp','.webp'}: continue
            with Image.open(p) as img:
                img.load()  # decode every image, not just headers
                width, height = img.size
            category, grade, use = classify(index, rel)
            frames, tile, kind = 'UNKNOWN', '16x16 (base grid; mixed object sizes)', 'mixed spritesheet'
            note = use
            if index == 2:
                metadata = p.parent / 'spritesheet.txt'
                siblings = sorted(p.parent.glob('frame*.png'))
                if metadata.exists():
                    rects = [tuple(map(int, line.split(' = ')[1].split())) for line in metadata.read_text().splitlines() if ' = ' in line]
                    frames = str(len(rects))
                    tile = f'{rects[0][2]}x{rects[0][3]} (frame canvas)'
                    assert all(x >= 0 and y >= 0 and x+w <= width and y+h <= height for x,y,w,h in rects)
                    kind = 'animation spritesheet'
                else:
                    frames = str(len(siblings))
                    tile = f'{width}x{height} (frame canvas)'
                    kind = 'animation frame'
                note += '; 15 FPS per included guide; large/small and atlas/frames are alternate representations'
            elif 'Character' in rel.parts:
                frames = '4 per row (idle)' if 'idle' in p.name.lower() else '6 per row (walk)'
                tile = '32x32 (candidate frame canvas)'
            elif '4 frames' in p.name:
                frames = '4 (filename; visual sequence)'
                tile = 'UNKNOWN (not a terrain tile)'
            elif category == 'animals':
                note += '; repeated poses indicate animation; timing and row semantics undocumented'
            license_row = licenses[index]
            row = dict(license_row)
            row.update({'file_path': p.relative_to(ROOT).as_posix(), 'category': category, 'dimensions': f'{width}x{height}', 'tile_size': tile, 'animation_frames': frames, 'visual_grade': grade, 'intended_use': use, 'notes': license_row['notes'] + '; ' + note, 'kind': kind, 'sha256': digest})
            graphics.append(row)
            # All non-effect sheets; three poses of every effect/size/color sequence.
            if index != 2:
                groups[f'{index+1}_{category}'].append((p, rel.as_posix(), grade))
            elif kind == 'animation frame':
                seq = sorted(p.parent.glob('frame*.png'))
                if p in [seq[0], seq[len(seq)//2], seq[-1]]:
                    groups[f'3_{category}'].append((p, rel.as_posix(), grade))
    write_csv(ROOT / 'docs/assets_manifest.csv', graphics)
    write_csv(ROOT / 'docs/asset_file_inventory.csv', inventory)
    hashes = {a: hashlib.sha256((ROOT/a).read_bytes()).hexdigest() for a,_ in PACKS}
    (ROOT/'docs/asset_archive_hashes.json').write_text(json.dumps(hashes, indent=2)+'\n', encoding='utf-8')
    sheets = WORK / 'contact_sheets'
    sheets.mkdir(exist_ok=True)
    links = []
    for category, entries in sorted(groups.items()):
        for page in range(math.ceil(len(entries)/24)):
            batch = entries[page*24:(page+1)*24]
            canvas = Image.new('RGB', (1200, 55+math.ceil(len(batch)/4)*245), '#1d262b')
            draw = ImageDraw.Draw(canvas)
            draw.text((12,12), category + f' / page {page+1} / local review only / nearest-neighbor', fill='white')
            for n,(p,label,grade) in enumerate(batch):
                x, y = (n%4)*300, 55+(n//4)*245
                for cy in range(0,180,12):
                    for cx in range(0,288,12):
                        draw.rectangle((x+cx,y+cy,x+cx+11,y+cy+11),fill='#3a4549' if (cx//12+cy//12)%2 else '#303a3e')
                with Image.open(p) as im:
                    im = im.convert('RGBA')
                    scale = min(288/im.width,180/im.height)
                    scale = max(1,int(scale)) if scale >= 1 else scale
                    size = (max(1,int(im.width*scale)),max(1,int(im.height*scale)))
                    im = im.resize(size,Image.Resampling.NEAREST)
                    canvas.paste(im,(x+(288-im.width)//2,y),im)
                short = label.replace('PNG/','')
                for line in range(3): draw.text((x+4,y+184+line*14), short[line*43:(line+1)*43], fill='white')
                draw.text((x+4,y+226), f'Grade {grade} | {Image.open(p).size}', fill='#b7ddbd')
            name = re.sub(r'[^a-zA-Z0-9_-]','_',category)+f'_{page+1:02}.png'
            canvas.save(sheets/name)
            links.append(f'<h2>{html.escape(category)} / {page+1}</h2><a href="contact_sheets/{name}"><img loading="lazy" src="contact_sheets/{name}" width="1200"></a>')
    full_links = ''.join(f'<li>{html.escape(r["source_pack"])}: <a href="extracted/{html.escape(folder)}/{html.escape(r["archive_path"])}">{html.escape(r["archive_path"])}</a></li>' for r in inventory for a,folder in PACKS if a==r['source_pack'] and not r['archive_path'].startswith('PNG/'))
    (WORK/'index.html').write_text('<!doctype html><meta charset="utf-8"><title>G0.2 local asset review</title><style>body{background:#172126;color:#eee;font:16px sans-serif}img{max-width:100%;image-rendering:pixelated}a{color:#b9e9bb}</style><h1>G0.2 - Local review / private</h1><p>A=ship candidate; B=adapt; C=prototype only. Visual grades do not authorize shipping. Full sheets follow; effect sequences show first/middle/last. Click images for full resolution. Original atlases/files linked below. Categories absent from packs are documented in the report.</p>'+''.join(links)+'<h2>Original files (atlases + non-frame files)</h2><ul>'+full_links+'</ul>', encoding='utf-8')
    summary = {'files':len(inventory),'graphics':len(graphics),'by_pack':dict(Counter(r['source_pack'] for r in graphics)), 'by_category':dict(Counter(r['category'] for r in graphics)), 'grades':dict(Counter(r['visual_grade'] for r in graphics)), 'contact_sheets':len(links)}
    (ROOT/'docs/asset_audit_summary.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(summary,indent=2))

if __name__ == '__main__': main()
