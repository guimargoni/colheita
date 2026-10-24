# G1.1 — fundação da agricultura local

2026-10-24. Branch `feature/g1-1-farming-foundation`, base `a30f74f`.
Autorização explícita do diretor para G1.1 apenas; ADR-014. G0.6 é referência
conceitual, sem promoção automática de seus sprites ou aprovação artística final.

## Fronteiras implementadas

- `data/farming/crops.json`: três definições versionadas, balanceamento provisório.
- `domain/farming/crop_catalog.gd`: leitura/validação do catálogo.
- `domain/farming/farm_state.gd`: snapshot versionado, terrenos por ID estável,
  acesso/bloqueio, referência de região/owner, cultivo, cuidado e campos sociais.
- `domain/farming/growth_rules.gd`: estado/estágio por tempo e preview puro de
  modificadores futuros; não recebe delta de frame.
- `domain/farming/inventory.gd`: consumo de sementes e crédito de produtos,
  separados em mapas por cultura; nenhum saldo de moedas ou XP.
- `services/farming/farm_clock.gd`: fonte de horário injetável. Fonte padrão local
  é manipulável; fonte controlada nos testes. Não há relógio confiável de servidor.
- `services/farming/farm_service.gd`: contrato snapshot/comando para trocar o
  provedor local por remoto autenticado em gate futuro. Não é backend implementado.
- `services/farming/local_farm_service.gd`: regras e transação de desenvolvimento.
- `services/farming/farm_store.gd`: persistência de um snapshot por operação.
- `ui/farming/farm_presenter.gd`: adapta dados ao renderer e gera comandos.
- `ui/farming/farm_inventory_panel.gd`: seleção de sementes e inventário simples.
- `scenes/farm/g11/farm.tscn`: composição e input; `visual/g11_view.gd`: sprites.

Não substituir autoloads ou criar serviços sem consumidores. A cena usa a mesma
classe de gestos G0.4 e mantém as funções de câmera do G0.6; os controladores e
renderer anteriores ficaram intactos. Novos adaptadores foram criados em arquivos
separados, sem reescrever o histórico para encaixar a agricultura real.

## Tempo e estado

Ao plantar: `cycle_id` único por sequência persistida da fazenda, `planted_at`,
`base_duration` e `ready_at=planted_at+growth_seconds`. Duração é congelada naquele
ciclo: editar tempos do catálogo não reescreve silenciosamente plantações em curso.
`progress=clamp((now-planted_at)/(ready_at-planted_at),0,1)`; estágio é o último
limiar atingido. Maduro em `now>=ready_at`, inclusive a fronteira exata.

Estado canônico salvo: vazio/plantado e datas; estado atual e estágio são derivados
no snapshot (empty/planted/growing/mature/locked), sem precisar gravar a cada frame.
O refresh de 200 ms atualiza texto/apresentação, não o crescimento. Suspender,
perder foco, fechar o programa ou passar meses sem abrir não reinicia o ciclo.
Maduros permanecem maduros sem expirar; produtos só são creditados ao colher.
Recuo do relógio local pode atrasar/regredir apresentação; não há anti-cheat fictício.

Fixture inicial de quatro terrenos vazios preserva a composição artística; não é
decisão de quantidade inicial/final. IDs não são índices de array ou calculados
pela largura da fazenda. Serviço aceita outros terrenos e regiões. Coordenadas,
footprint/arte e acesso são independentes; posições adjacentes são permitidas.
Campos de cuidado/modificadores e dados sociais ficam presentes, sem implementar
rega, pragas, roubo ou progressão de G1.2/G2. Sem exigência de cuidado neste gate.

## Comandos, deduplicação e gravação

`plant`: request_id, plot_id e crop_id; valida acesso, vazio, cultura e estoque.
`harvest`: request_id, plot_id e cycle_id esperado; valida ciclo e maturidade.
Quantidade vem do catálogo, nunca de quantidade fornecida pela UI. Campos de preço,
XP e nível existem como metadados; não são aplicados como economia/progressão.

Uma cópia candidata reúne consumo/crédito, alteração de terreno, revisão e recibo
da operação. Só após gravar com sucesso vira estado em memória e emite o evento
local de analytics/feedback. Falha de IO ou conflito não consome/gratifica. Mesmo
request_id+intenção retorna recibo persistido (`replayed=true`), sem nova animação
ou evento. Request_id com payload diferente falha. Novo pedido com cycle_id antigo
também falha, mesmo após replantio. Recibos não são truncados nesta versão local.

Store grava `.tmp`, flush e rename/substituição do arquivo no mesmo diretório.
No Windows local testado, funciona ao substituir save existente. Checa revisão
antes de gravar para detectar instância desatualizada. **Não é transação distribuída
nem CAS interprocessos atômico**: usar uma instância gravadora por save. Não há
promessa de durabilidade contra falha física de disco/energia ou corrida entre
dois processos simultâneos. O online exigirá banco/transação/idempotência e RLS.

JSON inválido, schema/perfil incompatível ou inventário inválido falham fechados:
nenhuma redefinição automática, sementes grátis ou sobrescrita do arquivo corrompido.
UI informa erro e permite reabrir o save após recuperação manual. Ausência legítima
na primeira abertura cria a fixture. Não migrar/mesclar save dev para conta online.
Um `.tmp` abandonado não é promovido como operação concluída.

## Perfis e limites

Normal: `user://g11_local.json`, `local.real.v1`, 1×.
Somente debug/teste com `--g11-fast`: `user://g11_fast.json`, `local.fast60.v1`, 60×.
Perfil acelerado usa segundos locais ×60 consistentemente entre sessões, não UTC
de servidor; save separado e validação de perfil evitam misturar calendários.
Export release ignora a flag. Não existe botão para adiantar a fazenda normal.

Plantar/colher é imediato e sem confirmação; cada arrasto fixa a intenção do
primeiro canteiro e deduplica terrenos. Colher não planta vizinho vazio no mesmo
gesto. Pinça, pan e hold permanecem separados. FX não bloqueiam o próximo comando.

Áudio usa slots existentes: ausente/não aprovado = silêncio. Telemetria apenas
signal local por ação comprometida; nenhum dado enviado. Strings passam pelos
helpers de tradução, sem catálogo traduzido de produção. A interface local não
implementa latência, reconexão/autenticação ou estados de rede fictícios.

## Preparação de fertilizantes

Quatro classes em `fertilizers.json`: comum, rápido, super e social. Preços,
frações e limites finais **null**, sem aplicação no serviço ou UI. Preview puro
rejeita não balanceado, incompatibilidade, escopo incorreto, duplicidade e limite
de uso; recebe políticas explícitas somente em testes. Calcula piso de duração,
cap de aceleração e tempo restante mínimo, sem concluir toda plantação instantaneamente.
Histórico proposto guarda request/item/horário/antes/depois/escopo. Autorização de
amizade/owner e aplicação final pertencem ao servidor futuro. Valores sintéticos
dos testes não são decisões de balanceamento ou ofertas monetizadas.

## Pendências e riscos

Sem autoridade online/anti-cheat, backend, venda, loja, pagamento, XP, desbloqueio,
fertilizante utilizável ou cuidado definitivo. Save editável e relógio alterável
são limitações assumidas de desenvolvimento. Sem quota final de inventário ou
política de compactação de recibos. Validação física mobile e recuperação de save
de produção permanecem futuras. Trigo precisa arte original e morango precisa
desenho intermediário. Caminho e continuidade visual de canteiros aguardam arte.
Não avançar para G1.2/G1.3/G2 sem nova autorização.
