# G1.3 — relatório técnico

2026-10-24. Branch `feature/g1-3-economy-progression`, base limpa `22f988b`.
Autorização exclusiva ADR-017. Marco `milestone/g1.2-mechanics-approved` preservado.

**G1.3 técnico: PASS.**
**G1.3 experiência: PENDING HUMAN APPROVAL.**

## Entrega jogável

Cena isolada `game/scenes/farm/g13/farm.tscn`; entrada fácil `JOGAR_G13_TESTE.cmd`.
Ciclo comprar sementes → plantar/cuidar → colher para estoque/XP → vender por
escolha → reinvestir. Não há venda automática no jogo. Quatro canteiros existentes,
sem expansão nem quantidade final de terrenos decidida neste gate.

Loja tem catálogo, preço unitário/total, quantidade por compra, estoque disponível,
sementes na bolsa, saldo e bloqueio por nível. Inventário permite selecionar semente,
vender unidade/quantidade ou cesta inteira de culturas selecionadas, mantendo o resto.
Dados futuros de animais/construções/decorações/produção/expansão têm status PLANNED,
nível nulo e não aparecem como funcionalidades disponíveis.

## Domínio e fronteiras

`scripts/domain/economy/economy_rules.gd`: configuração validada, quantidades inteiras,
preço/valor de venda, limites, carteira, ledger, XP, níveis e desbloqueios.
`economy_state.gd`: schema 3, validação de cuidados reutilizada do G1.2 e invariantes
econômicas. `services/economy/local_economy_service.gd`: comandos validados atrás de
FarmService. O adaptador é independente do provedor aprovado G1.2: evita estender uma
operação já commitada e gravar XP em segunda transação. Cuidados/domínio/renderer
originais são reutilizados; os arquivos anteriores não foram alterados.

Comandos novos:

```text
buy_seeds { request_id, crop_id, quantity }
sell_products { request_id, items: { crop_id: quantity, ... } }
```

UI não determina preços, saldo, recompensa ou XP. `harvest` acrescenta produtos e
XP na mesma cópia candidata que limpa o canteiro. XP só na colheita; nível e lista
de culturas liberadas são derivados dos limiares configuráveis. Plantio também
valida nível, independentemente do botão desabilitado da loja.

Sem novos autoloads, dependências, rede, banco, credenciais ou migrações de backend.
O futuro provedor remoto deve validar identidade/tempo/preços/estoques e aplicar
essas intenções em transações de servidor. Estes saves não devem virar patrimônio
online por importação confiada.

## Persistência, auditoria e idempotência

Schema 3/catalog `g13.economy.v1`, perfis `local.economy.real.v3` e
`local.economy.fast60.v3`; arquivos `user://g13_local.json` e `user://g13_fast.json`.
Nenhuma migração/reset de G1.1/G1.2. Novo save concede moedas/sementes e estoque DEV
de fertilizantes somente na criação confirmada. Sem restock ao abrir.

Carteira, sementes, produtos, estoque da loja, XP/nível/desbloqueios, ledger e
recibos persistem em um snapshot via store existente: temporário, flush e rename,
checagem de revisão e publicação do estado em memória só após commit. Erro mantém
estado anterior, bloqueia novas mutações e exige reabertura do estado confirmado.
JSON/schema/perfil inválido falha fechado; sem concessão gratuita por corrupção.

Cada mutação de moedas tem transaction_id, tipo, delta inteiro assinado, saldo
anterior/posterior, origem, horário lógico, operation_id e quantidades por item.
Concessão inicial também consta. XP está no recibo da colheita com ciclo, recompensa,
nível anterior/posterior e conteúdos liberados. Leitura valida encadeamento do ledger,
saldo final e soma de XP dos recibos. IDs de transação são sequenciais no contexto
do save/fazenda local; não são IDs globais de produção.

Request ID bem-sucedido fica persistido junto da mutação. Reenvio devolve o recibo
sem gastar, recompensar ou emitir evento de novo. Alterar intenção mantendo ID
falha; cesta usa ordenação canônica. Falhas não confirmadas podem ser tentadas após
recuperação. Cliques novos representam intenções novas, não retries de transporte.
Guard síncrono busy evita reentrada na UI. Não há autosale ou concessão de XP por
animar HUD, gastar moeda ou abrir jogo. Eventos locais só após commit têm autoridade
explicitamente `LOCAL_DEVELOPMENT_UNTRUSTED`.

Limites preservados: uma instância gravadora por save; revisão não é CAS
interprocessos atômico. Não há garantia contra queda física de energia, edição de
arquivo, relógio manipulado ou trapaça. Ledger local não é prova criptográfica.
Histórico/recibos completos crescem no snapshot; export/arquivamento e performance
de anos de conta exigem solução de servidor futura, não foram certificados aqui.

## Interface, arte e áudio

HUD mostra moedas com transição, nível e barra de XP animada até o próximo nível.
Compra/venda têm estado textual; venda tem voo de três sprites de moeda, XP tem
feedback e nível celebra sem bloquear, informando nova cultura. Movimento reduzido
retira deslocamentos/interpolação, preservando resultado textual. Painéis roláveis
mantêm fechamento e venda selecionada acessíveis; campo numérico, +/−, teclado,
mouse e toque. Erros comuns têm mensagens em português via `tr()`, preparando
localização; não há pacote de tradução final.

Reutiliza UI original `g05r_pilot/ui_v1.png` e renderer G1.2, com Cozy Pixel Art —
Fazenda Viva. A moeda é um recorte AtlasTexture dessa imagem, não novo PNG nem arte
geométrica substituta. Nenhum asset foi gerado, alterado ou promovido para release.
Painéis/progressbar/campos nativos são componentes de UI, acabamento ainda em revisão.

`g13/audio_slots.json` e `economy_audio.gd` preparam buy_seeds/sell_products/level_up
só com caminho válido, status APPROVED e embedding comercial. Não há masters
aprovados: **o protótipo permanece silencioso**, sem fingir áudio final. Fonte,
arte de trigo/morango, FX dedicados e demais dívidas G1.2 permanecem abertas.

## Validação

- 135 checks G1.3: compras, estoque/saldo, quantidades inválidas, preços adulterados
  ignorados, bloqueios, vendas, seleção atômica, recibos/reenvios, XP, nível,
  desbloqueio, limites, corrupção, falhas de compra/venda/colheita e recuperação.
- Quatro processos separados buy/harvest/sell/replay verificam estoque, moedas e XP
  uma vez só entre reinicializações reais.
- UI em 1920×1080, 1080×1920, 1280×720 e 720×1280; toque planta, mouse colhe,
  painéis bloqueiam fundo e fluxo de compra/venda usa o serviço.
- Suíte completa: fundação, G0.3 480, G0.4 15, G0.5 418, G0.5-R 1.148,
  amostra v2 154, G0.6 329, G1.1 126 e G1.2 176: PASS.
- 27 simulações de serviço real, três perfis; [resultados](G13_BALANCE_RESULTS.md)
  e [interpretação](G13_BALANCE.md), sem afirmar equilíbrio definitivo.
- 16 capturas reais, Godot Compatibility/RX7600, PC/retrato, fixtures isoladas;
  sem retoques nem saves do jogador. Galeria ignorada `.local/g13/index.html`.

## Pendências e parada

Sem blocker técnico local identificado. **Experiência G1.3 aguarda diretor**:
prazer das transações, progressão, diferença entre culturas e conforto dos menus.
Balanceamento provisório, arte/acabamento, áudio final, licenças/release, aparelho
físico/insets/desempenho Android e segurança online continuam pendentes e separados.
Não implementar G1.4/G2, pagamentos, premium, anúncios, visitas, roubos, expansão
ou produção animal. Pare neste gate.
