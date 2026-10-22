# Animação — naturalidade e registro de frames

G0.5-R. Não impor número fixo de frames. Definir gesto, intenção, arco, contato
e duração; só então decidir quantos desenhos tornam o movimento convincente.
Frames adicionais não corrigem pivô incorreto ou variação involuntária de volume.

## Estrutura de clipe

Por frame: rect de atlas, duration_ms, canvas constante, pivot, feet_contact,
shadow_anchor, bounds de alpha e evento opcional. Por clipe: direção, loop,
contato, variações intencionais e status de revisão. Temporização em milissegundos,
sem assumir fps global. Eventos secundários não reiniciam todos os animais juntos.

Idle: pose de repouso longa, respiração discreta no tórax, sem escalar o sprite
inteiro; blink 80–150 ms ocasional, orelha/cabeça a cada 3–8 s com variação
determinística de fase. Andar: pés apoiados sem deslizar, peso alternado, velocidade
de deslocamento compatível com passada. Caso não haja arte suficiente, não fingir
caminhada final movimentando um idle inteiro em senoide.

Canteiro: vento só nas folhas, solo e raízes imóveis. Colheita/plantio/rega: efeito
curto não bloqueante, eventos de ação independentes de finished do clipe.
Recompensa visual não concede moedas/XP. Movimento reduzido desativa ambientação,
mantém estados e feedback estático/curto, sem informação exclusiva em animação.

## Legado e laboratório

G0.5 alterna recortes com fps uniforme e muda proporções/contato entre desenhos;
esse comportamento foi preservado na cena original. Laboratório permite observar
os mesmos desenhos com durações individuais: galinha [1,1; 0,12; 0,55; 1,45] s,
cão [1,8; 0,3; 0,65; 0,12] s e fase distinta. São **ensaios de timing**, não prova
de naturalidade nem novos desenhos. Há quatro desenhos porque o atlas legado já
tem quatro; a produção futura não herda essa exigência.

## Verificações

Automático estrutural: canvas e pivô coerentes, rect dentro do atlas, duração >0,
contato/sombra <=1 px quando declarados normalizados. Rejeitar mudanças de tamanho
não documentadas. Medir bounds de alpha em pixels reais durante export; comparar
largura/altura de massa, contato e centro; exceções artísticas justificadas por frame.
Loop: último→primeiro sem salto de pés, sombra ou silhueta involuntário.

O JSON G0.5-R deixa frames de produção vazios, alignment_verified=false e
NOT_PRODUCED. Testes certificam que nada foi promovido. Medição visual/pixel dos
atlases legados continua pendente; não substituir por testes que só repetem pivôs
inventados. QA humano em 1×/4×, slow motion e 30/60/120 fps antes de aceitar.
