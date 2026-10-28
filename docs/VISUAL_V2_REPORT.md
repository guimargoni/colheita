# Fundação visual integrada v2 — entrega e avaliação

2026-10-28, base `faa22bf`, branch `feature/integrated-visual-foundation`. Intervenção na cena principal existente, não demonstração separada. Direção 2D estilizada acolhedora mantida. Qualidade artística definitiva continua pendente de avaliação humana.

## Executar

Abra **JOGAR_COLHEITAFELIZ.cmd** na raiz. Para duas contas e tempo acelerado: `JOGAR_COLHEITAFELIZ.cmd -TwoPlayers -Fast`. Mesmos perfis, mundos e fluxo social da versão integrada. Em Ajustes → Aparência, escolha Fazenda Viva ou Noite de abóboras, depois telhado terracota ou azul. A troca atualiza o mundo existente; somente os controles do HUD são reorganizados. Não há custo, recompensa ou alteração do calendário/evento.

Loja e Inventário apresentam culturas em cartões ilustrados; comprar quantidades, seleção de sementes, estoque, venda parcial/selecionada continuam funcionais. Fazenda reúne animais/produção, decoração, construções e conquistas. O posicionamento de decoração mostra uma miniatura da propriedade: escolha uma posição livre numerada para comprar/mover. Amigos separa amizades, convites, atividade, privacidade e evento. Visitas usam o mesmo renderer e tema de preview local, mantendo dados privados protegidos. Cuidados usa componentes nativos compactos; alvos e descrições específicas permanecem onde faltam ícones claros.

Mesmos controles: clique/toque direto, arrasto de ferramentas, hover/hold, câmera por ferramenta/botão secundário/Espaço, roda/pinça, Home, Esc. O tema e a skin ficam em `user://integrated_preferences.cfg`, separados da economia. São preferências locais de apresentação, não cosméticos compartilhados ou comprados pelo servidor. Visitantes ainda não recebem a personalização artística do dono.

Galeria: `.local/visual_v2/index.html`. Dez capturas reais em PC 1920×1080 e retrato 1080×1920; dois vídeos `.avi` Motion-JPEG, 960×540 e 540×960, quatro segundos nominais/96 frames cada, sem áudio. Abrir os AVI num player compatível; a página inclui preview GIF, cuja compressão não é referência final de cor. Nenhuma imagem foi retocada. Captura por I/O não mede FPS. Fixtures visuais usam recursos conquistados por comandos do domínio, sem alterar a fazenda inicial ou saves do jogador. Evidências geradas ficam fora do Git.

Reproduzir capturas: `tools/capture_visual_v2.ps1 -Godot CAMINHO -Python CAMINHO`. Os caminhos de execução usados nesta máquina estão no checkpoint. `game/project.godot` continua abrindo `scenes/main/farm.tscn`.

## Arquitetura e perspectiva

`data/visual/v2/appearance.json` é o pacote versionado `farm.appearance.v2`. Contém contratos por família, referências de atlas, envelopes, âncoras, temas, skins e fallback explícito. `appearance/resolver.gd` combina entidade lógica, tema, skin, estado funcional, animação e variação permitida; texturas têm cache. Culturas, frames animais, cenários e ícones são referências visuais independentes dos IDs persistidos. Nenhum nome de PNG entra no domínio.

`crop_renderer.gd` e `animal_renderer.gd` desenham famílias separadas. O view coordena projeção/profundidade e renderização ambiental, reutilizando a camada existente de feedback; não concede produção. `animation_clock.gd` calcula frames por segundos/fase, `animation_clips.json` define timings distintos. `seasonal_ambience.gd` demonstra iluminação e AnimationPlayer nativos; shader move delicadamente água/tint sazonal. Transformações, Tween de UI, partículas limitadas e ghosts de colheita são independentes dos recibos econômicos. Há estados estáticos quando movimento/intensidade são zero.

Chão ortográfico **2:1**: `p=(16(x−y),8(x+y))`, canteiro 2×2 com base aproximadamente 64×32. Adjacência antiga foi preservada. Ângulo aparente dos eixos é ±26,565°; paredes verticais e duas faces em casa/ateliê. Os novos sprites corrigem a frontalidade da casa; não foi usado skew. Recortes são ajustados proporcionalmente dentro de envelopes, sem esticar cada eixo. Casa: envelope 115×122; solo 64×33; path 22×12. A skin azul conserva envelope/pivô da terracota. Outros itens e frames têm medidas no manifesto.

Âncora é contato no chão, com solo/caminho centrados; retângulo transparente não define ocupação. Chão antes dos objetos, depois ordenação pelo y projetado e x como desempate. Objetos altos ficam atrás dos campos, marcadores legíveis por cima. Footprint/hit map vêm do modelo e não do sprite. Sombras desenhadas mantêm luz superior esquerda; nova produção deve separar sombra e corpo para rig sem arrastar a sombra. Pequenas margens/contatos e mistura de densidades ainda precisam avaliação humana.

Tema Halloween troca vegetação, solo, caminho e ornamentos, acento da UI, tint do gramado existente e luz ambiental. Ele não é um novo tileset completo de grama/água. Animais/culturas/construções sem desenho sazonal próprio usam a família padrão; fallback é intencional, sem inventar arte inadequada. Novos eventos econômicos continuam no catálogo de eventos, não no tema.

## Terrenos e compatibilidade

Capacidade parametrizada em `data/integrated/land.json`: **16 parcelas, quatro iniciais**, oito anteriores mantidas com mesmos IDs/coordenadas/custos. As oito novas completam uma disposição 4×4 de canteiros 2×2 e começam bloqueadas. Custos adicionais: 460, 600, 740, 880, 1020, 1160, 1300 e 1440 moedas; pré-requisito sequencial, níveis 5/5/6/6/6/6/6/6. Valores provisórios de modernização, sem alegação histórica ou balanceamento definitivo.

`land_extension.gd` migra somente o layout antigo conhecido, adicionando parcelas vazias/bloqueadas. Não concede moeda, item, XP nem recursos retroativos; conserva histórico/recibos/temporizadores. Commit validado/idempotente; escrita falha não publica candidato. Servidor migra no início e persiste antes de atender leituras. Saves de gates antigos e seus serviços/dados permanecem intactos; layouts customizados desconhecidos não são sobrescritos. Downgrade de um mundo ampliado para código antigo não é migração suportada: faça backup antes de trocar branches para jogar versões antigas.

Os slots de decoração continuam fora da grade ampliada. Câmera calcula limites pela ocupação e mantém zoom/pan; não altera escala dos sprites por tipo quando adiciona parcela. Perspectiva/hit map são os mesmos em PC/retrato. O cenário distante ainda é uma composição de apresentação ancorada na tela, não terreno modular de propriedade ilimitada.

## Estado por entregável

| Entregável | Classificação | Evidência/limite |
|---|---|---|
| Cena principal, launcher e mecânicas preservadas | CONCLUÍDO tecnicamente | Regressões locais e sociais; sem cena alternativa |
| Pacote, contratos, resolução, fallback | CONCLUÍDO tecnicamente | Manifesto e testes de limites de atlas/estados |
| Dois temas e skin individual da casa | CONCLUÍDO tecnicamente | Troca no mundo existente, persistência cosmética e economia isoladas |
| UI principal, cartões, social por abas, mapa de decoração | CONCLUÍDO tecnicamente / PENDENTE DE VALIDAÇÃO HUMANA | Layouts testados; avaliação de intuição, contraste e gosto não é automatizada |
| Perspectiva/escala | PARCIAL / PENDENTE DE VALIDAÇÃO HUMANA | Casas substituídas; vegetação/poses e contatos de atlas ainda em revisão |
| Maturidade/colheita e conforto | CONCLUÍDO tecnicamente / PENDENTE DE VALIDAÇÃO HUMANA | Estrela estática, realce, vento, feedback e opções de redução; requer avaliar satisfação |
| Animação híbrida final de animais e partes | PARCIAL / PENDENTE DE ASSET | Três poses e timings por espécie, clips/reação/coleta; caminhada, alimentação desenhada específica e rigs completos faltam |
| Gramado/água totalmente modulares/temáticos | PARCIAL / PENDENTE DE ASSET | Fundo com shader/tint e novas peças sazonais; sem tileset completo novo |
| Progressão ampliada | CONCLUÍDO tecnicamente / PARCIAL no balanceamento | Migração e compras preservadas; curva de longo prazo ainda provisória |
| Capturas/vídeos reais e testes | CONCLUÍDO tecnicamente | Galeria e logs privados; vídeo não é teste em aparelho físico |
| Pesca | CONCLUÍDO como planejamento | `FISHING_PLAN.md`; nenhum gameplay de pesca |
| Celular físico / publicação online | BLOQUEADO externamente nesta entrega | Sem dispositivo e infraestrutura pública autorizada; layout PC simulado não substitui validação real |
| Aprovação artística definitiva | PENDENTE DE VALIDAÇÃO HUMANA | Arte original ART_REVIEW, sem promoção a final |

Nenhum blocker impediu os objetivos locais executáveis. [Lista de produção/aquisição](ASSET_ACQUISITION_LIST.md) registra os materiais faltantes; música e áudio final permanecem pendentes, com SFX CC0 existentes preservados.

## Checklist humano

- [ ] Abrir pelo launcher e identificar rapidamente como plantar, cuidar, colher e vender.
- [ ] Comparar padrão/Halloween e telhados sem perder orientação ou contexto; reiniciar e conferir preferência.
- [ ] Colher com efeitos normal/zero e movimento reduzido; distinguir madura/vazia/bloqueada/cultivada sem som ou cor como único sinal.
- [ ] Avaliar perspectiva de casa/ateliê/canteiros, escala animal, contato dos pés, oclusão e sombras.
- [ ] Comprar e mover decoração pelo mapa, girar cerca e conferir após reinício.
- [ ] Comprar/guardar/vender produtos, alimentar/coletar, expandir uma parcela; comparar saldo/XP antes e depois.
- [ ] Testar dois perfis: convite na aba Convites, aceitar, visitar, ajudar/presentear e ler Atividade antes/depois da troca de tema.
- [ ] Testar mouse, teclado/foco, arrasto, hold/pinça; câmera não deve aplicar ferramentas.
- [ ] Avaliar menus em retrato, legibilidade, tamanho dos alvos, orientação, excesso de texto e se a fazenda permanece central.
- [ ] Avaliar loops dos animais, ritmo, maturidade e colheita por vários minutos; registrar movimentos inadequados em vez de aprovar pelo número de testes.

Os resultados e comandos finais estão em `AUTONOMOUS_EXECUTION.md`; aprovação humana não foi registrada por inferência.

## Verificação técnica final

Baseline antes das alterações: regressões completas e social PASS. Após as alterações: `tools/check.ps1` PASS, domínio 248, interface 104, aparência 122, migração em disco e smoke sem parsing errors. Social final: API81 + recovery18 + concorrência9 + processos6/7 + UI remota5 = 126, com duas contas/processos e visita após tema/skin. Sem duplicar recompensas ou remover sistemas.

Benchmark real RX7600/Compatibility, 30 frames de aquecimento e 240 medidos por caso, seis casos. Efeitos são amplitudes/contagens, não multiplicadores de tempo de animação.

| Resolução | Intensidade | FPS | p95 ms | Máximo ms |
|---|---:|---:|---:|---:|
| 1920x1080 | 0.0 | 179.98 | 8.701 | 14.300 |
| 1920x1080 | 0.65 | 180.02 | 8.202 | 14.491 |
| 1920x1080 | 1.0 | 180.34 | 9.600 | 14.578 |
| 1080x1920 | 0.0 | 179.82 | 8.653 | 13.651 |
| 1080x1920 | 0.65 | 180.55 | 9.214 | 13.838 |
| 1080x1920 | 1.0 | 179.97 | 9.142 | 16.383 |

Tempo de frame do processo no PC, sem rede/carga pública/celular. Não é medição isolada de GPU nem comparação estatística de custo por efeito. I/O dos vídeos é excluído do benchmark. Aprovação artística, desempenho térmico e teste em dispositivo físico não foram inferidos.
