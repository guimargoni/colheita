"""Render actual Godot expansion simulations; provisional economics only."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
data = json.loads((ROOT / '.local/g14/balance.json').read_text(encoding='utf-8'))
lines = ['# G1.4 — resultados reproduzíveis da expansão', '',
         '12 simulações do serviço GDScript real, seed RNG `24102026`, três dias.',
         'Não são observações de jogadores ou números históricos. Hipóteses e análise',
         'em [G14_BALANCE.md](G14_BALANCE.md).', '',
         '| Min/dia | Cuidados | Expande? | Terrenos abertos | Saldo | XP | Colheitas | Ações | Moedas em terrenos | Colheitas iniciais |',
         '|---:|---|---|---:|---:|---:|---:|---:|---:|---:|']
for row in data['rows']:
    lines.append(f"| {row['minutes_per_day']} | {row['care']} | {'sim' if row['expansion_enabled'] else 'controle sem expansão'} | {row['open_plots']} | {row['coins']} | {row['xp']} | {row['harvests']} | {row['actions']} | {row['land_spend']} | {row['home_share']*100:.1f}% |")
lines += ['', '## Tempo e esforço até cada compra', '',
          'Tempo ativo é cumulativo entre sessões. Horas corridas incluem ausência.',
          'Colheitas = total até a compra, não apenas custo marginal do terreno.',
          'Não atingido em três dias aparece como —; não estimar um dia inexistente.', '',
          '| Min/dia | Cuidado | Terreno | Preço | Ativo min | Corrido h | Colheitas até compra | XP | Saldo após |',
          '|---:|---|---|---:|---:|---:|---:|---:|---:|']
for row in data['rows']:
    if not row['expansion_enabled']:
        continue
    by_id = {purchase['id']: purchase for purchase in row['purchases']}
    for i in range(1, 5):
        purchase = by_id.get(f'plot.expand.{i}')
        if purchase:
            lines.append(f"| {row['minutes_per_day']} | {row['care']} | {i+4} | {purchase['price']} | {purchase['active_minutes']} | {purchase['elapsed_hours']:.3f} | {purchase['harvests_so_far']} | {purchase['xp']} | {purchase['balance_after']} |")
        else:
            lines.append(f"| {row['minutes_per_day']} | {row['care']} | {i+4} | — | — | — | — | — | — |")
lines += ['', '## Evolução diária (cuidado sem itens)', '',
          '| Min/dia | Expande? | Dia | Terrenos | Saldo | XP | Nível |',
          '|---:|---|---:|---:|---:|---:|---:|']
for row in data['rows']:
    if row['care'] != 'care':
        continue
    for day in row['daily']:
        lines.append(f"| {row['minutes_per_day']} | {'sim' if row['expansion_enabled'] else 'não'} | {day['day']} | {day['open_plots']} | {day['coins']} | {day['xp']} | {day['level']} |")
lines += ['', 'O saldo não inclui valor dos cultivos em andamento nem propriedade adquirida.',
          'Um saldo zero pode coexistir com plantas que amadurecerão; não implica falência.',
          'JSON bruto ignorado em `.local/g14/balance.json`.', '']
(ROOT / 'docs/G14_BALANCE_RESULTS.md').write_text('\n'.join(lines), encoding='utf-8')
print('G1.4 balance report: 12 actual-service scenarios')
