"""Gallery of actual Godot captures, no image retouching or external assets."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
out = ROOT/'.local/g11'
html = ['''<!doctype html><html lang="pt-BR"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Agricultura G1.1</title><style>body{font:18px system-ui;background:#fff2d5;color:#203d4a;margin:24px}section{display:flex;gap:16px;flex-wrap:wrap}figure{margin:0;max-width:48%}img{max-width:100%;max-height:85vh}h2{margin-top:40px}</style><h1>Fazenda Viva — agricultura G1.1</h1><p>18 capturas reais do Godot, sem retoque. Relógio controlado e fixture de teste isolada; saves do usuário não são alterados. Persistência entre processos validada separadamente nos testes.</p><p>Trigo reutiliza folhagem como placeholder identificado. Arte e caminho aguardam acabamento; nenhum asset foi promovido para release.</p>''']
for res in ['1920x1080','1080x1920']:
    html.append(f'<h2>{res}</h2><section>')
    for name,label in [('farm','Cena funcional'),('crop_1','Cenoura madura'),('crop_2','Morango e tempo restante'),('crop_3','Trigo · arte provisória'),('inventory_before','Inventário antes da colheita'),('harvest','Colheita imediata'),('inventory_after','Inventário com produto creditado'),('planted','Replantio · estágio inicial'),('growing','Estágio seguinte, sem contagem por frames')]:
        html.append(f'<figure><img loading="lazy" src="captures/g11_{res}_{name}.png"><figcaption>{label}</figcaption></figure>')
    html.append('</section>')
html.append('</html>')
(out/'index.html').write_text('\n'.join(html),encoding='utf-8')
print('Gallery: '+str(out/'index.html'))
