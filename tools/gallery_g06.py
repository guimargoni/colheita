"""Local gallery of unretouched GPU frames; no image processing/dependencies."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
out = ROOT/'.local/g06'
html = ['''<!doctype html><html lang="pt-BR"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Fazenda Viva · G0.6</title>
<style>body{background:#fff2d5;color:#203d4a;font:18px system-ui;margin:24px}section{display:flex;gap:16px;flex-wrap:wrap}figure{margin:0;max-width:48%;min-width:280px}img{max-width:100%;max-height:85vh}button,a{font:inherit;color:inherit}button{padding:12px;background:#f2c34e;border:2px solid #203d4a;border-radius:8px}h2{margin-top:40px}figcaption{padding:8px}aside{max-width:900px}</style>
<h1>Cozy Pixel Art · Fazenda Viva — G0.6</h1><aside>Capturas reais do Godot, sem retoque. Direção conceitual aprovada; acabamento artístico pendente. Quatro canteiros de amostra, sem economia/progressão. Os botões abaixo alternam desenhos capturados; não representam vídeo nem teste em celular físico.</aside>''']
for res in ['1920x1080','1080x1920']:
    prefix = f'captures/g06_{res}_'
    html.append(f'<h2>{res} — antes / depois</h2><section>')
    for name, label in [('before','Antes · v2 preservada'),('farm','Depois · G0.6')]:
        html.append(f'<figure><img loading="lazy" src="{prefix}{name}.png"><figcaption>{label}</figcaption></figure>')
    html.append('</section><h3>Aproximações reais de câmera</h3><section>')
    for name,label in [('house','Casa e entrada'),('plots','Canteiros após a colheita de demonstração'),('animal','Galinha — escala estilizada')]:
        html.append(f'<figure><img loading="lazy" src="{prefix}{name}.png"><figcaption>{label}</figcaption></figure>')
    html.append(f'</section><h3>Colheita — desenhos amostrados em 40 / 180 / 360 ms</h3><button onclick="play(this,\'{res}\')">Reproduzir sequência de capturas</button><p><img id="fx{res}" src="{prefix}harvest_01.png"></p>')
    html.append(f'<details><summary>Menu e estados</summary><img loading="lazy" src="{prefix}studio.png"></details>')
html.append('''<h2>Idle — poses desenhadas, sem deformação por escala</h2><button onclick="idle(this)">Reproduzir poses da galinha</button><p><img id="idle" src="captures/g06_1920x1080_idle_01.png"></p>
<script>let timers=[];function play(b,r){b.disabled=true;let i=0,times=[140,180,700];function next(){document.getElementById('fx'+r).src='captures/g06_'+r+'_harvest_0'+(i+1)+'.png';if(i<2)setTimeout(next,times[i++]);else setTimeout(()=>b.disabled=false,700)}next()}
function idle(b){b.disabled=true;let i=0;function next(){document.getElementById('idle').src='captures/g06_1920x1080_idle_0'+(i+1)+'.png';if(i<2)setTimeout(next,[2400,120][i++]);else setTimeout(()=>b.disabled=false,550)}next()}</script></html>''')
(out/'index.html').write_text('\n'.join(html),encoding='utf-8')
print('Gallery: '+str(out/'index.html'))
