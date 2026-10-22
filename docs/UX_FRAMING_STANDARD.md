# UI, enquadramento e fazenda expansível

G0.5-R, parâmetros propostos para avaliação. Mockup orienta qualidade/identidade;
não copiar avatar, posições, barra de vida, datas, missões ou sistemas ilustrados.
Não há autorização para implementar essas funções agora.

UI futura: topo compacto para moeda/nível e acesso de menu; toolbar contextual
inferior; inventário/amigos/loja em ações secundárias. Papel claro, navy/teal,
ouro contido, ícones de silhueta simples. Trocar ornamento excessivo por hierarquia,
sem reduzir alvos. Texto tem camada nativa legível, estados normal/hover/foco/
pressionado/disabled; a borda não é a área de toque.

Meta de fazenda visível: >=80% da altura útil desktop, >=75% mobile na tela de
interação, fora modais temporários. Zonas seguras: safe-area real do sistema +
16 dp laterais, 8–12 dp separação e 12 dp entre ferramentas. UI em dp; mínimo
48×48 dp por botão, fonte 14–16 sp corpo, rótulos não cortados em português.
132 px em imagem 1080 não comprova 44 dp em qualquer aparelho; medir densidade
real e insets. Manter teclado/foco e texto de estado além de cor/som.

Canteiros: alvo com largura/altura efetiva >=48 dp em modo de ação. Se overview
reduzir isso, toque apenas foca/aproxima, sem plantar/colher. Não deixar hit areas
gigantes sobre vários terrenos; desempate determinístico e teste de bordas.
Tap/drag iniciado em canteiro age; fundo/ferramenta câmera faz pan; hold inspeciona;
pinch cancela gesto de ação. Filtrar locked antes de ação. Sem confirmação rotineira.

Camera inicial foca área disponível, reservando contexto para regiões futuras.
Novos terrenos aumentam bounds; não encolhem casa, personagem ou plantas.
Geral opcional, zoom ancorado, retorno ao foco e pan com margem. Regiões podem
ser compactas ou ter alamedas; skins não mudam hit map ou posição de controles.

Laboratório usa controles técnicos simples, régua e guias, não o novo HUD final.
Tem inspeção e câmera, sem gameplay. Em retrato sua barra de ferramentas ocupa
mais que a meta do produto: registrar isso como limitação de bancada, não como
solução final. Também não há safe-area de aparelho físico validada nesta sessão.
G0.5 principal permanece disponível para comparação do HUD anterior.
