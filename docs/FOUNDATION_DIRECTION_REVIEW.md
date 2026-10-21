# Revisão da foundation e registro de commits

Data: 2026-10-21. Branch dedicada: `foundation/g0-bootstrap-audit`.

O diretor aprovou tecnicamente G0.1 e G0.2. A direção visual e o licenciamento continuam sujeitos à revisão humana. O escopo deste acompanhamento é versionar o trabalho já realizado e revisar/integrar documentação. G0.3 e G1 permanecem não autorizados e não iniciados.

## Base, preservação e integração

- Base original do bootstrap: `8dccbdb` de `foundation/game-design`.
- Commit do trabalho G0: `f1f1971` — `feat: bootstrap Godot project and audit source assets` (52 arquivos de código, configuração, documentação e metadados).
- Após `git fetch origin`, a referência revisada foi `e7f5bcc` de `origin/foundation/game-design`.
- Novidades remotas: `7c9dae0` (eventos), `a7f8273` (áudio), `e7f5bcc` (monetização).
- `git merge-tree --write-tree HEAD origin/foundation/game-design` retornou sucesso sem conflitos, antes de alterar o checkout.
- A integração foi preparada com `git merge --no-ff --no-commit origin/foundation/game-design`. Não houve entradas não resolvidas em `git ls-files -u`. Os três documentos foram preservados integralmente, com conteúdo igual à referência revisada. Nenhuma resolução automática de conflito foi necessária.
- A integração e este registro são reunidos em um commit de merge com a mensagem `docs: integrate foundation direction updates and record review`, preservando as duas linhas de histórico. O hash final consta do histórico Git e da entrega ao diretor.
- A branch local não acompanha a branch remota de design, para evitar tratá-la como destino do trabalho. Nenhum push, PR ou alteração de `main` foi solicitado/realizado.

## Documentos revisados

| Área | Evidência na referência e avaliação | Pendência humana / limite de escopo |
|---|---|---|
| UX | Não existe documento específico de direção de UX em `e7f5bcc`. A árvore e o histórico disponíveis foram conferidos. O GDD contém onboarding, sessões e princípios de UX (§25–27); LIVE_OPS contém Event UX e MONETIZATION_ECONOMY contém Purchase UX. Compatíveis com UI legível, localização e interação touch previstas na arquitetura. | Localizar/adicionar o documento dedicado caso exista em outro lugar. Validar visualmente os fluxos em um gate futuro explicitamente autorizado; nenhuma tela de gameplay foi criada aqui. |
| Áudio | `docs/AUDIO_DIRECTION.md` lido integralmente: identidade pastoral, transições suaves, polifonia limitada, buses separados e experiência funcional sem som. O bootstrap não contém áudio nem SDK que conflite com essas diretrizes. | Aprovar identidade sonora por escuta, licenças/proveniência e loops. Não foram compostos/importados sons, implementados buses ou acionadas ferramentas de geração. |
| Eventos | `docs/LIVE_OPS.md` lido integralmente: definições versionadas, relógio/claims no servidor, idempotência, trilha gratuita e eventos opcionais. Alinhado à arquitetura e ao GDD. A cadência é hipótese, não compromisso de operação. | Aprovar cadência, calendário, tema, recompensas e capacidade de produção. Nenhuma configuração de evento, recompensa, telemetria ou backend foi implementada. |
| Monetização | `docs/MONETIZATION_ECONOMY.md` lido integralmente: cosméticos prioritários, conveniência limitada, sem vantagem paga de furto/defesa; reconciliação e concessões fora do cliente. Compatível com a economia autoritativa e com o bootstrap sem dados econômicos. | Validar modelo comercial, balanceamento, preços e regras de plataforma na data de implementação/lançamento. Nenhuma compra, anúncio, moeda ou SDK foi integrado. |

Não foram encontrados conflitos textuais ou incompatibilidades que exijam mudança no código de G0.1/G0.2. Esta revisão de compatibilidade não aprova direção criativa, preços, composição musical ou obrigações comerciais futuras.

## O que fica fora dos commits

A seleção de staging foi explícita e conferida por caminho/extensão: nenhum `.local/`, `.godot/`, `assets_source/`, contact sheet, imagem, áudio ou arquivo compactado novo foi incluído. Os CSV/JSON contêm apenas inventário/metadados e hashes, não conteúdo gráfico. A extração local e as 42 pranchas continuam disponíveis para revisão no índice `.local/asset_audit/index.html`, ignorado pelo Git.

Os três arquivos compactados originais já estavam versionados na base. Permanecem intactos e não foram adicionados/modificados por estes commits. Sua presença histórica continua sendo um risco de redistribuição; esta tarefa não reescreve histórico nem remove fontes.

## Verificações e comandos deste acompanhamento

- `git status --short --branch`, `git branch -avv`, `git log`, `git remote -v`, `rg --files` e leitura de `AGENTS.md`: convenções/estado inicial conferidos; mensagens seguem o padrão existente `tipo: descrição`.
- `git fetch origin`: a primeira tentativa no sandbox falhou por resolução de rede; repetição com acesso normal autorizado teve sucesso.
- `git diff --name-status HEAD origin/foundation/game-design`, `git ls-tree` e `git show` para os três documentos: leitura completa e escopo das adições conferidos; busca no histórico não encontrou arquivo específico de UX.
- `python tools/check_repository.py`: estrutura, manifesto, hashes, quarentena e padrões básicos de segredos aprovados antes do primeiro commit.
- `git add -- <lista explícita>`; verificação de extensões/caminhos do staging; `git diff --cached --check`: aprovados.
- `git commit -m 'feat: bootstrap Godot project and audit source assets'`: commit G0 realizado.
- `git merge-tree --write-tree HEAD origin/foundation/game-design`; `git merge --no-ff --no-commit origin/foundation/game-design`; `git ls-files -u`: integração sem conflitos.
- Check completo após integração: `./tools/check.ps1 -Godot 'C:/Users/guilh/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe' -Python 'C:/Users/guilh/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'`. Repositório, importação/parsing, testes de integração e boot aprovados.
- Conteúdo dos três documentos comparado byte a byte no índice com `origin/foundation/game-design`; nenhum asset novo no diff desde `8dccbdb`; `git diff --cached --check`; status final e pais do commit de merge conferidos.

## Pendências humanas mantidas

1. Direção visual: avaliar as contact sheets, a recomendação de base Maeve e as adaptações propostas, sem assumir escolha definitiva.
2. Licenças: esclarecer escopo da edição FREE de Maeve, conflito do README SnowHex com termos públicos e preservar termos completos de unTied/atribuição antes de promoção para distribuição.
3. Decidir tratamento dos arquivos compactados de terceiros já presentes no histórico antes de publicar/distribuir o repositório.
4. Localizar o documento específico de UX mencionado, ausente na referência remota conferida.
5. Revisar e aprovar as propostas de áudio, eventos e monetização em seus momentos de decisão; CI remota só será observada após publicação autorizada.

G0.1 e G0.2 permanecem tecnicamente aprovados. Nenhum gate seguinte foi iniciado.
