# G1.2 — relatório técnico

2026-10-24. Base limpa `f6b265f`, branch `feature/g1-2-crop-care`.
G1.1 aceito pelo diretor no novo briefing. Autorização exclusiva G1.2 em ADR-015.
**G1.2 técnico: PASS. Mecânicas G1.2: VALIDADAS PELO DIRETOR em 2026-10-24.**
Escopo e pendências: [registro de validação humana](G12_HUMAN_APPROVAL.md).
A aprovação das mecânicas não aprova acabamento artístico, áudio final,
teste em celular físico ou segurança online.

## Implementação

Cena `game/scenes/farm/g12/farm.tscn`. Preserva plantio/colheita direta, arrasto de
intenção única, câmera, tempo por timestamps e persistência. Cópias isoladas de
controller/renderer/adaptador; scripts G1.1 e anteriores não foram modificados.
Catálogo de culturas, inventário, relógio injetável e store transacional G1.1 são
reutilizados, sem substituir arquivos históricos ou criar autoridade fictícia.

Domínio em `scripts/domain/care/`: `care_rules.gd` deriva hidratação, ocorrências,
atraso efetivo e pisos de aceleração; `care_commands.gd` valida/aplica cuidados na
cópia candidata; `care_state.gd` valida schema2 e dados extras. Provedor local em
`services/care/local_care_service.gd`, atrás da mesma interface FarmService.

Rega: horário, hidratação até, contagem, cap e cooldown; histórico por request.
Ervas/pragas: sorteadas uma vez na plantação, horário e origem persistidos;
remoção grava removed_at, nunca rerrola/reaparece no mesmo ciclo. Snapshot calcula
ativo/inativo e término efetivo com atraso limitado; read não escreve save.
Não há cron/frame acumulando crescimento ou dano, nem morte/expiração de maduro.
Penalidade moderada é temporal, recuperável e sem destruir produto.

Fertilizantes: três itens de owner aplicáveis com estoque, compatibilidade, usos
e pisos; Amor é categoria futura não aplicável neste gate. Percentuais/estoque/
origem/ícone/FX estão em JSON. Validação de catálogo e política antes de abrir save.
Sem saldo premium, compra, presente social, grants por login ou loja escondida.

## Transação e persistência

Novos comandos water/remove_weeds/remove_pests/fertilize exigem cycle_id esperado,
validam ferramenta/estado/limites e entram na mesma transação de revisão+recibo do
G1.1. Estoque, horários, hidratação e histórico só viram estado confirmado depois
do commit. Falha de IO mantém estado anterior e bloqueia novas mutações até reabrir.
Reenvio retorna recibo sem consumir/aplicar/emitir FX outra vez; outro payload com
mesmo request_id falha. Histórico e modificadores de ciclo concluído ficam no recibo
de colheita antes da limpeza do terreno. IDs e recibos persistem entre sessões.

Save schema2/catalog `g12.care.v1`: `user://g12_local.json` normal e
`user://g12_fast.json` debug 60×, perfis `local.care.real.v2`/`local.care.fast60.v2`.
Sem migração automática: **saves G1.1 permanecem intactos**, abertos pela sua cena.
Nova cena inicia fixture independente. Perfil/schema incorreto ou JSON inválido
falha fechado, sem reset/grant automático. Política de cuidado é congelada por
ciclo. Estoque inicial de fertilizante é concedido só na criação do save.

Mesmas limitações G1.1: relógio/save manipuláveis, uma instância gravadora por save,
checagem de revisão não é CAS interprocessos atômico, sem garantia contra falha
física/energia. Não exportar esses saves como verdade de conta online. Futuro
servidor deve resolver tempo, RNG, amizade/owner, itens e recompensas em transação.
Guard local de actor e campo source preparam fronteiras, não autenticação real.

## UX

Um cartão perto do canteiro informa cultura, tempo restante, água e incômodos.
Hover PC, hold mobile sem ação; plantio/cuidado também seleciona o alvo. Somente
um cartão, não relógios permanentes em todos. UI ignora mouse para não bloquear
ação, limita posição à área visível e acompanha câmera. Pronto tem estrela discreta.

Menu Cuidados seleciona rega, limpeza ou fertilizante e volta à fazenda; toque/
arrasto age sem confirmação rotineira. Super só é armado por seleção explícita,
uma aplicação bem-sucedida desarma, e arrasto não gasta vários. Não chamar isso de
segurança online. Amor fica realmente desabilitado. Nome/estoque da ferramenta
ficam no HUD, e erros comuns têm texto compreensível em português.

Maduro continua colhendo com um toque mesmo com ferramenta de cuidado selecionada;
um gesto iniciado em maduro mantém intenção de colheita e não planta vizinho.
Gesto de rega/limpeza não muda sua ação ao atravessar outro terreno. Pinça/pan/
hold não consomem itens. Efeitos são separados do commit, curtos, limitados a 16;
carregar save não reproduz a sequência de ações ou seus sons.

## Verificações e entregáveis

176 checks G1.2: rega válida/repetida/cooldown/cap, ferramenta inválida, probabilidade/
fronteira de incômodo/recuperação/sem respawn, penalidade moderada, fertilizantes
válidos/incompatíveis/sem estoque/duplicados/cap global/armamento, IO falho, ausência,
colheita acelerada, schema2, quatro processos plant/care/harvest/replay, cartões/
arrasto/hover/hold/painel/atlas em PC e retrato, também nas escalas 1280×720 e
720×1280. G1.1 e regressões G0 no check completo.
Simulação: nove cenários com três perfis/estratégias; dados e análise no relatório
de balanceamento. 18 capturas reais de Godot em 1920×1080 e 1080×1920.

Sem blocker local. Não é certificado de desempenho Android nem teste em celular
físico. Sprites/FX e áudio final aguardam produção/revisão, detalhados em
`G12_ART_AND_AUDIO.md`. Mecânicas aceitas conforme registro humano; parâmetros
continuam provisórios, sem aprovação de balanceamento definitivo.
Não iniciado G1.3/G2: sem economia completa, pagamentos, premium, amigos, roubos
ou expansão. Não avançar automaticamente após esta entrega.
