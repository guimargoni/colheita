# G1.5 — resultados reproduzíveis de culturas

30 cenários de serviço real, seed RNG 151026, três dias. Não são jogadores
observados. Mesma base conquistada de 32 XP/176 moedas/quatro canteiros;
o custo da preparação não integra os resultados abaixo.

## Ciclo completo teórico, sem incômodos/cuidados/pausas

| Cultura | Semente | Primeiro s | Recuperação s | Colheitas | Produção/colheita | Venda/un | Lucro completo | ROI | XP total | Moedas/h |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Cenoura | 2 | 120 | 0 | 1 | 2 | 3 | 4 | 200% | 1 | 120.0 |
| Morango | 5 | 900 | 0 | 1 | 3 | 5 | 10 | 200% | 4 | 40.0 |
| Trigo | 8 | 7200 | 0 | 1 | 4 | 8 | 24 | 300% | 12 | 12.0 |
| Feijão | 12 | 600 | 300 | 3 | 3 | 4 | 24 | 200% | 9 | 72.0 |
| Rosa vermelha | 6 | 1200 | 0 | 1 | 3 | 5 | 9 | 150% | 4 | 27.0 |
| Abóbora Amaldiçoada | 10 | 3600 | 0 | 1 | 2 | 12 | 14 | 140% | 7 | 14.0 |

## Sessões diárias reais do simulador

Cuidado inclui rega/limpeza e até oito comuns finitos; sem restock.
Especial esgotada passa a trigo. Sem expansão ou coleta durante ausência.
Variação de caixa não inclui sementes/cultivos remanescentes e não equivale
ao lucro completo da tabela teórica. Ver G15_BALANCE.md.

| Min/dia | Preferência | Cuidados + finitos | Caixa final | Caixa/dia (variação média) | XP ganho | Colheitas | Ações | Sementes gastas (moedas) | Vendas (moedas) |
|---:|---|---|---:|---:|---:|---:|---:|---:|---:|
| 5 | crop.carrot | não | 264 | 29.33 | 24 | 24 | 89 | 56 | 144 |
| 5 | crop.carrot | sim | 296 | 40.00 | 32 | 32 | 166 | 72 | 192 |
| 5 | crop.wheat | não | 336 | 53.33 | 96 | 8 | 34 | 96 | 256 |
| 5 | crop.wheat | sim | 336 | 53.33 | 96 | 8 | 54 | 96 | 256 |
| 5 | crop.bean | não | 224 | 16.00 | 24 | 8 | 18 | 48 | 96 |
| 5 | crop.bean | sim | 224 | 16.00 | 24 | 8 | 41 | 48 | 96 |
| 5 | crop.rose | não | 224 | 16.00 | 32 | 8 | 34 | 72 | 120 |
| 5 | crop.rose | sim | 224 | 16.00 | 32 | 8 | 56 | 72 | 120 |
| 5 | crop.haunted_pumpkin | não | 256 | 26.67 | 56 | 8 | 34 | 112 | 192 |
| 5 | crop.haunted_pumpkin | sim | 256 | 26.67 | 56 | 8 | 54 | 112 | 192 |
| 20 | crop.carrot | não | 568 | 130.67 | 100 | 100 | 360 | 208 | 600 |
| 20 | crop.carrot | sim | 632 | 152.00 | 116 | 116 | 567 | 240 | 696 |
| 20 | crop.wheat | não | 336 | 53.33 | 96 | 8 | 34 | 96 | 256 |
| 20 | crop.wheat | sim | 336 | 53.33 | 96 | 8 | 54 | 96 | 256 |
| 20 | crop.bean | não | 416 | 80.00 | 96 | 32 | 71 | 144 | 384 |
| 20 | crop.bean | sim | 416 | 80.00 | 108 | 36 | 140 | 192 | 432 |
| 20 | crop.rose | não | 224 | 16.00 | 32 | 8 | 34 | 72 | 120 |
| 20 | crop.rose | sim | 332 | 52.00 | 80 | 20 | 110 | 144 | 300 |
| 20 | crop.haunted_pumpkin | não | 256 | 26.67 | 56 | 8 | 34 | 112 | 192 |
| 20 | crop.haunted_pumpkin | sim | 256 | 26.67 | 56 | 8 | 56 | 112 | 192 |
| 60 | crop.carrot | não | 1380 | 401.33 | 303 | 303 | 1075 | 614 | 1818 |
| 60 | crop.carrot | sim | 1592 | 472.00 | 356 | 356 | 1678 | 720 | 2136 |
| 60 | crop.wheat | não | 336 | 53.33 | 96 | 8 | 34 | 96 | 256 |
| 60 | crop.wheat | sim | 336 | 53.33 | 96 | 8 | 57 | 96 | 256 |
| 60 | crop.bean | não | 956 | 260.00 | 303 | 101 | 239 | 432 | 1212 |
| 60 | crop.bean | sim | 992 | 272.00 | 324 | 108 | 380 | 480 | 1296 |
| 60 | crop.rose | não | 440 | 88.00 | 128 | 32 | 119 | 216 | 480 |
| 60 | crop.rose | sim | 548 | 124.00 | 176 | 44 | 224 | 288 | 660 |
| 60 | crop.haunted_pumpkin | não | 256 | 26.67 | 56 | 8 | 34 | 112 | 192 |
| 60 | crop.haunted_pumpkin | sim | 352 | 58.67 | 104 | 12 | 75 | 144 | 320 |

## Caixa ao final de cada dia (sem cuidados)

| Min/dia | Preferência | Dia 1 | Dia 2 | Dia 3 |
|---:|---|---:|---:|---:|
| 5 | crop.carrot | 192 | 224 | 264 |
| 5 | crop.wheat | 144 | 240 | 336 |
| 5 | crop.bean | 128 | 176 | 224 |
| 5 | crop.rose | 152 | 188 | 224 |
| 5 | crop.haunted_pumpkin | 136 | 192 | 256 |
| 20 | crop.carrot | 296 | 432 | 568 |
| 20 | crop.wheat | 144 | 240 | 336 |
| 20 | crop.bean | 224 | 320 | 416 |
| 20 | crop.rose | 152 | 188 | 224 |
| 20 | crop.haunted_pumpkin | 136 | 192 | 256 |
| 60 | crop.carrot | 556 | 968 | 1380 |
| 60 | crop.wheat | 144 | 240 | 336 |
| 60 | crop.bean | 416 | 692 | 956 |
| 60 | crop.rose | 224 | 332 | 440 |
| 60 | crop.haunted_pumpkin | 136 | 192 | 256 |

Dados brutos: `.local/g15/balance.json` (ignorado). Valores provisórios.
