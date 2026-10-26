"""Report observed deterministic service runs, distinct from theoretical ROI."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
data = json.loads((ROOT / '.local/g15/balance.json').read_text(encoding='utf-8'))
crops = json.loads((ROOT / 'game/data/farming/g15/crops.json').read_text(encoding='utf-8'))['crops']
economy = json.loads((ROOT / 'game/data/farming/g15/economy.json').read_text(encoding='utf-8'))
lines = ['# G1.5 — resultados reproduzíveis de culturas', '',
         '30 cenários de serviço real, seed RNG 151026, três dias. Não são jogadores',
         'observados. Mesma base conquistada de 32 XP/176 moedas/quatro canteiros;',
         'o custo da preparação não integra os resultados abaixo.', '',
         '## Ciclo completo teórico, sem incômodos/cuidados/pausas', '',
         '| Cultura | Semente | Primeiro s | Recuperação s | Colheitas | Produção/colheita | Venda/un | Lucro completo | ROI | XP total | Moedas/h |',
         '|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|']
for crop in crops:
    rule = economy['crops'][crop['id']]
    count = crop['harvest_count']
    duration = crop['growth_seconds'] + (count-1)*crop['regrowth_seconds']
    profit = count*crop['yield_quantity']*rule['sell_value']-rule['seed_price']
    roi = profit / rule['seed_price']*100
    lines.append(f"| {crop['name']} | {rule['seed_price']} | {crop['growth_seconds']} | {crop['regrowth_seconds']} | {count} | {crop['yield_quantity']} | {rule['sell_value']} | {profit} | {roi:.0f}% | {count*rule['harvest_xp']} | {profit*3600/duration:.1f} |")
lines += ['', '## Sessões diárias reais do simulador', '',
          'Cuidado inclui rega/limpeza e até oito comuns finitos; sem restock.',
          'Especial esgotada passa a trigo. Sem expansão ou coleta durante ausência.',
          'Variação de caixa não inclui sementes/cultivos remanescentes e não equivale',
          'ao lucro completo da tabela teórica. Ver G15_BALANCE.md.', '',
          '| Min/dia | Preferência | Cuidados + finitos | Caixa final | Caixa/dia (variação média) | XP ganho | Colheitas | Ações | Sementes gastas (moedas) | Vendas (moedas) |',
          '|---:|---|---|---:|---:|---:|---:|---:|---:|---:|']
for row in data['rows']:
    lines.append(f"| {row['minutes_per_day']} | {row['preferred']} | {'sim' if row['care_and_finite_common'] else 'não'} | {row['final_coins']} | {row['coins_per_day']:.2f} | {row['xp_earned']} | {row['harvests']} | {row['actions']} | {row['seed_spend']} | {row['sales']} |")
lines += ['', '## Caixa ao final de cada dia (sem cuidados)', '',
          '| Min/dia | Preferência | Dia 1 | Dia 2 | Dia 3 |',
          '|---:|---|---:|---:|---:|']
for row in data['rows']:
    if not row['care_and_finite_common']:
        lines.append(f"| {row['minutes_per_day']} | {row['preferred']} | " + ' | '.join(str(day['coins']) for day in row['daily']) + ' |')
lines += ['', 'Dados brutos: `.local/g15/balance.json` (ignorado). Valores provisórios.', '']
(ROOT / 'docs/G15_BALANCE_RESULTS.md').write_text('\n'.join(lines), encoding='utf-8')
print('G1.5: report generated from 30 actual-service rows')
