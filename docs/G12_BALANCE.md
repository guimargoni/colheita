# G1.2 — parâmetros e hipóteses de balanceamento

2026-10-24. **Provisórios**, não ofertas comerciais nem balanceamento final.
Arquivos: `game/data/farming/g12/care.json` e `fertilizers.json`. Tempos/produção
G1.1 preservados em `data/farming/crops.json`; sem implementar economia G1.3.

## Parâmetros

| Regra | Cenoura | Morango | Trigo |
|---|---|---|---|
| Duração base | 120 s | 900 s | 7.200 s |
| Produção por colheita | 2 | 3 | 4 |
| Hidratação após rega | 180 s | 1.800 s | 21.600 s |
| Cooldown mínimo | 60 s | 300 s | 3.600 s |
| Máximo de regas/ciclo | 1 | 1 | 2 |

Rega reduz 5% da duração base por uso, respeita cap próprio 10% e o cap combinado
de aceleração. A hidratação atual normalmente cobre todo o restante do cultivo;
limite 2 do trigo reserva flexibilidade para futuras durações, sem impor segunda
rega. Não há penalidade por seco nem morte por ausência. Rega tardia pode apenas
hidratar se o piso temporal já impedir outra redução. Não cobrar ou reabastecer água.

Ervas: chance 25%, ocorrência em 20% da duração base; pragas: chance 15%, ocorrência
em 35%. Sorteadas apenas ao plantar e persistidas como horários. Máximo **uma de
cada por ciclo**, sem respawn após remover. Cada ocorrência ativa acrescenta 3%
da duração base ao término efetivo, cap total 6%; remoção recupera seu atraso.
Não reduzir quantidade, destruir cultura ou acumular penalidade diária offline.
Esse efeito temporal é a consequência moderada de produção escolhida neste gate.

| Fertilizante | Redução do restante | Estoque DEV inicial | Usos/ciclo | Restrição |
|---|---|---|---|---|
| Comum | 10% | 8 | 2 | três culturas |
| Rápido | 20% | 4 | 1 | três culturas |
| Superfertilizante | 30% | 1 | 1 | cenoura/morango, armar um uso |
| Fertilizante do Amor | 10% futuro | 0 | 1 futuro | amigos não implementados, desabilitado |

Frações incidem no tempo restante efetivo; novo término canônico respeita 50%
da duração base e pelo menos 10 segundos lógicos a partir da aplicação. A soma
de rega/fertilizantes não atravessa esse piso; penalidades ativas podem adicionar
seu atraso moderado ao término. Aplicação sem benefício permitido pelo piso é
rejeitada sem consumir item. Estoques são concessão de fixture DEV **uma vez**,
sem renovação por login, loja, preço, prêmio de cultivo ou pagamento.

Ocorrências acontecem antes do primeiro término possível (frações 0,20/0,35 <0,50).
Assim não surgem depois que a cultura já ficou madura por aceleração. Limites e
probabilidades inválidos são rejeitados; alterações de política não reescrevem
ciclos em andamento, que guardam cópia da política e seus horários.

## Simulações

`tests/simulate_care.gd` usa o **mesmo serviço**, relógio controlado e RNG seed
24102026. Três dias, uma sessão contínua de 5/20/60 minutos por dia; decisões em
cadência de 60 s, um canteiro de cada cultura. Compara sem cuidados, cuidados sem
fertilizante, cuidados com oito comuns DEV finitos (não simula compra/restock).
Sem auto-colheita enquanto fechado. Sementes abundantes somente na fixture de
simulação para não confundir limite de estoque com efeito dos cuidados.

Resultados completos: `G12_BALANCE_RESULTS.md`; dados brutos ignorados em
`.local/g12/balance.json`. Para reproduzir: `tools/simulate_care.ps1` com Godot/Python
conforme o guia. Não são observações de jogadores, previsão de receita ou prova
de economia equilibrada.

Resumo de colheitas em três dias (sem cuidados / cuidados / cuidados+comuns):
casual **10 /12 /12**, regular **32 /36 /36**, dedicado **90 /102 /103**.
Todos continuam colhendo sem cuidado. Comuns não acrescentaram colheita casual/
regular nessa cadência, embora reduzam espera; dedicado ganhou uma colheita além
dos cuidados sem fertilizante. Isso favorece acesso gratuito viável, não pressão
para compra. Cuidado também exige ações extras: 20/53/144 na estratégia sem itens.

## Interpretação e riscos

Cadência de minuto quantiza fortemente culturas de dois minutos: reduzir poucos
segundos pode cruzar uma janela de coleta, dando diferença percentual maior que
a redução temporal nominal. O modelo não mede custo de clique, UX, alternância
de sessões, fadiga, rendimento em moedas, preço/raridade ou preferência por cultura.
Oito comuns são finitos; não comparar com acesso pago ilimitado inexistente.

Mais tempo ativo dá mais ações curtas; trigo mantém utilidade de espera longa e
não morre. Nenhuma estratégia comercial dominante foi demonstrada ou descartada.
Antes de preço/recompensa definitivos, variar horários, janelas de retorno e custo
de atenção; comparar produto por objetivo/valor, não só quantidade de cenouras.
Não aumentar penalidades para vender alívio. Reavaliar com o diretor e playtests.
