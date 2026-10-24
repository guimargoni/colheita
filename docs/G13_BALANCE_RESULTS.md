# G1.3 — resultados reproduzíveis de balanceamento

Dados provisórios. Simulação determinística executada no serviço GDScript real,
não comportamento observado de jogadores. Seed RNG `24102026`.

## Economia de uma colheita sem cuidado

Por canteiro, em tempo normal; compra de uma semente, venda manual de toda a
produção. Rendimento horário teórico supõe reposição e coleta instantâneas 24h;
não representa o ganho de um jogador com sessões limitadas.

| Cultura | Nível | Semente | Tempo s | Produção | Venda/un | Lucro | Moedas/h | XP/colheita | XP/h | Ciclos/h |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Cenoura | 1 | 2 | 120 | 2 | 3 | 4 | 120.00 | 1 | 30.00 | 30.00 |
| Morango | 2 | 5 | 900 | 3 | 5 | 10 | 40.00 | 4 | 16.00 | 4.00 |
| Trigo | 3 | 8 | 7200 | 4 | 8 | 24 | 12.00 | 12 | 6.00 | 0.50 |

## Três dias com orçamento diário de atenção

Quatro canteiros existentes. Uma sessão/dia, decisões por minuto. Prioriza a
cultura indicada após seu desbloqueio; antes disso usa cenoura. Compra uma
semente quando falta, planta, colhe, vende os produtos e reinveste. Sem
compras reais, restock, coleta automática durante ausência ou sementes infinitas.
Cuidado: rega ao plantar e remoção dos incômodos vistos. Finito: o mesmo,
mais até oito comuns iniciais, uma aplicação por plantio enquanto houver.
Cada comando bem-sucedido é uma ação; venda de cesta conta uma ação.

| Min/dia | Preferência | Cuidado | Colheitas | Saldo final | Variação de moedas | XP | Nível | Ações |
|---:|---|---|---:|---:|---:|---:|---:|---:|
| 5 | crop.carrot | none | 24 | 136 | 96 | 24 | 2 | 87 |
| 5 | crop.carrot | care | 32 | 168 | 128 | 32 | 3 | 154 |
| 5 | crop.carrot | finite_common | 32 | 168 | 128 | 32 | 3 | 162 |
| 5 | crop.strawberry | none | 15 | 112 | 72 | 27 | 2 | 55 |
| 5 | crop.strawberry | care | 16 | 122 | 82 | 31 | 2 | 85 |
| 5 | crop.strawberry | finite_common | 16 | 122 | 82 | 31 | 2 | 93 |
| 5 | crop.wheat | none | 24 | 136 | 96 | 24 | 2 | 87 |
| 5 | crop.wheat | care | 32 | 162 | 122 | 32 | 3 | 154 |
| 5 | crop.wheat | finite_common | 32 | 162 | 122 | 32 | 3 | 162 |
| 20 | crop.carrot | none | 101 | 444 | 404 | 101 | 4 | 355 |
| 20 | crop.carrot | care | 116 | 504 | 464 | 116 | 4 | 544 |
| 20 | crop.carrot | finite_common | 116 | 504 | 464 | 116 | 4 | 552 |
| 20 | crop.strawberry | none | 27 | 232 | 192 | 75 | 3 | 96 |
| 20 | crop.strawberry | care | 28 | 242 | 202 | 79 | 3 | 139 |
| 20 | crop.strawberry | finite_common | 28 | 242 | 202 | 79 | 3 | 147 |
| 20 | crop.wheat | none | 40 | 276 | 236 | 95 | 4 | 139 |
| 20 | crop.wheat | care | 43 | 348 | 308 | 131 | 4 | 204 |
| 20 | crop.wheat | finite_common | 43 | 348 | 308 | 131 | 4 | 212 |
| 60 | crop.carrot | none | 302 | 1248 | 1208 | 302 | 5 | 1063 |
| 60 | crop.carrot | care | 356 | 1464 | 1424 | 356 | 5 | 1681 |
| 60 | crop.carrot | finite_common | 356 | 1464 | 1424 | 356 | 5 | 1689 |
| 60 | crop.strawberry | none | 55 | 512 | 472 | 187 | 5 | 198 |
| 60 | crop.strawberry | care | 55 | 512 | 472 | 187 | 5 | 267 |
| 60 | crop.strawberry | finite_common | 55 | 512 | 472 | 187 | 5 | 275 |
| 60 | crop.wheat | none | 43 | 348 | 308 | 131 | 4 | 150 |
| 60 | crop.wheat | care | 43 | 348 | 308 | 131 | 4 | 209 |
| 60 | crop.wheat | finite_common | 43 | 348 | 308 | 131 | 4 | 217 |

## Tempo até os níveis

Minutos ativos e horas corridas desde o primeiro plantio; sem confundir
tempo conectado com tempo de calendário. Não atingido em três dias = —.

| Min/dia | Preferência | Cuidado | Nível 2 (ativo min / corrido h) | Nível 3 | Nível 4 | Nível 5 |
|---:|---|---|---|---|---|---|
| 5 | crop.carrot | none | 5 / 24.00 | — | — | — |
| 5 | crop.carrot | care | 4 / 0.07 | 14 / 48.07 | — | — |
| 5 | crop.carrot | finite_common | 4 / 0.07 | 14 / 48.07 | — | — |
| 5 | crop.strawberry | none | 5 / 24.00 | — | — | — |
| 5 | crop.strawberry | care | 4 / 0.07 | — | — | — |
| 5 | crop.strawberry | finite_common | 4 / 0.07 | — | — | — |
| 5 | crop.wheat | none | 5 / 24.00 | — | — | — |
| 5 | crop.wheat | care | 4 / 0.07 | 14 / 48.07 | — | — |
| 5 | crop.wheat | finite_common | 4 / 0.07 | 14 / 48.07 | — | — |
| 20 | crop.carrot | none | 6 / 0.10 | 19 / 0.32 | 46 / 48.10 | — |
| 20 | crop.carrot | care | 4 / 0.07 | 16 / 0.27 | 40 / 48.00 | — |
| 20 | crop.carrot | finite_common | 4 / 0.07 | 16 / 0.27 | 40 / 48.00 | — |
| 20 | crop.strawberry | none | 6 / 0.10 | 36 / 24.27 | — | — |
| 20 | crop.strawberry | care | 4 / 0.07 | 35 / 24.25 | — | — |
| 20 | crop.strawberry | finite_common | 4 / 0.07 | 35 / 24.25 | — | — |
| 20 | crop.wheat | none | 6 / 0.10 | 19 / 0.32 | 40 / 48.00 | — |
| 20 | crop.wheat | care | 4 / 0.07 | 16 / 0.27 | 20 / 24.00 | — |
| 20 | crop.wheat | finite_common | 4 / 0.07 | 16 / 0.27 | 20 / 24.00 | — |
| 60 | crop.carrot | none | 6 / 0.10 | 19 / 0.32 | 48 / 0.80 | 106 / 24.77 |
| 60 | crop.carrot | care | 4 / 0.07 | 16 / 0.27 | 40 / 0.67 | 90 / 24.50 |
| 60 | crop.carrot | finite_common | 4 / 0.07 | 16 / 0.27 | 40 / 0.67 | 90 / 24.50 |
| 60 | crop.strawberry | none | 6 / 0.10 | 37 / 0.62 | 75 / 24.25 | 167 / 48.78 |
| 60 | crop.strawberry | care | 4 / 0.07 | 36 / 0.60 | 75 / 24.25 | 165 / 48.75 |
| 60 | crop.strawberry | finite_common | 4 / 0.07 | 36 / 0.60 | 75 / 24.25 | 165 / 48.75 |
| 60 | crop.wheat | none | 6 / 0.10 | 19 / 0.32 | 60 / 24.00 | — |
| 60 | crop.wheat | care | 4 / 0.07 | 16 / 0.27 | 60 / 24.00 | — |
| 60 | crop.wheat | finite_common | 4 / 0.07 | 16 / 0.27 | 60 / 24.00 | — |

Interpretação, hipóteses, efeitos de cuidados e limitações em
[G13_BALANCE.md](G13_BALANCE.md). JSON bruto ignorado em `.local/g13/balance.json`.
