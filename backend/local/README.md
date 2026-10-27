# Servidor social local

Implementação de desenvolvimento, **somente 127.0.0.1**. Godot headless executa o mesmo domínio da fazenda do cliente; não há players simulados no mesmo cliente. Identidade independente com credencial aleatória de 256 bits, hash no servidor e perfil privado local por cliente. Nunca expor este transporte TCP sem TLS na internet.

A entrada normal é `JOGAR_COLHEITAFELIZ.cmd`; `tools/play_colheita.ps1 -TwoPlayers -Fast` abre duas identidades no servidor DEV 60× separado. O snapshot fica em `.local/backend/world_real.json` ou `world_fast.json`, fora do Git. Um único processo escritor por arquivo é obrigatório. Transações sociais usam candidato completo e substituição atômica por arquivo temporário; não é Postgres/RLS, consenso distribuído nem garantia contra toda falha física.

Protocolo JSON por linha: `method`, `token`, `args`, `request_id`. Limites de pacote, conexão, quantidade, dono, amizade, bloqueio, disponibilidade temporal e recibos são aplicados no servidor. A API aceita intenções, nunca snapshots, preços, XP ou saldo aprovados pelo cliente. Tokens não aparecem em logs ou fixtures versionadas. Operações de duas fazendas são confirmadas no mesmo snapshot; replay retorna resultado anterior, chave reutilizada para outro payload é recusada.

Métodos de leitura: snapshot, social_state, discover, visit, community_state. Mutação: farm_command (núcleo compartilhado), invite_create/revoke/redeem, friend_request/accept/reject, block/unblock, permissions, help, animal_help, gift, steal, mischief, community_donate/claim. Visitas omitem carteiras, recibos, inventário privado e credenciais. Travessuras são opt-in; presentes e ajuda exigem consentimento/amizade. Roubo tem cooldown, teto diário, teto por ciclo e rendimento mínimo preservado; guardião alimentado impede a tentativa. Configuração em `game/data/integrated/social.json`.

`tools/check_social.ps1` inicia ambiente isolado, testa duas conexões reais, reinicia o servidor, verifica persistência/concorrência e visita por cliente Godot. Dados/credenciais de QA são ignorados e nunca devem ser publicados.

Pendências de publicação: serviço gerenciado ou implantação protegida, TLS, armazenamento transacional/Postgres, rotação/expiração e recuperação de identidade, armazenamento de credencial pelo sistema operacional, backup e observabilidade, testes adversariais e carga. Convite `colheita://invite/CODIGO` funciona por colagem no jogo local; associação do esquema ao aplicativo e URL HTTPS pública dependem de exportação/hospedagem. Não prometer que um contato no WhatsApp em outro aparelho consegue acessar localhost. Não foi feito push, deploy ou contratação.

Steam permanece opcional e não implementado: um futuro adapter de amigos deve mapear contas consentidas para IDs internos e usar os mesmos pedidos de amizade, sem acesso a contatos nem autoridade sobre carteira. Não existe botão que finja consultar Steam.
