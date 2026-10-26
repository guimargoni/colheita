# G1.4 — relatório técnico

Fechamento: 2026-10-26. Branch `feature/g1-4-land-expansion`, base funcional
G1.3 `62112b1`. Integração histórica e autorização em `56fc39f` (ADR-018).

**G1.4 técnico: PASS. G1.4 experiência: PENDING HUMAN APPROVAL.**

## Entrega

Cena `game/scenes/farm/g14/farm.tscn`, iniciador `JOGAR_G14_TESTE.cmd`.
Amostra de quatro canteiros iniciais e quatro expansões, sem definir máximo final.
IDs, grid, nível, preço, sequência e condições ficam em `g14/land.json`.
Condições desconhecidas são rejeitadas. Custos 40/90/180/320 e níveis 2/3/4/5
são hipóteses atuais, não números históricos. Economia/culturas/cuidados anteriores
são reutilizados sem modificar seus arquivos.

Domínio em `scripts/domain/land/`, provedor `services/land/local_land_service.gd`,
UI em `scripts/ui/land/`, renderer `scripts/visual/g14_view.gd`. Preço, requisitos
e débito são calculados no provedor, não confiados à interface. O comando
`unlock_plot` leva request_id, plot_id, confirmação, revisão esperada e versão
da cotação. Guardar recursos produtivos ou moedas para uma semente evita ficar
sem meios de replantar após a compra; regra explícita e configurável.

Selecionar bloqueado só informa; preparar e confirmar são gestos distintos, com
proteção de 350 ms monotônicos, independente do relógio acelerado. Cancelar,
redimensionar ou perder foco revoga a intenção. Arrasto, câmera, pinça e inspeção
não compram. Terreno liberado aceita plantio, cuidado e colheita normalmente.

## Persistência e limites

Schema 4/catalog `g14.land.v1`; saves `user://g14_local.json` e
`user://g14_fast.json`, perfis `local.land.real.v4`/`local.land.fast60.v4`.
Sem migração ou alteração dos saves anteriores. Carteira, acesso, histórico,
ledger e recibo persistem no mesmo snapshot; publicação em memória só após commit.
Falha mantém estado anterior e bloqueia mutações até reabrir. Revisão e cotação
antigas são rejeitadas; request repetido retorna recibo sem novo débito/evento.
Números inteiros são normalizados no fingerprint para reenvios após leitura JSON.

Histórico registra terreno, preço, requisito, horário, operação e transação.
Validação cruza acesso/histórico/recibos/ledger. IDs do layout são persistentes,
independentes da ordem de apresentação. Novas parcelas não renumeram as anteriores.
Eventos locais pós-commit e textos via `tr()` preparam analytics/localização.

Uma instância gravadora por save. Store usa temporário/flush/rename e revisão;
não oferece CAS interprocessos, garantia contra queda física de energia ou
proteção contra edição de arquivo/relógio. Economia online deverá ser validada
pelo servidor. Nenhum backend, segredo, dependência ou migração de banco novo.

## Arte e áudio

Solo usa máscaras texturizadas e bordas externas do atlas original existente,
sem novo PNG ou geometria como ilustração substituta. Grade 2:1, canteiros adjacentes,
alvos semiabertos sem sobreposição; áreas bloqueadas têm vegetação e marcador.
Caminhos internos foram retirados nesta cena; cercas e caminho externo ajustados.
Câmera considera extensão dos terrenos; composição é curada para esta amostra,
não um gerador final de fazendas. Acabamento/UVs/tiles nativos e caminho continuam
em revisão, sem promoção de assets/licenças a conteúdo autorizado de release.

Feedback de desbloqueio reutiliza FX e toast não bloqueante. Slot `unlock_plot`
aceita somente master aprovado com embedding permitido. Sem master disponível,
o protótipo permanece silencioso; não foi produzido áudio final.

## Evidências

- 99 checks G1.4: requisitos, débito correto, confirmação, idempotência, falhas,
  recuperação, reinício em quatro processos, mouse/toque e quatro resoluções.
- Regressões anteriores: fundação PASS; G0.3 480, G0.4 15, G0.5 418,
  G0.5-R 1.148, v2 154, G0.6 329, G1.1 126, G1.2 176, G1.3 135: PASS.
- 12 simulações reais do serviço, 5/20/60 min/dia; dados e inflação discutidos em
  `G14_BALANCE.md` e `G14_BALANCE_RESULTS.md`, sem aprovação definitiva dos valores.
- 16 capturas reais Godot Compatibility/RX7600 em PC 1920×1080 e retrato 1080×1920,
  fixtures isoladas, sem retoques ou saves do jogador, galeria `.local/g14/index.html`.
- Auditoria e pilares importados integralmente do commit remoto `1d1dd8e` sem merge.
  Origem, diferenças e aceite G1.3 em `G14_HISTORICAL_INTEGRATION.md`.

Sem blocker técnico local identificado. Pendente: avaliação humana do G1.4,
balanceamento de longo prazo/inflação, acabamento artístico, áudio final, celular
físico/insets/desempenho e segurança online. Não avançar para G1.5/G2, amigos,
roubo, animais/produção, premium, monetização real ou expansões modernas.
