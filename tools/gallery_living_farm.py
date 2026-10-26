"""Encode unretouched Godot frames as GIF and a private comparison gallery."""
from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parents[1]
out=root/'.local/g1v'
cap=out/'captures'
for option in ['A','B']:
    frames=[Image.open(p).convert('RGB') for p in sorted(cap.glob(f'motion_{option}_*.png'))]
    if len(frames)!=72: raise RuntimeError('Missing Godot motion frames')
    frames[0].save(out/f'motion_{option}.gif',save_all=True,append_images=frames[1:],duration=42,loop=0,optimize=False)
    for frame in frames: frame.close()
html=['''<!doctype html><html lang="pt-BR"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>G1.V — Fazenda Viva</title><style>body{font:18px system-ui;background:#f6f1e1;color:#244f47;margin:28px}section{display:flex;gap:20px;flex-wrap:wrap}figure{margin:0;max-width:47%}img{max-width:100%;max-height:85vh;border-radius:12px}a{color:#245f55}</style><h1>G1.V — Fazenda Viva</h1><p>Para JOGAR: execute JOGAR_G1V_TESTE.cmd na raiz do repositório. Esta página exibe capturas e gravações reais do Godot, sem retoque.</p><p>A: pixel art modernizada. B: híbrido com cartões arredondados, sombras mais suaves e gradação sutil de luz. Mesma lógica, cenário e sprites. Direção pendente de decisão humana.</p><h2>Movimento · 960×540</h2><p>Frames reais capturados em sequência, codificados a 24 fps para comparação visual. Não são benchmark de FPS nem gravação de toque em aparelho físico.</p><section>''']
for option in ['A','B']: html.append(f'<figure><img src="motion_{option}.gif"><figcaption>Opção {option} · colheita, rega, fertilizante e transição da loja</figcaption></figure>')
html.append('</section>')
for res in ['1920x1080','1080x1920']:
    for name,title in [('farm','Fazenda'),('shop','Loja'),('inventory','Inventário')]:
        html.append(f'<h2>{res} · {title}</h2><section>')
        for option in ['A','B']: html.append(f'<figure><img loading="lazy" src="captures/g1v_{res}_{option}_{name}.png"><figcaption>Opção {option}</figcaption></figure>')
        html.append('</section>')
(out/'index.html').write_text('\n'.join(html),encoding='utf-8')
print(f'Gallery and 2 GIFs: {out}')
