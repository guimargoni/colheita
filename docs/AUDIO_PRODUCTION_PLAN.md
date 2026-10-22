# Direção e produção sonora — G0.5

## Revisão G0.5-R — Fazenda Viva

Direção vigente: acolhedora, natural, suave e memorável. Todos os sons atuais
são PLACEHOLDER ou NOT_PRODUCED; nenhum APPROVED ou candidato final. Inventário
por cue/origem/licença/status em `audio_catalog_g05r.csv`; não existem arquivos
de áudio final em `game/assets/audio/`. Sons de animais ainda não produzidos:
galinha em pequenos clucks ocasionais (não loop contínuo), cão com respiração/
farejo e reação gentil, sem latido a cada ação. Vozes animais espaçadas 8–20 s
como proposta de mix, sujeita a escuta; nunca mascarar rega/colheita.

76 BPM, Ré maior e instrumentação abaixo são brief de composição, não uma trilha
aprovada. Produzir motivo original com silêncio e variação, sem imitar músicas.
Separar música/vento/aves/animais/SFX/UI em buses e manter headroom. Pausas
ambientais e camadas de intensidade baixa evitam sensação de áudio genérico.
Transições futuras dia/noite/visita com crossfade 2–4 s, sem reinício ao abrir UI;
retomar após background móvel com fade curto, respeitando mute. São especificações
de produção, não funcionalidades já prontas. Revisão 20 min em fone/telefone/
caixas, checar loop, fadiga e clipping; cada master precisa termo de embedding,
autor, fonte, hash e medição. Ausência atual permanece em silêncio no laboratório.

Status: **áudio final não produzido**. Não havia ferramenta de composição/master
musical disponível nesta sessão. A alternativa autorizada no pedido é este brief
executável de produção e pontos de integração; os tons do G0.4 não são trilha final.
Cena G0.5 inicia em silêncio. Ajustes permite ouvir apenas SFX temporários para
comparar feedback, explicitamente rotulados. Música synth não é oferecida no G0.5.

## Tema diurno original: Jardim do Sol

Atmosfera: manhã tranquila, terra úmida, luz na varanda; motivo curto reconhecível,
com pausas que deixam a fazenda respirar. Sem citar/copiar melodias de jogos.
Andamento **76 BPM, 4/4**, centro tonal Ré maior, sem bateria agressiva. Forma de
32 compassos (~101,05 s) A8/A'8/B8/A''8, mais cauda separada para loop.
Proposta harmônica: D6–Gmaj7–Em7–A(add9), Bm7–G–D/F#–Asus4; variações de
voicing para não soar como bloco repetido. Compositor define melodia original
de 4 compassos com resposta de 4, evitando notas constantes e saltos gritantes.

Violão nylon dedilhado (centro), piano felt suave (respostas), flauta respirada
restrita a 2 frases por seção; baixo acústico discreto, escova/shaker quase inaudível,
pad orgânico muito baixo. B retira flauta e abre espaço. No máximo 5 camadas
simultâneas. Variação de noite retira percussão, baixa registro e densidade.
Halloween usa celesta/clarinete em frase nova, mistério gentil, sem horror.

Entregar mix full, sem melodia e stems de cordas/teclas/sopro/baixo/ambiente.
Seamless loop de amostra exata, sem silêncio final e sem reiniciar ao abrir painéis.
Testar transição por 20 repetições e sessão confortável de pelo menos 20 min.

## Ambiência e efeitos

| Slot | Direção e duração | Variações / limite |
|---|---|---|
| ambient_farm | vento leve estéreo + folhas; pássaros espaçados, 60–90 s | sem vocalizações repetidas em 5 s |
| plant | terra macia, toque de semente, folhinha, 120–220 ms | 3 variações, sem agudo metálico |
| water | gota inicial + fluxo pequeno, 220–420 ms | 3, sem ruído agressivo |
| harvest | folhagem, pop orgânico, resolução musical curta, 180–320 ms | 4, jamais encobrir próxima ação |
| reward | brilho de madeira/metal macio, 140–280 ms | 3, menos frequente que harvest |
| button | madeira/papel com click gentil, 40–90 ms | 3, volume menor |

Todos precisam ser originais gravados/compostos ou com licença comercial para
embutir em jogo e modificar, autoria e termos arquivados. Não usar áudio de
YouTube, rip de jogos ou licença apenas pessoal. Se usar geração musical, revisar
contrato da ferramenta/modelo e origem dos inputs antes de contratar/produzir.

## Especificação de entrega

Masters WAV PCM 48 kHz/24 bit; SFX mono quando pontuais, ambiência e música
estéreo. Runtime Ogg Vorbis para loops, WAV 16 bit para efeitos pequenos.
Música alvo -20 a -18 LUFS-I, true peak <=-1 dBTP; SFX nivelados por percepção
e confortável relação com música, sem master clip. Cortes/fades em zero crossing,
cauda preservada, teste mono e alto-falante de telefone. Registrar medição por arquivo.
Esses são alvos de produção, não medições de material que ainda não existe.

Buses Master/Music/Ambient/SFX/UI. `game/scripts/audio/review_audio.gd` carrega
somente slots com path existente, `review_status: APPROVED` e
`commercial_embedding: true`; ausente = silêncio sem erro. Slots em
`game/data/art/audio_slots.json`. `set_ambience()` liga loops já aprovados; a
propriedade de loop deve ser configurada no import do stream. Seis vozes e
intervalo mínimo 35 ms para cues, sem esperar áudio para agir. Não há credenciais.
Integração de crossfade, sliders persistentes e interrupção móvel definitiva
fica para o gate autorizado correspondente; não foi declarada pronta.

Produção humana estimada: compositor 2–4 dias para tema + revisão, sound designer
1–2 para ambiência/SFX, técnico 0,5–1 para imports/loops/mix, QA auditivo 0,5.
Ferramentas possíveis: DAW com instrumentos e bibliotecas licenciadas (Reaper,
Ardour ou equivalente), editor de áudio e medidor LUFS/true peak. Sem nova
dependência instalada. Contratação, escolha de ferramenta e aceite são humanos.
