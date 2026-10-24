"""Report deterministic Godot service results, never fabricate simulation rows."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
data = json.loads((ROOT / '.local/g13/balance.json').read_text(encoding='utf-8'))
config = json.loads((ROOT / 'game/data/farming/g13/economy.json').read_text(encoding='utf-8'))
crops = json.loads((ROOT / 'game/data/farming/crops.json').read_text(encoding='utf-8'))['crops']
lines = ['# G1.3 — resultados reproduzíveis de balanceamento', '',
         'Dados provisórios. Simulação determinística executada no serviço GDScript real,',
         'não comportamento observado de jogadores. Seed RNG `24102026`.', '',
         '## Economia de uma colheita sem cuidado', '',
         'Por canteiro, em tempo normal; compra de uma semente, venda manual de toda a',
         'produção. Rendimento horário teórico supõe reposição e coleta instantâneas 24h;',
         'não representa o ganho de um jogador com sessões limitadas.', '',
         '| Cultura | Nível | Semente | Tempo s | Produção | Venda/un | Lucro | Moedas/h | XP/colheita | XP/h | Ciclos/h |',
         '|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|']
for crop in crops:
    row = config['crops'][crop['id']]
    profit = crop['yield_quantity'] * row['sell_value'] - row['seed_price']
    cycles = 3600 / crop['growth_seconds']
    lines.append(f"| {crop['name']} | {row['unlock_level']} | {row['seed_price']} | {crop['growth_seconds']} | {crop['yield_quantity']} | {row['sell_value']} | {profit} | {profit*cycles:.2f} | {row['harvest_xp']} | {row['harvest_xp']*cycles:.2f} | {cycles:.2f} |")
lines += ['', '## Três dias com orçamento diário de atenção', '',
          'Quatro canteiros existentes. Uma sessão/dia, decisões por minuto. Prioriza a',
          'cultura indicada após seu desbloqueio; antes disso usa cenoura. Compra uma',
          'semente quando falta, planta, colhe, vende os produtos e reinveste. Sem',
          'compras reais, restock, coleta automática durante ausência ou sementes infinitas.',
          'Cuidado: rega ao plantar e remoção dos incômodos vistos. Finito: o mesmo,',
          'mais até oito comuns iniciais, uma aplicação por plantio enquanto houver.',
          'Cada comando bem-sucedido é uma ação; venda de cesta conta uma ação.', '',
          '| Min/dia | Preferência | Cuidado | Colheitas | Saldo final | Variação de moedas | XP | Nível | Ações |',
          '|---:|---|---|---:|---:|---:|---:|---:|---:|']
for row in data['rows']:
    lines.append(f"| {row['minutes_per_day']} | {row['preferred_crop']} | {row['care']} | {row['harvests']} | {row['coins']} | {row['coin_change']} | {row['xp']} | {row['level']} | {row['actions']} |")
lines += ['', '## Tempo até os níveis', '',
          'Minutos ativos e horas corridas desde o primeiro plantio; sem confundir',
          'tempo conectado com tempo de calendário. Não atingido em três dias = —.', '',
          '| Min/dia | Preferência | Cuidado | Nível 2 (ativo min / corrido h) | Nível 3 | Nível 4 | Nível 5 |',
          '|---:|---|---|---|---|---|---|']
for row in data['rows']:
    cells = []
    for level in range(2, 6):
        value = row['level_times'].get(str(level))
        cells.append(f"{value['active_minutes']} / {value['elapsed_seconds']/3600:.2f}" if value else '—')
    lines.append(f"| {row['minutes_per_day']} | {row['preferred_crop']} | {row['care']} | " + ' | '.join(cells) + ' |')
lines += ['', 'Interpretação, hipóteses, efeitos de cuidados e limitações em',
          '[G13_BALANCE.md](G13_BALANCE.md). JSON bruto ignorado em `.local/g13/balance.json`.', '']
(ROOT / 'docs/G13_BALANCE_RESULTS.md').write_text('\n'.join(lines), encoding='utf-8')
print('G1.3 balance report: 27 real-service scenarios + analytical per-crop metrics')
