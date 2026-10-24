# G1.3 — hipóteses econômicas e balanceamento

2026-10-24. **Valores provisórios, não balanceamento definitivo.** Fonte única das
regras econômicas: `game/data/farming/g13/economy.json`. Durações e produção seguem
o catálogo G1.1, sem modificar sua implementação nem seus preços históricos.

## Proposta inicial

| Cultura | Nível | Semente | Duração normal | Produção | Venda/un | Lucro/ciclo | XP/colheita |
|---|---:|---:|---:|---:|---:|---:|---:|
| Cenoura | 1 | 2 | 120 s | 2 | 3 | 4 | 1 |
| Morango | 2 | 5 | 900 s | 3 | 5 | 10 | 4 |
| Trigo | 3 | 8 | 7.200 s | 4 | 8 | 24 | 12 |

Cenoura ensina o ciclo e recompensa atenção frequente. Morango aumenta recompensa
por ciclo e janela de retorno. Trigo oferece maior retorno por plantio/colheita
e por semente investida, com menos intervenções. Não se tenta igualar moedas/h
teóricas: isso faria a cultura longa estritamente melhor quando o jogador pode
retornar constantemente. O teste humano deve avaliar se a diferença atual é justa.
Não há cultura premium, punição por ausência ou custo de cuidado para vender alívio.

Novo save recebe **40 moedas e quatro sementes de cenoura**, uma vez. Estoque da
loja: 1.000 sementes por cultura, finito e persistido, sem restock neste gate.
É uma disponibilidade DEV suficiente para o ensaio, não decisão de escassez comercial.
Compra permite 1–999 unidades; venda da seleção inteira aceita todo o estoque
dentro do limite numérico. Carteira/XP/estoques ficam limitados a 1 bilhão.

XP só na colheita: sem XP por comprar, vender, regar ou gastar fertilizante.
Isso evita farmar níveis girando transações. Limiares **cumulativos**: 0, 8, 32,
80, 180 e 360 XP, níveis 1–6. Morango desbloqueia no 2, trigo no 3. Níveis 4–6
não fingem liberar sistemas futuros. Ao atingir 6, XP segue registrado até o limite,
barra exibe máximo DEV. A curva não é infinita nem aprovada para produção.

## Simulações executadas

27 cenários no serviço real, RNG seed 24102026, quatro canteiros, três dias,
perfis de **5/20/60 minutos por dia**, uma sessão contínua e decisões por minuto.
Preferência por cenoura/morango/trigo; usa cenoura até desbloquear a preferida.
Compara sem cuidados, rega/limpeza e cuidados com até oito comuns DEV finitos.
Compra/reinveste com saldo real, sem sementes ilimitadas. Venda automática é
**somente a política do simulador**; o jogo exige venda manual.

Resultados, moedas/h e XP/h teóricos, frequência de ciclos e tempos até níveis:
[G13_BALANCE_RESULTS.md](G13_BALANCE_RESULTS.md). Variação de moedas é diferença
de caixa, não lucro contábil: há sementes gratuitas, estoque remanescente e
capital em cultivos ainda crescendo. Não comparar apenas saldo final.

Exemplos sem cuidado, em três dias:

- 5 min/dia: cenoura termina com 136 moedas/24 XP/87 ações; preferência por morango,
  112 moedas/27 XP/55 ações. Há ganho por ciclo/atenção mesmo com menor caixa.
- 20 min/dia: cenoura 444 moedas/101 XP/355 ações; trigo 276 moedas/95 XP/139 ações.
- 60 min/dia: cenoura 1.248 moedas/302 XP/1.063 ações; trigo 348 moedas/131 XP/150 ações.

O primeiro nível chega em 4–6 minutos ativos no modelo; no casual sem cuidado,
o retorno diário adia o nível 2 para o segundo dia. A prioridade por trigo casual
não gera colheita de trigo antes do fim de três dias: desbloqueia tarde ou nem
chega ao nível 3. Não apresentar esse cenário como teste de fazenda já estabelecida.

## Cuidados e fertilizantes

Regras G1.2 preservadas: rega tira 5% da duração base por uso, até 10%; ervas e
pragas adicionam 3% cada enquanto ativas, recuperável ao remover, sem perda de
produção. Comum/rápido/super reduzem 10/20/30% do restante, respeitando limites,
piso de 50% da duração base e ao menos 10 s até conclusão. Amor não aplicável.

Exemplo sem incômodo, uma rega e fertilizante imediato: duração aproximadamente
0,95 × 0,90 = 85,5% da base com comum; 76% com rápido; 66,5% com Super, sujeito
às restrições por cultura. Na cenoura comum: 120 → 114 → 102,6 s. Esse exemplo
não cria disponibilidade infinita: há oito comuns, quatro rápidos e um Super,
sem compra/restock; trigo não aceita Super. Não há preço nem margem comercial
atribuída aos fertilizantes DEV gratuitos.

Nos 27 cenários, os oito comuns não acrescentaram colheitas frente a só cuidar
nessa cadência, mas consumiram ações/estoque. Sem cuidado continua havendo retorno
positivo; cuidados às vezes cruzam uma janela de minuto, ampliando a diferença
de colheitas além da redução nominal de tempo. Examinar isso antes de aumentar bônus.

## Limitações e próxima revisão humana

Não modela tempo gasto nos menus, habilidade, sessões espalhadas no dia, farm
expandida, custos de decoração/animais/receitas, estoque de longo prazo ou inflação
de meses. Só três culturas e três dias; sem variância entre seeds RNG. A estratégia
rápida vence moedas/h conectado; isso é um risco de fadiga, não uma conclusão de
que longas estão balanceadas. Avaliar valor por ação, retornos assíncronos e rotinas
reais antes de aprovar números. Não implementar sinks ou sistemas de outro gate
para disfarçar uma lacuna do modelo.

Reprodução: `tools/simulate_economy.ps1 -Godot CAMINHO -Python CAMINHO`.
Usa arquivos de teste em `.local/g13/`; não altera saves do jogador.
