# Especificação-mestre vinculante — Produto integrado

2026-10-26, autorização expressa da missão autônoma. Branch `feature/integrated-farm-product`, base `46615cc`.

## Produto e limites

Uma entrada principal e um launcher: `JOGAR_COLHEITAFELIZ.cmd`. Fazenda e vida social têm importância equivalente. Começo com quatro terrenos relevantes; expansão, moedas e XP conquistados. Reutilizar núcleo G1.5 e game feel G1.V. Gates antigos permanecem disponíveis como histórico, sem pedir aprovação por subsistema. Não fazer push, publicar builds nem contratar serviços.

Direção oficial passa a 2D estilizada, clean e acolhedora, não pixel art. Não converter arte antiga por blur nem substituir a produção artística por geometria. Novos sprites originais/licenciados; metadados, origem e revisão separados. Áudio sem licença não entra. Dispositivo físico, qualidade artística e operação pública não podem ser declarados por inferência.

## Dependências e aceitação verificável

A. Entrada integrada e persistência: cena principal única, novo save; importação/cópia de saves antigos sem sobrescrever. Regressões G0–G1.V passam.
B. Fazenda: agricultura completa herdada; árvore frutífera; galinha/ovo, abelha/mel, vaca/leite e ovelha/lã com compra, alimento, produção temporal, coleta, estoque, venda e reinício. Decorações compráveis/posicionáveis persistentes, casa/melhoria e produção de buquês. Dados novos provisórios e identificados como aproximações.
C. Social real: backend local em processo separado, duas contas distintas, tempo/cálculo/estoques no servidor. Identidade, convites revogáveis, amizade consentida, visita/permissão, ajuda, flores/presentes/popularidade, roubo limitado/guardiões/bloqueio e histórico. Cliente nunca envia preço/recompensa aprovada. Exigir testes de duas conexões, replay, concorrência e autorização negativa. Ausência de hospedagem não autoriza chamar simulação de multiplayer.
D. UI/arte integradas: nova linguagem 2D, feedback compartilhado, configurações e alvos desktop/toque. Evidência renderizada real e comparação de perfil; não gerar dezenas de relatórios redundantes.
E. Estabilidade/conteúdo: catálogos, simulações 5/20/60 minutos, segurança local documentada, lacunas históricas e externas explícitas. Critérios não implementados ficam pendentes, nunca escondidos atrás de botões falsos.

## Classificação histórica

Usar G1H_HISTORICAL_AUDIT e G15_HISTORICAL_CATALOG. Existência de animais produtores, ração, flores, visitas, guarda e buquês documentada. Custos, durações, limites e receitas novos são reconstruções aproximadas/provisórias. UI, regras antiabuso e evento original são modernizações. Minas, máquinas e recursos não recuperados precisam constar como lacunas, não serem inventados como originais.

## Arquitetura

Domínio GDScript compartilhado por cliente local e servidor Godot headless. Adapters de persistência/rede isolados. Social de desenvolvimento somente loopback, sem prometer TLS/hospedagem/Steam disponíveis. Publicação gerenciada futura deve substituir transporte/identidade por serviços seguros, preservando contratos. Banco/snapshot local não equivale a Postgres/RLS em produção.

## Disciplina

Pequenos commits recuperáveis; testes a cada dependência. Atualizar `AUTONOMOUS_EXECUTION.md` com evidências, estado de retomada e pendências sempre que houver limite efetivo. Continuar enquanto houver trabalho autorizado viável. Não declarar missão integralmente concluída com módulos obrigatórios ausentes.
