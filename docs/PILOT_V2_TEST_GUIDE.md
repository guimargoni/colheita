# Avaliação da amostra independente v2

Godot 4.7.2 stable, GDScript/Compatibility, sem addons ou credenciais.
Na branch `foundation/g0-5r-art-sample-v2`, importe `game/project.godot`.
**F5 mantém o G0.5 anterior**. Abra `game/scenes/art/pilot/pilot.tscn` e pressione
**F6** para esta amostra. Laboratório e demais cenas anteriores continuam disponíveis.

1. Observe casa/porta/árvore/galinha, recortes, sombras, solo e estágios. Esta é
   uma composição independente de quatro canteiros, não projeto de fazenda completa.
2. Clique/toque no morango maduro (canteiro de cima). Ele some imediatamente e
   aparecem os desenhos de colheita. Clique de novo com Semear, sem esperar o FX.
3. Semear outra vez alterna Morango/Cenoura; texto de estado informa a seleção.
   Regar/tecla 2 cuida das mudas azuladas; após 9 s simulados ficam maduras.
4. Arraste sobre canteiros e retorne: uma ação por canteiro/gesto, sem confirmação.
   Segure por ~550 ms para inspecionar sem plantar/colher.
5. Câmera/tecla 3, botão direito/meio, Espaço+arrastar ou fundo vazio fazem pan
   sem ação agrícola. Roda/pinça mudam zoom em passos inteiros. Home enquadra.
6. Estúdio abre o painel. Em breve está realmente desabilitado. Movimento reduzido
   congela idle e reduz deslocamento do FX, sem bloquear ações. Esc fecha.
7. Tab/foco e atalhos 1/2/3 são demonstrados. Sem áudio; moedas/XP são estáticos.
   Nenhuma ação persiste após fechar a cena.

## Executar e regenerar evidências

PowerShell na raiz `D:/Projetos/ColheitaFelizProMax/colheita`:

```powershell
$godot = 'C:/Users/guilh/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'
$python = 'C:/Users/guilh/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $godot --path game res://scenes/art/pilot/pilot.tscn --resolution 1920x1080
& $godot --path game res://scenes/art/pilot/pilot.tscn --resolution 1080x1920
./tools/check.ps1 -Godot $godot -Python $python
./tools/capture_pilot.ps1 -Godot $godot
Start-Process (Resolve-Path '.local/pilot_v2/index.html')
```

Janela retrato pode ser limitada pela tela física; capturas usam SubViewport com
resolução exata. Captura requer GPU/display, não `--headless`. Caminhos de Godot/
Python variam em outra máquina; jogo não depende de Python para executar.
PNGs em `.local/pilot_v2/captures/`, logs/galeria no diretório pai, todos ignorados.
Arquivos: `pilot_{1920x1080|1080x1920}_{farm|harvest_01|harvest_02|harvest_03|studio}.png`.

Registrar preferência e problemas por família; medir 20 ações intencionais,
legibilidade/oclusão, tamanho de toque, loop e conforto. Ler `PILOT_V2_REVIEW.md`
antes de aprovar: pixels nativos, pivôs e bordas ainda precisam produção/limpeza.
O teste retrato em PC não substitui aparelho real. Aprovação humana permanece aberta.
