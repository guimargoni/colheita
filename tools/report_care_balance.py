"""Publish a reproducible Markdown snapshot of the Godot simulation results."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
data = json.loads((ROOT/'.local/g12/balance.json').read_text(encoding='utf-8'))
names = {'no_care':'Sem cuidados','care_only':'Cuidados sem fertilizante','care_and_finite_common':'Cuidados + 8 comuns DEV finitos'}
lines = ['# G1.2 — resultados da simulação', '',
         'Gerado por `tools/report_care_balance.py` a partir da simulação Godot com as regras reais.',
         'Hipóteses, limitações e parâmetros em `G12_BALANCE.md`. Não são dados de jogadores.', '',
         '| Min/dia | Estratégia | Colheitas | Produtos cenoura / morango / trigo | Ações de cuidado | Comuns usados | Segundos recuperados |',
         '|---|---|---|---|---|---|---|']
for row in data['results']:
    counts = ' / '.join(str(int(row['products'].get(key,0))) for key in ['crop.carrot','crop.strawberry','crop.wheat'])
    lines.append(f"| {row['minutes_per_day']} | {names[row['strategy']]} | {row['harvests']} | {counts} | {row['care_actions']} | {row['common_used']} | {row['time_saved_seconds']} |")
lines += ['', 'Janela: 3 dias; uma sessão diária por perfil; decisões a cada 60 segundos;',
          'um canteiro de cada cultura; seed RNG 24102026. Sementes abundantes na fixture',
          'de simulação (não no jogo). Sem moedas, preço, venda, tempo de animação ou',
          'custo de clique modelados. Cultivos maduros fora das sessões não são auto-colhidos.', '']
(ROOT/'docs/G12_BALANCE_RESULTS.md').write_text('\n'.join(lines),encoding='utf-8')
print('Balance report: docs/G12_BALANCE_RESULTS.md')
