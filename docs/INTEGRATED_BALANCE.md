# Economia integrada — simulação provisória

Execução real de `game/tests/simulate_integrated.gd`: 12 casos, três dias, sessões de 5/20/60 minutos por dia, quatro canteiros iniciais, 40 moedas e quatro sementes de cenoura. Passo de um minuto com observação também no fim da sessão; sem expansão, sem doações e sem presentes. Cada estado final foi serializado/revalidado. Não altera saves de jogador.

| Min/dia | Estratégia | Moedas finais | XP total | Nível | Produtores | Ações |
|---:|---|---:|---:|---:|---:|---:|
| 5 | carrot | 160 | 32 | 3 | 0 | 145 |
| 5 | wheat | 154 | 32 | 3 | 0 | 145 |
| 5 | diverse | 145 | 31 | 2 | 0 | 130 |
| 5 | producers | 47 | 40 | 3 | 2 | 163 |
| 20 | carrot | 544 | 128 | 4 | 0 | 553 |
| 20 | wheat | 340 | 131 | 4 | 0 | 192 |
| 20 | diverse | 372 | 110 | 4 | 0 | 320 |
| 20 | producers | 289 | 187 | 5 | 4 | 631 |
| 60 | carrot | 1504 | 368 | 6 | 0 | 1573 |
| 60 | wheat | 340 | 131 | 4 | 0 | 192 |
| 60 | diverse | 872 | 268 | 5 | 0 | 730 |
| 60 | producers | 1929 | 608 | 6 | 4 | 1831 |

Carrot cultiva cenouras ativamente; wheat usa trigo; diverse alterna cenoura/feijão/rosa/macieira conforme desbloqueio; producers começa com cenouras e reinveste em um exemplar de cada produtor, alimento e coleta. Compra preserva reserva de 24 moedas. Todas adquirem um vaso quando possível. O simulador decide vender estoque; o jogo nunca vende automaticamente.

A simulação desativa ocorrências aleatórias de ervas/pragas e usa rega gratuita disponível, sem fertilizante. Ausência de penalidade aleatória e frequência automatizada de ações tornam os resultados otimistas. Ações são comandos bem-sucedidos, não gestos ou minutos de esforço humano. Não há teste de economia social abusiva de longo prazo nem inflação entre contas nesta simulação; isso é coberto apenas por limites e testes funcionais de transação.

Cenoura domina moeda por atividade frequente frente ao trigo; diversificação reduz caixa inicial. Produtores consomem capital/alimento e retornam mais XP; em sessões longas já superam caixa da cenoura. Cinco minutos não compram todo o catálogo, e nenhum caso termina insolvente. Isso sustenta progressão inicial testável, não prova equilíbrio final: rever esforço por minuto, receita de produtores, variedade desejável, recompensas sociais e horizonte de semanas antes de lançamento. Preços/tempos são aproximações provisórias, não números históricos comprovados.

Reproduzir: Godot headless, `--path game --script res://tests/simulate_integrated.gd`. Resultado completo e log em `.local/integrated/balance.json` e `balance.log`, ignorados pelo Git.
