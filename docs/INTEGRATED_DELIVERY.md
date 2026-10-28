# Versão integrada local — guia e estado da entrega

Checkpoint de 2026-10-28, branch `feature/integrated-farm-product`. Direção oficial: 2D estilizada acolhedora, ADR-021. Os gates, cenas e saves anteriores permanecem preservados; esta entrega não altera suas aprovações humanas. A missão integral de lançamento continua pendente.

## Abrir e jogar

1. Na raiz do repositório, dê dois cliques em **JOGAR_COLHEITAFELIZ.cmd**. Requer Godot 4.x estável instalado; o launcher procura no PATH e em Downloads. Esta instalação foi testada com Godot 4.7.2.
2. Aguarde a importação de assets. O launcher inicia o servidor local e abre a versão integrada, sem escolher cenas antigas. Não abra a galeria HTML esperando jogar: ela contém capturas.
3. Se o motor não for encontrado, execute `powershell.exe -NoProfile -File tools/play_colheita.ps1 -Godot "CAMINHO_DO_GODOT_CONSOLE.exe"`.
4. Para avaliar rapidamente, execute `JOGAR_COLHEITAFELIZ.cmd -Fast`. O tempo de desenvolvimento fica 60×, com mundo separado do modo normal. Não há recursos gratuitos escondidos.

O início real tem 40 moedas, quatro sementes de cenoura e quatro canteiros disponíveis. Selecione Semear e toque/clique num canteiro vazio. Uma planta madura é colhida diretamente. Em Cuidados, escolha regador, remoção de ervas/pragas ou fertilizante; aplique no canteiro. Pode arrastar a ferramenta por vários terrenos. Produtos vão ao Inventário e só são vendidos por decisão do jogador. Compre sementes na Loja; moedas e XP desbloqueiam conteúdo. Terrenos com + mostram uma compra explícita, porque gastam moedas.

Câmera: ferramenta Câmera, arraste com botão secundário ou Espaço+arraste; roda do mouse para zoom. Toque com dois dedos/pinça navega sem aplicar ferramentas. Home reenquadra, Esc fecha, 1 seleciona semente, 2 abre cuidados, 3 seleciona câmera. Hover/toque prolongado consulta contexto. As ações não esperam suas animações terminarem.

Em **Fazenda**, abra Animais, Decoração, Construções ou Conquistas. Animais exigem nível e moedas: adquira, compre alimento, alimente, espere, colete e venda ou guarde a produção. O clique no animal também alimenta/coleta. Cada ciclo precisa de novo alimento; não há morte por ausência. Decoração usa 16 posições exclusivas; escolha uma posição livre no painel, compre e mova depois. Cercas podem mudar de orientação. O ateliê transforma três rosas em buquê. A casa possui uma melhoria visível. O guardião comprado e alimentado protege por tempo limitado. Todos usam o mesmo saldo persistido.

## Social entre duas pessoas no mesmo PC

1. Execute **JOGAR_COLHEITAFELIZ.cmd -TwoPlayers -Fast**. Abrem duas janelas, perfis one e two, e um servidor headless separado. Para abrir só a segunda depois: `JOGAR_COLHEITAFELIZ.cmd -Player two -Fast`.
2. Na primeira, abra **Amigos**, crie e copie o convite. Na segunda, cole o link ou código em Usar convite. Na primeira, aceite a solicitação. Também é possível encontrar pelo nome/ID.
3. Visite a fazenda amiga, atualize sua visualização quando necessário e regue/remova ervas ou pragas. Ajuda a animais gasta alimento do ajudante. Consulte o histórico na conta que recebeu a ação.
4. Cultive rosas para enviar flores ou buquês. Presentes transferem estoque real e aumentam popularidade. Roubo exige cultura madura, dono de nível mínimo 2 e permissão; possui limites diários, por ciclo e intervalo. Guarda alimentado impede; pelo menos uma unidade permanece para o dono.
5. Experimente bloquear/desbloquear, privacidade de visita, revogar convite e ativar/desativar travessuras. O evento Jardim compartilhado aceita cenouras, exige contribuição e dá uma recompensa única quando o objetivo coletivo é alcançado. Janela demonstrativa: 26/10 a 01/12/2026 UTC, configurada no catálogo.

O link HTTP abre uma página válida **neste computador**, em 127.0.0.1. Não funciona em outro aparelho por WhatsApp: hospedagem HTTPS pública, aplicativo exportado e associação de links ainda faltam. Nenhum acesso a contatos é solicitado. Não há amigos fictícios preenchendo o painel.

## Persistência e recuperação

Mundos: `.local/backend/world_real.json` e `world_fast.json`. Identidades locais: `user://integrated_identity_one.cfg` e `integrated_identity_two.cfg`. Credenciais de desenvolvimento nunca devem ser publicadas. A configuração do nome do projeto foi preservada para manter a localização dos saves antigos. Faça backup do mundo e identidades juntos; não edite nem apague para tentar recuperar saldo. O servidor encerra após 120 segundos sem pedidos; inicia novamente pelo launcher.

F5 no editor abre a mesma cena integrada com provedor local isolado; para social, use o launcher. A ferramenta `tools/import_integrated_save.ps1 -SourceSave ORIGEM -DestinationSave NOVO_DESTINO` copia schemas anteriores sem sobrescrever o original ou um destino existente. Adicione `-Fast` apenas para um save originalmente acelerado. Importação econômica de arquivos do cliente para a conta online não é permitida. Testes confirmam preservação de bytes da origem, IDs, estoques e temporizadores.

## Evidência executada

- `tools/check.ps1`: regressões G0–G1.V, domínio integrado **248**, interface **68** em 1920×1080, 1080×1920, 1280×720 e 720×1280; migração real em disco e abertura headless. Sem erros de parsing nos checks.
- `tools/check_social.ps1`: **125 verificações**: socket/API 81, recuperação após reinício 18, concorrência/ajuda animal 9, dois processos Godot 6+7, interface remota 4. Inclui convite HTTP, identidade, consentimento, permissões, replay, preço forjado, ajuda, roubo/guarda, transferência, evento e persistência. Não equivale a auditoria de segurança de produção.
- `simulate_integrated.gd`: 12 simulações de três dias, [resultados e limites](INTEGRATED_BALANCE.md).
- `capture_integrated.gd` + `tools/capture_integrated.ps1`: seis capturas reais GPU e 96 frames de interação, codificados em GIF sem retoque. Galeria local `.local/integrated/index.html`; imagens em `captures/`. Fixtures de captura conquistam seus recursos por comandos do domínio e não alteram o início do jogo.
- `benchmark_integrated.gd`: RX 7600, Compatibility, 240 frames medidos por resolução após 30 de aquecimento. 1920×1080: 179,92 fps, p95 6,381 ms; 1080×1920: 180,05 fps, p95 5,943 ms. Tempo de frame do processo no PC, sem rede; não mede celular, carga social, consumo ou estabilidade prolongada.
- `tools/check_repository.py` e `git diff --check`: política de assets/licença/segredos básicos e whitespace. Logs e evidências geradas ficam em `.local`, fora do Git.

## Implementado e limites

Agricultura/cuidado/multicolheita, sete culturas incluindo macieira, economia, expansão compacta, quatro produtores funcionais, alimento finito, casa/ateliê/buquês, sete decorações, conquistas e guardião estão integrados. Social possui contas distintas no servidor local, amizade consentida, visitas, ajuda, presentes/flores/popularidade, roubo limitado, bloqueio, privacidade, histórico e evento comunitário. Preços e tempos novos são reconstruções aproximadas; UI, antiabuso e evento são modernizações originais, não regras históricas comprovadas.

A apresentação usa cinco PNGs originais com prompts/hashes e status **ART_REVIEW**, não aprovação final de arte. SFX Kenney CC0 têm licenças e hashes; música, ambiência e vozes finais faltam. O cenário distante é uma composição de apresentação, ainda não terreno modular de grandes propriedades. Algumas margens/recortes, transições de poses e indicadores de cuidado precisam acabamento. Personalização por posições fixas é funcional, ainda menos intuitiva que edição direta no mundo.

Catálogo histórico não integral: patos/pavões, animais de crescimento como porcos/coelhos, churrasco/bebidas, minas, roleta/tesouros, solo vermelho, login e catálogo amplo de avatares/skins/VIP não estão implementados. Não existem botões que simulem esses sistemas. A economia tem evidência inicial, sem validação de retenção ou balanceamento final.

Pendências externas: implantação autorizada, TLS, autenticação recuperável/rotação e armazenamento seguro de credenciais, banco transacional gerenciado, backup/observabilidade, testes adversariais/carga e integração Steam. JSON de escritor único com commit atômico é DEV, não Supabase/Postgres/RLS. Comandos síncronos limitados ao loopback não garantem boa UX na internet. Não houve push, publicação ou contratação.

PC foi executado; layouts e gestos foram testados em software. Celular físico, áreas seguras, densidade, bateria e desempenho térmico continuam sem validação. Aprovação artística, mix final e clearance de lançamento permanecem humanos. A entrega é jogável localmente; não é lançamento público concluído.
