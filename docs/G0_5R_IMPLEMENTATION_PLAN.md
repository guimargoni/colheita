# G0.5-R — aplicação em etapas, riscos e teste

Escopo atual: consolidar padrões e preparar aplicação, sem substituir arte final.
Fases abaixo são plano, **não autorização automática para executá-las**.

| Etapa | Entrega concreta | Dependência / saída | Esforço indicativo |
|---|---|---|---|
| 0 — esta revisão | Contratos, diagnóstico, catálogo e bancada | Diretor avalia docs e laboratório | executada |
| 1 — piloto de escala | Humano original + casa/porta + cão/galinha lado a lado | Aceite de 32×16, proporções e densidade | 2–4 dias arte + 0,5 técnico |
| 2 — kit de chão | Solo/bordas/caminho/cerca + duas culturas separadas | Adjacência em bloco e alamedas a 1×/4× | 3–5 dias arte + 1–2 técnicos |
| 3 — movimento e UI | Clipe por gesto, UI compacta e um conceito de skin | Pivôs medidos, safe-area, sem salto de volume | 3–5 dias arte + 1–2 técnicos |
| 4 — som | Tema/ambiente/SFX/animais masterizados | Direitos e escuta aprovados | 3–6 dias áudio + 0,5–1 técnico |
| 5 — integração limitada | Trocar apenas família piloto aprovada, sob comparação | Regressões, mobile físico e aceite do diretor | 1–2 técnicos + 1 QA |

Dia de produção = 6 h; estimativas internas, sem cotação ou prazo garantido;
rodadas de revisão podem ampliar custo. Não iniciar dezenas de culturas/skins
antes de provar o piloto. Mantêm-se planos históricos como evidência, não promessa.

## Riscos e controles

- Porta/humano podem exigir redesenho completo da casa: validar primeiro, sem
  tentar corrigir com escala dinâmica. Regra de encaixe antes de ornamentação.
- Arte antiga não é nativa 32 px: laboratório é comparador, não conformidade de
  alpha/densidade. Solicitar fontes em camadas e export normalizado.
- Bordas compartilhadas e oclusão podem falhar em arranjos densos: testar cada mask,
  caminhos e árvores contra crops antes de integrar. Reservar alamedas é opção.
- Muitos canteiros não cabem todos com alvos 48 dp: overview apenas inspeciona;
  ações pedem aproximação e filtro de acesso. Não encolher todos os sprites.
- Tema sazonal pode alterar silhueta demais: respeitar envelope, footprint e sockets.
- Fonte/UI e sons têm direitos próprios: registro por arquivo, sem usar mockup como
  biblioteca. Packs históricos continuam bloqueados, sem novo download/treino.
- Aparelho físico, notch, DPI, temperatura/GPU e gesto real não são simulados pela
  resolução retrato. Fica QA dedicado após a direção/kit piloto aprovados.

## Laboratório reproduzível

Importar `game/project.godot` no Godot 4.7.2. **F5 continua abrindo G0.5**.
Abrir `game/scenes/art/art_lab.tscn` e pressionar **F6** para o laboratório isolado.
Também: `godot --path game res://scenes/art/art_lab.tscn --resolution 1920x1080`
ou `--resolution 1080x1920` (sistema pode limitar tamanho da janela).

Compacta/Densa/Alamedas trocam fixtures de QA; Fase visual alterna cedo/tarde
sem desbloqueio econômico. B = bloqueado, V = disponível vazio, mudas/culturas
mostram estágios. Clique/toque apenas inspeciona. Arraste para pan, roda ou +/−
para zoom inteiro, dois dedos para passos de zoom; Geral/Home enquadra a extensão.
Paleta é tint diagnóstico, não skin entregue. Guias mostram footprints ideais;
Pausa congela ensaio de idle. Régua 32 px não é um personagem final geométrico.

Avaliar casas/animais ao lado da régua, folgas de base, continuidade entre vizinhos,
bloqueados em região grande, pan/zoom e estados. Não confundir bancada com nova
arte final ou HUD definitivo. A bancada tem UI técnica maior que a meta do produto.

Checks: `./tools/check.ps1 -Godot <executável> -Python <python>` inclui contratos,
IDs, adjacência, câmeras e regressões antigas. Capturas reais de bancada geradas
por `./tools/capture_art_lab.ps1 -Godot <executável>` ficam em `.local/g0_5r/`.
Não versionar capturas nem mockup externo. Resultados em `G0_5R_EXECUTION_RECORD.md`.

## Próximo gate recomendado

Revisão humana do G0.5-R, seguida de **piloto autoral limitado em G0**, com novo
escopo explícito. Não recomendar G1 enquanto escala, kit modular e identidade não
forem aceitos. Nenhuma quantidade ou custo de terreno será fixado neste plano.
