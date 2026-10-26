# G1.5 — Como jogar e testar no Windows

## Abrir

1. Na raiz do repositório, dê dois cliques em `JOGAR_G15_TESTE.cmd`. Ele procura Godot 4.x estável instalado e abre somente G1.5 com crescimento 60 vezes mais rápido e save próprio.
2. Alternativa: importe `game/project.godot`, abra `game/scenes/farm/g15/farm.tscn` e pressione F6. Esse modo usa tempo normal. F5 mantém a cena anterior.
3. A galeria `.local/g15/index.html` contém capturas reais e não é um jogo interativo. Abra-a no navegador para comparar PC e retrato.

## Roteiro criativo

- Comece com 40 moedas e quatro sementes de cenoura. Selecione Semear e clique/toque num terreno disponível. Colha com um toque quando maduro; venda produtos manualmente no Inventário.
- O nível 2 exige 8 XP e libera rosa e abóbora; o nível 3 exige 32 XP e libera feijão. Comprar sementes exige saldo e nível.
- Loja: use os filtros Hortaliças, Flores e Especiais. Depois da compra, abra Inventário e pressione «Semear» na cultura desejada para selecioná-la. O inventário mantém produtos separados e permite venda parcial; trocar categoria limpa a cesta selecionada.
- Feijão: compre e plante uma semente, colha três vezes. A planta permanece nas duas primeiras; o cartão mostra recuperação e colheitas restantes. A última libera o solo. Reabra o jogo durante a recuperação para conferir continuidade.
- No modo rápido: cenoura 2 s, morango 15 s, trigo 120 s; feijão 10 s + 5 s + 5 s; rosa 20 s; abóbora 60 s. O cartão continua mostrando tempo lógico.
- Regue e use fertilizante comum/rápido na série. Os limites por ciclo reiniciam a cada recuperação; o estoque de fertilizantes não é reposto. Super mantém somente a compatibilidade antiga.
- Colha rosas, guarde parte e venda outra parte. Presentes e popularidade não foram implementados.
- Abóbora: observe os dois frames sutis quando madura; movimento reduzido usa frame estático. O evento original permite comprar até oito sementes por fazenda, entre 26/10/2026 00:00 UTC e 03/11/2026 00:00 UTC. Depois disso, compras encerram; sementes próprias, plantas e produtos permanecem utilizáveis. As capturas e testes usam relógio controlado para reproduzir ambos os estados.
- Arraste sobre vários terrenos para ações; use modo Câmera, botão direito/meio ou Espaço para mover sem plantar. Teste zoom e gesto de pinça, hover/toque prolongado, redimensionamento e retornos rápidos. Teclas 1/2/3 alternam ferramentas; Home reenquadra; Esc fecha painéis.

## Saves anteriores, somente por cópia

Os saves antigos continuam nas cenas antigas. Não há migração automática. Feche o jogo e localize o arquivo pelo menu Godot Project > Open User Data Folder.

```powershell
./tools/import_cultures.ps1 -SourceSave 'C:\CAMINHO\g14_local.json' -DestinationSave 'user://g15_importado.json'
./tools/play_cultures.ps1 -SavePath 'user://g15_importado.json'
```

Para fonte acelerada, acrescente `-Fast` aos dois comandos. O destino deve ser novo; arquivos existentes e conversão entre taxas são recusados. Schemas 1–4 são aceitos. IDs, posições, estoque, saldo, XP, ciclos e horários são preservados. G1.1/G1.2 recebem carteira zero e nenhum XP retroativo; layouts anteriores mantêm seus terrenos sem concessão extra.

## Reproduzir checks e imagens

```powershell
./tools/check.ps1 -Godot 'CAMINHO_DO_GODOT_CONSOLE.exe' -Python 'CAMINHO_DO_PYTHON.exe'
./tools/simulate_cultures.ps1 -Godot 'CAMINHO_DO_GODOT_CONSOLE.exe' -Python 'CAMINHO_DO_PYTHON.exe'
./tools/capture_cultures.ps1 -Godot 'CAMINHO_DO_GODOT_CONSOLE.exe' -Python 'CAMINHO_DO_PYTHON.exe'
```

As capturas exigem sessão gráfica; saídas e saves de teste ficam em `.local/`, ignorado pelo Git. Validação por eventos sintéticos de toque não substitui celular físico. Aprovar separadamente mecânicas, arte e áudio; nenhum desses testes certifica segurança online.
