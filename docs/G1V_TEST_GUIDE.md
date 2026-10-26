# G1.V — Fazenda Viva: teste no Windows

**G1.V direção visual: PENDING HUMAN DECISION.** Este experimento não aprova arte, G1.4/G1.5 ou G1.6.

## Jogar, não apenas olhar capturas

1. Abra a pasta do repositório e dê dois cliques em `JOGAR_G1V_TESTE.cmd`. Requer Godot 4.x estável instalado; o launcher procura no PATH e Downloads. Não baixa programas nem modifica ExecutionPolicy.
2. A cena já começa no nível 3, com recursos conquistados por comandos do serviço existente. Feijão e morango prontos; rosa crescendo e cenoura inicial. A galinha é somente decoração já existente.
3. Clique/toque no feijão: colhe imediatamente, mostra XP efetivamente concedida e começa recuperação. Colha o morango também sem esperar a animação anterior.
4. Em Cuidados, escolha Regador e toque na rosa antes de amadurecer. Escolha fertilizante comum e toque novamente. No modo 60× ela amadurece rápido: se já madura, colha, abra Inventário, selecione Semear rosa e replante; depois cuide.
5. Use Loja para comprar sementes, filtros e quantidade. No Inventário, escolha semente, guarde produtos, venda quantidade parcial ou selecione tipos para venda conjunta. Compras, vendas, XP, níveis e expansão continuam usando G1.5/G1.4 sem novo balanceamento.
6. Pressione **A / B** para comparar a mesma fazenda: A angular/pixel modernizada; B cartões arredondados, sombras suaves e luz discretamente aquecida. Nada é replantado ou concedido ao alternar.
7. Em Ajustes, altere intensidade 0–100%, movimento reduzido e métricas. Preferências são desta sessão. Observe se a informação continua clara com movimento desligado.
8. Teste mouse, teclado e toque: arrasto sobre canteiros, modo Câmera, botão direito/meio/Espaço para pan, roda/pinça para zoom, Home para foco, Esc para fechar. Hold/hover mostra o cartão contextual. Pinça não deve colher inadvertidamente.
9. Redimensione a janela para retrato. Avalie leitura, botões, scroll dos cartões e quanto a UI encobre a fazenda. Teste o jogo também sem áudio; os slots ainda não têm masters finais aprovados.

## Preservação e comparação com G1.5

`user://g1v_fast.json` é exclusivo do launcher; `user://g1v_local.json` é exclusivo do modo normal. Não são lidos/escritos os saves principais G1.1–G1.5. O schema e serviço são os mesmos do G1.5; não há migração neste gate.

Para tempo normal: importe `game/project.godot`, abra `game/scenes/farm/g1v/farm.tscn` e pressione F6. F5 e cenas anteriores permanecem inalterados. Para comparar o comportamento anterior, abra `game/scenes/farm/g15/farm.tscn` com F6 ou use seu launcher antigo.

Para uma nova rodada sem apagar a anterior:

```powershell
./tools/play_living_farm.ps1 -Fast -SavePath 'user://g1v_rodada2.json'
```

Escolha um nome ainda não utilizado. Não aponte essa opção para um save principal. Em caso de erro de save, preserve o arquivo e reinicie a demonstração; não existe botão que silenciosamente descarte o progresso.

## Galeria e movimento

Abra `.local/g1v/index.html` no navegador. É material visual; não é o jogo. Há 12 capturas reais em 1920×1080 e 1080×1920 e dois GIFs 960×540, cada um codificado a 24 fps com 72 frames reais do Godot. O I/O de captura pode alterar a cadência; o GIF demonstra gestos/transições, não mede desempenho do jogo. Todos os arquivos gerados ficam ignorados no Git.

## Reproduzir

```powershell
./tools/check.ps1 -Godot 'CAMINHO_DO_GODOT_CONSOLE.exe' -Python 'CAMINHO_DO_PYTHON.exe'
./tools/capture_living_farm.ps1 -Godot 'CAMINHO_DO_GODOT_CONSOLE.exe' -Python 'CAMINHO_DO_PYTHON.exe'
```

Benchmark: execute Godot com `--path game --rendering-method gl_compatibility --script res://tests/benchmark_living_farm.gd` numa sessão gráfica; resultados em `.local/g1v/performance.json`. Não comparar medições durante captura ou outros processos pesados.

Celular físico, safe areas/densidade real, FPS mobile e acabamento sonoro continuam pendentes. O diretor deve decidir A, B ou uma combinação e avaliar game feel jogando, não apenas pelas imagens.
