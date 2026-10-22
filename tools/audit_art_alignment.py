"""Read-only alpha measurements of legacy sprites. Outputs QA JSON, never edits PNG."""
import hashlib
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
source = ROOT / 'game/assets/art/g05/animals_atlas_v1.png'
image = Image.open(source).convert('RGBA')
clips = {
    'chicken_idle': [(x, 20, 220, 236) for x in [130, 488, 846, 1195]],
    'chicken_walk': [(x, 280, 235, 220) for x in [130, 488, 846, 1195]],
    'dog_attention': [(x, 512, 255, 266) for x in [100, 455, 815, 1175]],
}
results = {}
for name, frames in clips.items():
    measured = []
    for x, y, width, height in frames:
        # Opaque subject only; excludes faint generated atmospheric alpha.
        points = [(px, py) for py in range(height) for px in range(width)
                  if image.getpixel((x + px, y + py))[3] >= 192]
        if not points:
            raise ValueError(f'Empty measured frame {name}')
        left, top = min(p[0] for p in points), min(p[1] for p in points)
        right, bottom = max(p[0] for p in points), max(p[1] for p in points)
        measured.append({'source_rect': [x,y,width,height],
                         'alpha_bounds': [left,top,right-left+1,bottom-top+1],
                         'lowest_alpha_y': bottom})
    feet_range = max(m['lowest_alpha_y'] for m in measured) - min(m['lowest_alpha_y'] for m in measured)
    results[name] = {
        'frames': measured, 'lowest_alpha_range_source_px': feet_range,
        'status': 'LEGACY_REVIEW_REQUIRED',
        'warning': 'Alpha bounds are not anatomical foot annotations; not production alignment certification',
    }
output = ROOT / '.local/g0_5r/legacy_alignment.json'
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(json.dumps({'sha256':hashlib.sha256(source.read_bytes()).hexdigest(),
                             'alpha_threshold':192,'clips':results},indent=2)+'\n',encoding='utf-8')
for name, result in results.items():
    print(name, 'lowest-alpha range:', result['lowest_alpha_range_source_px'], 'source px; REVIEW REQUIRED')
print(output)
