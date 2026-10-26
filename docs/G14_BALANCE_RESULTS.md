# G1.4 — resultados reproduzíveis da expansão

12 simulações do serviço GDScript real, seed RNG `24102026`, três dias.
Não são observações de jogadores ou números históricos. Hipóteses e análise
em [G14_BALANCE.md](G14_BALANCE.md).

| Min/dia | Cuidados | Expande? | Terrenos abertos | Saldo | XP | Colheitas | Ações | Moedas em terrenos | Colheitas iniciais |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|
| 5 | none | sim | 6 | 18 | 43 | 31 | 114 | 130 | 83.9% |
| 5 | care | sim | 7 | 0 | 111 | 41 | 196 | 310 | 78.0% |
| 5 | finite_common | sim | 7 | 0 | 111 | 41 | 204 | 310 | 78.0% |
| 5 | care | controle sem expansão | 4 | 248 | 88 | 32 | 154 | 0 | 100.0% |
| 20 | none | sim | 8 | 178 | 251 | 163 | 559 | 630 | 63.8% |
| 20 | care | sim | 8 | 386 | 336 | 193 | 896 | 630 | 60.1% |
| 20 | finite_common | sim | 8 | 386 | 336 | 193 | 904 | 630 | 60.1% |
| 20 | care | controle sem expansão | 4 | 640 | 204 | 116 | 540 | 0 | 100.0% |
| 60 | none | sim | 8 | 1818 | 694 | 551 | 1838 | 630 | 54.6% |
| 60 | care | sim | 8 | 2286 | 823 | 658 | 3032 | 630 | 54.1% |
| 60 | finite_common | sim | 8 | 2286 | 823 | 658 | 3040 | 630 | 54.1% |
| 60 | care | controle sem expansão | 4 | 1600 | 444 | 356 | 1675 | 0 | 100.0% |

## Tempo e esforço até cada compra

Tempo ativo é cumulativo entre sessões. Horas corridas incluem ausência.
Colheitas = total até a compra, não apenas custo marginal do terreno.
Não atingido em três dias aparece como —; não estimar um dia inexistente.

| Min/dia | Cuidado | Terreno | Preço | Ativo min | Corrido h | Colheitas até compra | XP | Saldo após |
|---:|---|---|---:|---:|---:|---:|---:|---:|
| 5 | none | 5 | 40 | 5 | 24.000 | 9 | 9 | 44 |
| 5 | none | 6 | 90 | 10 | 48.000 | 20 | 32 | 22 |
| 5 | none | 7 | — | — | — | — | — | — |
| 5 | none | 8 | — | — | — | — | — | — |
| 5 | care | 5 | 40 | 4 | 0.067 | 8 | 8 | 40 |
| 5 | care | 6 | 90 | 7 | 24.033 | 18 | 33 | 20 |
| 5 | care | 7 | 180 | 14 | 48.067 | 41 | 111 | 32 |
| 5 | care | 8 | — | — | — | — | — | — |
| 5 | finite_common | 5 | 40 | 4 | 0.067 | 8 | 8 | 40 |
| 5 | finite_common | 6 | 90 | 7 | 24.033 | 18 | 33 | 20 |
| 5 | finite_common | 7 | 180 | 14 | 48.067 | 41 | 111 | 32 |
| 5 | finite_common | 8 | — | — | — | — | — | — |
| 20 | none | 5 | 40 | 6 | 0.100 | 9 | 9 | 40 |
| 20 | none | 6 | 90 | 17 | 0.283 | 33 | 33 | 48 |
| 20 | none | 7 | 180 | 26 | 24.100 | 56 | 89 | 16 |
| 20 | none | 8 | 320 | 44 | 48.067 | 114 | 202 | 30 |
| 20 | care | 5 | 40 | 4 | 0.067 | 8 | 8 | 40 |
| 20 | care | 6 | 90 | 14 | 0.233 | 33 | 33 | 50 |
| 20 | care | 7 | 180 | 20 | 24.000 | 51 | 117 | 62 |
| 20 | care | 8 | 320 | 40 | 48.000 | 121 | 264 | 162 |
| 20 | finite_common | 5 | 40 | 4 | 0.067 | 8 | 8 | 40 |
| 20 | finite_common | 6 | 90 | 14 | 0.233 | 33 | 33 | 50 |
| 20 | finite_common | 7 | 180 | 20 | 24.000 | 51 | 117 | 62 |
| 20 | finite_common | 8 | 320 | 40 | 48.000 | 121 | 264 | 162 |
| 60 | none | 5 | 40 | 6 | 0.100 | 9 | 9 | 40 |
| 60 | none | 6 | 90 | 17 | 0.283 | 33 | 33 | 48 |
| 60 | none | 7 | 180 | 36 | 0.600 | 81 | 81 | 56 |
| 60 | none | 8 | 320 | 60 | 24.000 | 157 | 234 | 186 |
| 60 | care | 5 | 40 | 4 | 0.067 | 8 | 8 | 40 |
| 60 | care | 6 | 90 | 14 | 0.233 | 33 | 33 | 50 |
| 60 | care | 7 | 180 | 30 | 0.500 | 81 | 81 | 62 |
| 60 | care | 8 | 320 | 60 | 24.000 | 186 | 263 | 302 |
| 60 | finite_common | 5 | 40 | 4 | 0.067 | 8 | 8 | 40 |
| 60 | finite_common | 6 | 90 | 14 | 0.233 | 33 | 33 | 50 |
| 60 | finite_common | 7 | 180 | 30 | 0.500 | 81 | 81 | 62 |
| 60 | finite_common | 8 | 320 | 60 | 24.000 | 186 | 263 | 302 |

## Evolução diária (cuidado sem itens)

| Min/dia | Expande? | Dia | Terrenos | Saldo | XP | Nível |
|---:|---|---:|---:|---:|---:|---:|
| 5 | sim | 1 | 5 | 15 | 8 | 2 |
| 5 | sim | 2 | 6 | 4 | 39 | 3 |
| 5 | sim | 3 | 7 | 0 | 111 | 4 |
| 5 | não | 1 | 4 | 60 | 8 | 2 |
| 5 | não | 2 | 4 | 120 | 32 | 3 |
| 5 | não | 3 | 4 | 248 | 88 | 4 |
| 20 | sim | 1 | 6 | 50 | 45 | 3 |
| 20 | sim | 2 | 7 | 258 | 180 | 5 |
| 20 | sim | 3 | 8 | 386 | 336 | 5 |
| 20 | não | 1 | 4 | 160 | 36 | 3 |
| 20 | não | 2 | 4 | 400 | 120 | 4 |
| 20 | não | 3 | 4 | 640 | 204 | 5 |
| 60 | sim | 1 | 7 | 398 | 179 | 4 |
| 60 | sim | 2 | 8 | 1166 | 495 | 6 |
| 60 | sim | 3 | 8 | 2286 | 823 | 6 |
| 60 | não | 1 | 4 | 480 | 116 | 4 |
| 60 | não | 2 | 4 | 1040 | 280 | 5 |
| 60 | não | 3 | 4 | 1600 | 444 | 6 |

O saldo não inclui valor dos cultivos em andamento nem propriedade adquirida.
Um saldo zero pode coexistir com plantas que amadurecerão; não implica falência.
JSON bruto ignorado em `.local/g14/balance.json`.
