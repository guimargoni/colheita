"""Private real-Godot evidence gallery; GIF encoding only, no image retouching."""
from pathlib import Path
from PIL import Image
out=Path(__file__).resolve().parents[1]/'.local/integrated';cap=out/'captures'
frames=[Image.open(p).convert('RGB').quantize(colors=256,method=Image.Quantize.FASTOCTREE) for p in sorted(cap.glob('motion_*.png'))]
if len(frames)!=96: raise RuntimeError('Incomplete motion capture')
frames[0].save(out/'farm_motion.gif',save_all=True,append_images=frames[1:],duration=42,loop=0,optimize=False)
for frame in frames:frame.close()
html=['''<!doctype html><html lang="pt-BR"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Colheita · versão integrada</title><style>body{font:18px system-ui;background:#f8f1e2;color:#244f47;margin:28px}section{display:flex;gap:20px;flex-wrap:wrap}figure{margin:0;max-width:48%}img{max-width:100%;max-height:85vh;border-radius:12px}</style><h1>Colheita · versão integrada local</h1><p>Para JOGAR: dê dois cliques em JOGAR_COLHEITAFELIZ.cmd na raiz do repositório. Esta página é somente evidência visual real do Godot.</p><p>Capturas usam fixtures isoladas com recursos conquistados por comandos de jogo; não alteram seus saves nem representam a fazenda inicial. Arte original assistida por IA em revisão. Social entre dois processos é testado separadamente contra servidor local real, sem hospedagem pública.</p><h2>Movimento e interações · 960×540</h2><img src="farm_motion.gif"><p>96 frames reais, codificados nominalmente a 24 fps, sem áudio. Compressão GIF não é referência de cor final nem benchmark de FPS; o I/O de captura afeta a cadência.</p>''']
for title,name in [('Fazenda','farm'),('Animais e produção','animals'),('Inventário','inventory')]:
 html.append(f'<h2>{title}</h2><section>')
 for res in ['1920x1080','1080x1920']:html.append(f'<figure><img loading="lazy" src="captures/integrated_{res}_{name}.png"><figcaption>{res}</figcaption></figure>')
 html.append('</section>')
(out/'index.html').write_text('\n'.join(html),encoding='utf-8');print('Integrated gallery: '+str(out/'index.html'))
