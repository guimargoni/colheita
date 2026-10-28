# Execução autônoma — checkpoint recuperável

Atualizado em 2026-10-28. Branch `feature/integrated-farm-product`, base `46615cc`. Missão vinculante: `docs/INTEGRATED_PRODUCT_SPEC.md`; guia e limites completos: `docs/INTEGRATED_DELIVERY.md`. Não declarar missão integral/publicação concluída.

## Estado consolidado

Uma entrada principal `JOGAR_COLHEITAFELIZ.cmd` abre o cliente Godot integrado com servidor real loopback separado. `-TwoPlayers -Fast` abre duas identidades em duas janelas, tempo DEV 60× e mundo separado. F5 usa o provedor local isolado; social requer launcher. Domínio, UI e adapters separados. Nenhuma cena/save antiga foi substituída. Nada publicado, nenhum push ou serviço contratado.

Agricultura herdada com macieira adicional; galinha/colmeia/vaca/ovelha compráveis, alimento, espera/coleta/estoque/venda; decoração persistente, cerca orientável, residência/ateliê/buquês, conquistas/guardião. Social real: convite HTTP local, consentimento, visita, ajuda inclusive animal, presentes/flores/popularidade, roubo limitado/proteção, bloqueio/permissões/histórico e evento coletivo. Interface única com estado vazio real, sem amigos ou saldo fictícios escondidos.

Arte 2D original integrada: cinco PNGs, prompts completos, hashes, ART_REVIEW. Áudio: dez SFX Kenney CC0 com licenças originais preservadas byte a byte; masters finais/música/ambiência ausentes. A geometria não substitui arte principal. Atlas de decoração, depth sorting, poses animais e fundo estão incorporados; não há geração de imagem pendente neste checkpoint.

## Evidências concluídas

- Regressões completas `tools/check.ps1` PASS; integrado domínio 248, UI 68, migração real em disco e smoke sem parsing errors. Log `.local/integrated/check_final.log`.
- `tools/check_social.ps1` PASS 125: API/socket81, recovery18, concorrência9, dois processos Godot6+7, interface remota4. Link HTTP realmente acessado, servidor reiniciado com mesmo snapshot. Log `.local/integrated/social_final.log`.
- Simulação 12 casos/3dias, JSON revalidado. Resultados `.local/integrated/balance.json`, análise `docs/INTEGRATED_BALANCE.md`.
- Capturas GPU seis PNGs PC/retrato e 96 frames de ações; galeria `.local/integrated/index.html`, GIF sem retoque. Capturas inspecionadas. Não são fazendas iniciais; fixtures conquistam recursos sem editar carteira do produto.
- Benchmark real RX7600, 240 frames/resolução após aquecimento: ~180fps, p95 6,381/5,943ms PC. Sem inferência de celular físico/rede/carga longa.
- Launcher Windows PowerShell `-PrintCommand` validado. Scanner de política inclui backend; caches, credenciais, saves e capturas ignorados. Licenças externas têm exceção de formatação para preservar fonte original.

## Commits recuperáveis

- `3ca48d1`: autorização integrada e direção 2D.
- `5d834d9`: domínio de produção/personalização.
- `51d1233`: servidor autoritativo local e gateway.
- `4eab901`: limites, customização e convites HTTP locais.
- `689e8dc`: cliente unificado, arte original, SFX licenciados e launcher.
- Checkpoint seguinte versiona testes, ferramentas e documentação desta entrega; consultar `git log` para o hash final.

## Próximo trabalho, sem repetir etapas concluídas

1. Teste humano da versão inteira pelo launcher; acabamento artístico e de interação direta, sobretudo posicionamento visual de decorações e clareza imediata de cuidados. Isso não altera aprovações históricas.
2. Celular físico/exportação: ainda sem dispositivo de teste, áreas seguras/densidade/térmica/bateria não validadas. Layouts em software já passaram.
3. Publicação social: bloqueada por ausência de implantação/autorização de publicação. Não expor loopback cru. Preparar serviço com TLS, autenticação recuperável, credenciais seguras, banco gerenciado/transações, backup/observabilidade e testes adversariais/carga. Convites entre aparelhos/WhatsApp e Steam ainda dependem disso; nunca dizer que localhost equivale a internet.
4. Conteúdo adicional histórico permanece lacuna: patos/pavões, animais de crescimento, churrasco/bebidas, minas/tesouros/roleta, solo vermelho e catálogo de skins/VIP. Não estão fingidos na UI. Novos preços/tempos são aproximações provisórias. Rebalancear cenoura/produção em horizonte maior e com esforço humano real.
5. Produzir música/ambiência/vozes e animações finais; revisar recortes/contato dos sprites, terreno de expansão modular e clearance de lançamento. Não há pack de licença pendente incorporado como autorizado.

Não pedir segredos em texto, publicar, contratar nem avançar alegando produto de produção concluído. O núcleo integrado é jogável localmente; infraestrutura pública, acabamento final e inventário histórico integral continuam pendentes.
