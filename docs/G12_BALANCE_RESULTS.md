# G1.2 — resultados da simulação

Gerado por `tools/report_care_balance.py` a partir da simulação Godot com as regras reais.
Hipóteses, limitações e parâmetros em `G12_BALANCE.md`. Não são dados de jogadores.

| Min/dia | Estratégia | Colheitas | Produtos cenoura / morango / trigo | Ações de cuidado | Comuns usados | Segundos recuperados |
|---|---|---|---|---|---|---|
| 5 | Sem cuidados | 10 | 12 / 6 / 8 | 0 | 0 | 0.0 |
| 5 | Cuidados sem fertilizante | 12 | 16 / 6 / 8 | 20 | 0 | 1310.4 |
| 5 | Cuidados + 8 comuns DEV finitos | 12 | 16 / 6 / 8 | 20 | 8 | 2895.0 |
| 20 | Sem cuidados | 32 | 50 / 15 / 8 | 0 | 0 | 0.0 |
| 20 | Cuidados sem fertilizante | 36 | 58 / 15 / 8 | 53 | 0 | 1580.4 |
| 20 | Cuidados + 8 comuns DEV finitos | 36 | 58 / 15 / 8 | 54 | 8 | 2445.3 |
| 60 | Sem cuidados | 90 | 154 / 33 / 8 | 0 | 0 | 0.0 |
| 60 | Cuidados sem fertilizante | 102 | 178 / 33 / 8 | 144 | 0 | 2629.8 |
| 60 | Cuidados + 8 comuns DEV finitos | 103 | 178 / 36 / 8 | 144 | 8 | 3509.1 |

Janela: 3 dias; uma sessão diária por perfil; decisões a cada 60 segundos;
um canteiro de cada cultura; seed RNG 24102026. Sementes abundantes na fixture
de simulação (não no jogo). Sem moedas, preço, venda, tempo de animação ou
custo de clique modelados. Cultivos maduros fora das sessões não são auto-colhidos.
