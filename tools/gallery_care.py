"""Actual care scene captures; no retouching or synthetic mockups."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
out = ROOT/'.local/g12'
html = ['''<!doctype html><html lang="pt-BR"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>G1.2 — Cuidados</title><style>body{font:18px system-ui;background:#fff2d5;color:#203d4a;margin:24px}section{display:flex;gap:16px;flex-wrap:wrap}figure{margin:0;max-width:48%}img{max-width:100%;max-height:85vh}h2{margin-top:40px}</style><h1>G1.2 — Cuidados</h1><p>Capturas reais do Godot; imagens nao interativas. Para JOGAR, execute JOGAR_G12_TESTE.cmd na raiz do repositorio ou abra farm/g12/farm.tscn e pressione F6.</p><p>Relogio controlado e fixture isolada: nao altera saves do jogador. Sprites e FX em revisao; audio final ausente.</p>''']
for res in ['1920x1080','1080x1920']:
    html.append(f'<h2>{res}</h2><section>')
    for name,label in [('farm','Culturas, ervas e pragas'),('context','Indicador contextual de crescimento'),('tools','Ferramentas e fertilizantes'),('water','Rega e hidratacao'),('pests_removed','Pragas removidas'),('weeds_removed','Ervas removidas'),('fertilized','Tempo reduzido com fertilizante'),('stock_after','Estoque atualizado'),('harvest','Colheita direta preservada')]:
        html.append(f'<figure><img loading="lazy" src="captures/g12_{res}_{name}.png"><figcaption>{label}</figcaption></figure>')
    html.append('</section>')
html.append('</html>')
(out/'index.html').write_text('\n'.join(html),encoding='utf-8')
print('Gallery: '+str(out/'index.html'))
