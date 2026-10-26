# G1.4 — curva provisória de conquista de terrenos

2026-10-24. **Hipótese de desenvolvimento, não preços nem máximos históricos.**
Fonte: `game/data/farming/g14/land.json`. H-010 da auditoria histórica fundamenta
a mecânica, sem fornecer esta curva. A amostra começa com quatro canteiros e
oferece quatro expansões; oito não é o limite decidido do jogo.

| Terreno da amostra | Preço comum | Nível | Compra anterior | Custo acumulado |
|---|---:|---:|---|---:|
| 5 | 40 | 2 | nenhuma | 40 |
| 6 | 90 | 3 | terreno 5 | 130 |
| 7 | 180 | 4 | terreno 6 | 310 |
| 8 | 320 | 5 | terreno 7 | 630 |

Os quatro iniciais seguem relevantes: não são descartados ou renumerados. Cada
compra acrescenta **um** canteiro, com a mesma produção e footprint; não é um
prêmio de dezenas de campos. Preço cresce mais rápido que a capacidade; nível
e sequência impedem abrir tudo com as moedas iniciais. Sem XP por comprar terra,
moeda premium, venda de alívio ou aumento de penalidade para forçar gasto.

Economia, culturas e cuidados G1.3/G1.2 preservados. Lucro de vender toda produção
de uma semente: cenoura **4**, morango **10**, trigo **24** moedas, antes de qualquer
custo futuro inexistente. Por tempo-base conectado: 120/40/12 moedas/h por canteiro,
com diferentes custos de atenção; não equivalem ao rendimento de sessões diárias.
Uma parcela de 40 equivale a 10 colheitas de cenoura, 4 de morango ou 2 de trigo
se o jogador começasse sem saldo e vendesse tudo. Concessão inicial e desbloqueios
alteram o tempo real: não apresentar essa conta como número de colheitas histórico.

## Proteção contra ficar sem meios de plantar

Gastar todas as moedas em terra, sem sementes/produtos/plantas, poderia impedir
o próximo ciclo. A regra configurável exige manter algum recurso produtivo ou,
na ausência deles, **duas moedas após a compra** (semente inicial mais barata).
O painel mostra se o requisito está atendido. Não concede sementes ou moedas de
emergência nem reabastece estoque ao reiniciar. É uma proteção moderna mínima
da economia local, registrada como decisão atual, não atribuída ao jogo original.
Condições especiais por parcela estão vazias; o validador rejeita condições ainda
não implementadas, em vez de fingir que foram atendidas.

## Modelo executado

12 cenários no serviço real, três dias, quatro parcelas iniciais, seed RNG
24102026. Sessões de 5/20/60 minutos por dia, decisão por minuto. Enquanto ativo,
prefere cenoura; nos últimos dois minutos planta trigo, se liberado, senão morango
ou cenoura. As plantas amadurecem durante ausência, sem coleta automática.
Vende o que colheu e compra sementes com o saldo real. A venda automática pertence
**somente à estratégia simulada**; o jogo mantém venda manual.

Nove cenários compram a próxima parcela assim que a regra permite e a estratégia
consegue reservar uma semente de cenoura por canteiro aberto/novo. Compara sem
cuidados, rega/limpeza e cuidados com oito comuns DEV finitos. Outros três mantêm
somente quatro canteiros com cuidados para medir efeito da expansão. Sem loja de
fertilizantes, restock, gratificação diária, semente infinita ou receita premium.

Tempos por compra, colheitas, XP/nível, caixa, ações, gasto e participação dos
terrenos iniciais: [G14_BALANCE_RESULTS.md](G14_BALANCE_RESULTS.md).

## Leitura dos resultados

- Com cuidados: primeiro terreno em 4 minutos ativos (nível 2, 8 colheitas).
  Sem cuidados: 6 min nos perfis maiores; casual só na sessão do segundo dia.
  É deliberadamente acessível, mas ainda precisa do ciclo de colheita/venda.
- Casual 5 min/dia com cuidados: terreno 6 em 24,03 h corridas e terreno 7 em
  48,07 h; terreno 8 não atingido em três dias. Sem cuidado abre dois. Isso é
  resultado do horizonte, não extrapolação para uma data de compra inexistente.
- Regular 20 min/dia com cuidados: último terreno na terceira sessão, 40 min
  ativos /48 h corridas. Dedicado 60: segundo dia, 60 min ativos /24 h corridas.
- Comum finito não mudou compras/colheitas nessa cadência; acrescentou oito ações.
  Não prova inutilidade: reduções curtas podem não cruzar uma janela de minuto.
  Não comparar com fertilizante pago infinito, que não existe.
- Sem cuidado permanece possível expandir e lucrar; não há morte nem perda de
  produto por ausência. Cuidado pode atravessar o limite de coleta de um minuto,
  amplificando a diferença de colheitas. Reavaliar com horários variados.

## Capacidade, caixa e inflação

No máximo da **amostra**, capacidade dobra (4 → 8); gasto acumulado de 630 moedas
é um sink único, não solução de inflação permanente. Com cuidados, após três dias:

| Perfil | Com expansão: colheitas /caixa /XP | Controle 4: colheitas /caixa /XP |
|---|---|---|
| 5 min/dia | 41 /0 /111 | 32 /248 /88 |
| 20 min/dia | 193 /386 /336 | 116 /640 /204 |
| 60 min/dia | 658 /2.286 /823 | 356 /1.600 /444 |

O caixa zero casual tem cultivos em andamento: a estratégia reinvestiu em sementes
longas e a propriedade continua produtiva. Não representa ausência de recursos.
Caixa não inclui terreno adquirido, sementes ou plantas pendentes; não é patrimônio
líquido. Compras de terrenos desaceleram caixa inicial, mas o dedicado já supera o
controle no terceiro dia. Sem sinks recorrentes, a geração de moedas tende a
crescer; **risco de inflação permanece aberto**. Não implementar animais/decoração/
outros sistemas para esconder isso neste gate.

Parcelas iniciais geram cerca de 78%/60%/54% das colheitas nos perfis com cuidados.
Continuam centrais mesmo após expandir. Ações também crescem: 196/896/3.032 em
três dias. O modelo não mede tempo real de cliques, menus ou fadiga, então dedicado
não é promessa de sessão confortável. Colheitas rápidas não podem se tornar
obrigação de permanecer conectado.

## Pendências de avaliação

Diretor deve avaliar conquista cedo versus trivialidade, reserva de sementes,
ritmo de poupança, culturas longas, fadiga e clareza de cada parcela. Só uma seed
RNG, três dias e três culturas; não há inflação mensal, multi-sessões ou população
real modelada. Não afirmar equilíbrio definitivo ou reconstrução histórica 100%.
Reproduzir com `tools/simulate_land.ps1`; componentes Godot/Python usam `.local/g14/`
e não alteram saves do jogador. Não avançar para outro gate por conta dos resultados.
