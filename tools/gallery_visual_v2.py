"""Encode real Godot frame sequences, without retouching. Private artifacts only."""
from pathlib import Path
from PIL import Image
import io
import struct

out = Path(__file__).resolve().parents[1] / '.local/visual_v2'
cap = out / 'captures'

def chunk(tag, data):
    return tag + struct.pack('<I', len(data)) + data + (b'\0' if len(data) % 2 else b'')

def avi(paths, target):
    """Portable Motion-JPEG AVI; JPEG is codec encoding of unmodified captures."""
    first = Image.open(paths[0])
    width, height = first.size
    first.close()
    frames = []
    for path in paths:
        with Image.open(path) as image:
            buffer = io.BytesIO()
            image.convert('RGB').save(buffer, format='JPEG', quality=90)
            frames.append(buffer.getvalue())
    maximum = max(map(len, frames))
    avih = struct.pack('<14I', 41667, maximum * 24, 0, 16, len(frames), 0, 1, maximum, width, height, 0, 0, 0, 0)
    strh = struct.pack('<4s4sIHHIIIIIIIIhhhh', b'vids', b'MJPG', 0, 0, 0, 0, 1, 24, 0, len(frames), maximum, 0xFFFFFFFF, 0, 0, 0, width, height)
    strf = struct.pack('<IiiHH4sIiiII', 40, width, height, 1, 24, b'MJPG', width * height * 3, 0, 0, 0, 0)
    hdrl = chunk(b'LIST', b'hdrl' + chunk(b'avih', avih) + chunk(b'LIST', b'strl' + chunk(b'strh', strh) + chunk(b'strf', strf)))
    movi = bytearray(b'movi')
    index = bytearray()
    for frame in frames:
        index += struct.pack('<4sIII', b'00dc', 16, len(movi), len(frame))
        movi += chunk(b'00dc', frame)
    target.write_bytes(chunk(b'RIFF', b'AVI ' + hdrl + chunk(b'LIST', movi) + chunk(b'idx1', index)))

for device in ['pc', 'mobile']:
    paths = sorted(cap.glob(device + '_motion_*.png'))
    if len(paths) != 96:
        raise RuntimeError('Expected 96 real frames per device')
    avi(paths, out / (device + '_motion.avi'))
    frames = []
    for path in paths:
        with Image.open(path) as image:
            frames.append(image.convert('RGB').quantize(colors=256, method=Image.Quantize.FASTOCTREE))
    frames[0].save(out / (device + '_motion.gif'), save_all=True, append_images=frames[1:], duration=42, loop=0)
    for image in frames:
        image.close()

html = ['''<!doctype html><html lang="pt-BR"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Colheita · Fundação visual v2</title><style>body{background:#f9efdb;color:#243e39;font:18px system-ui;margin:24px}section{display:flex;gap:24px;flex-wrap:wrap}figure{margin:0;max-width:46%}img{max-width:100%;max-height:85vh}</style><h1>Fazenda Viva · versão integrada</h1><p>Para jogar: JOGAR_COLHEITAFELIZ.cmd na raiz. Esta galeria mostra capturas reais do Godot, não é o jogo. Arte em revisão. Recursos conquistados em fixtures isoladas, sem alterar saves pessoais.</p>''']
for device in ['pc', 'mobile']:
    html.append(f'<h2>Animações · {device}</h2><a href="{device}_motion.avi">Vídeo real AVI Motion-JPEG · 4 s, 24 fps nominais, sem áudio</a><p>I/O afeta a cadência; não é benchmark de FPS. GIF abaixo é preview com compressão de cor.</p><img src="{device}_motion.gif">')
for name in ['standard', 'halloween', 'shop', 'animals', 'inventory']:
    html.append(f'<h2>{name}</h2><section>')
    for resolution in ['1920x1080', '1080x1920']:
        html.append(f'<figure><img loading="lazy" src="captures/visual_{resolution}_{name}.png"><figcaption>{resolution}</figcaption></figure>')
    html.append('</section>')
(out / 'index.html').write_text('\n'.join(html), encoding='utf-8')
print('Visual v2 gallery and two AVI videos PASS: ' + str(out))
