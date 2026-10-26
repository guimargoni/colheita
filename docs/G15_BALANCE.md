# G1.5 — Análise de balanceamento

Status: provisório, pendente de avaliação humana. Os preços, XP e tempos novos não são reconstruções comprovadas da economia original. Nenhum valor efetivo de G1.4 foi alterado.

## Modelo

O relatório reproduzível [G15_BALANCE_RESULTS.md](G15_BALANCE_RESULTS.md) contém 30 cenários: cinco estratégias, três sessões contínuas de 5/20/60 minutos por dia e duas políticas de cuidado. Horizonte de três dias, quatro terrenos iniciais, sem expansão. Cada cenário começa após conquistar legitimamente 32 XP e 176 moedas. Compras, colheitas e vendas usam o serviço real; a política do simulador vende todos os produtos. O jogo não vende automaticamente.

A segunda política usa cuidados e até oito fertilizantes comuns finitos. Não há reposição gratuita, sementes ou saldo infinito. A estratégia especial respeita o limite de oito sementes e depois usa trigo. Ausência não destrói culturas nem coleta automaticamente; recuperação começa quando o jogador colhe.

## Comparação teórica, sem cuidado

| Cultura | Semente | Lucro do ciclo completo | Duração mínima | ROI | XP total | Moedas líquidas/hora ideal |
|---|---:|---:|---:|---:|---:|---:|
| Cenoura | 2 | 4 | 120 s | 200% | 1 | 120 |
| Morango | 5 | 10 | 900 s | 200% | 4 | 40 |
| Trigo | 8 | 24 | 7200 s | 300% | 12 | 12 |
| Feijão | 12 | 24 | 600 + 300 + 300 s | 200% | 9 | 72 |
| Rosa | 6 | 9 | 1200 s | 150% | 4 | 27 |
| Abóbora especial | 10 | 14 | 3600 s | 140% | 7 | 14 |

O rendimento por hora supõe retornos exatos e é um limite teórico por terreno, não ganho diário garantido. O feijão entrega nove produtos em três colheitas usando uma semente. A abóbora tem disponibilidade e quantidade limitadas.

## Leitura dos resultados

Sem cuidado, a cenoura termina com 264/568/1380 moedas nas sessões de 5/20/60 minutos; o feijão com 224/416/956; o trigo com 336 em todos os perfis. O trigo favorece retornos espaçados; a cenoura exige muito mais atividade. Aos 60 minutos, cenoura e feijão concedem 303 XP, mas exigem respectivamente 1075 e 239 ações na política simulada. O feijão reduz compras e replantios, comprometendo o terreno durante a série e exigindo colheitas para iniciar cada recuperação.

A rosa termina com 224/224/440 moedas sem cuidado; com cuidado e estoque finito, 224/332/548. Flores podem permanecer guardadas para uso futuro; esse valor social ainda não existe e não justifica afirmar equilíbrio definitivo. A especial encerra em 256 moedas sem cuidado; no perfil dedicado com cuidado chega a 352, incluindo quatro colheitas de trigo após oito de abóbora.

Saldo final menos saldo inicial não equivale a lucro contábil completo: podem restar sementes compradas e culturas em produção. Séries incompletas no horizonte penalizam aparentemente o feijão. Dividir ganhos por três informa média diária deste cenário, sem prometer renda universal.

## Pendências

A cenoura continua sendo a melhor fonte ativa de moedas nas hipóteses testadas; não alteramos G1.4 para esconder isso. As alternativas oferecem menor frequência de retorno, rendimento por semente, XP e coleção floral. Antes de balanceamento final, medir sessões reais, intervalos fragmentados, custos de oportunidade, utilidade futura das flores e efeito de mais terrenos. Não declarar ausência de estratégia dominante global com esta amostra limitada.
