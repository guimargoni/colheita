# G1.4 — como jogar e avaliar expansão

**G1.4 experiência: PENDING HUMAN APPROVAL.** Preços, quantidade da amostra e
acabamento são provisórios. O aceite funcional G1.3 está registrado separadamente.

## Abrir o jogo interativo

1. No Explorador, abra `D:\Projetos\ColheitaFelizProMax\colheita`.
2. Dê dois cliques em **JOGAR_G14_TESTE.cmd**.
3. Aguarde a janela do Godot. `.local/g14/index.html` é a galeria de capturas,
   não o jogo interativo.

Precisa de Godot 4 stable instalado; o script procura no PATH e em Downloads.
Não instala nada ou contorna políticas do Windows. Alternativa: importe
`game/project.godot`, abra `game/scenes/farm/g14/farm.tscn`, pressione **F6**.
F6 é tempo normal; o `.cmd` usa teste 60×. F5 e cenas anteriores continuam intactos.

## Primeira conquista, passo a passo

1. Save novo: quatro canteiros iniciais juntos, quatro áreas futuras com vegetação
   e marcador **5+ /6+ /7+ /8+**, 40 moedas e quatro sementes de cenoura.
2. Clique/toque em **5+**: veja preço 40, nível 2, benefício e requisitos atuais.
   Isso **não compra**. Segurar inspeciona; arrastar por terreno bloqueado não compra.
3. Volte. Plante as quatro sementes nos espaços iniciais vazios. Cenoura no teste
   60× leva aproximadamente 2 s. Um toque na madura colhe produto e XP.
4. No **Inventário**, venda os oito produtos; **Loja**, compre quatro sementes
   de cenoura e replante. Colha/venda novamente. Seguindo só esse roteiro: oito
   colheitas, nível 2 e 80 moedas. Se guardar produtos ou comprar diferente, o saldo muda.
5. Toque em **5+ → Preparar compra**. Confira o segundo painel. Aguarde o botão
   liberar (0,35 s reais); só **Confirmar terreno · 40 moedas** faz o débito.
   Cancelar/voltar/fechar ou perder foco revoga a preparação. Um duplo toque rápido
   não pode abrir e comprar com o mesmo gesto. Redimensionar também cancela a intenção.
6. Após confirmar, o marcador some e o solo se une à área liberada. Saldo 40 no
   roteiro acima, **um** novo canteiro. Compre semente e plante nele normalmente.
   Cuidados, crescimento e colheita funcionam com as mesmas regras dos iniciais.
7. Feche e reabra o `.cmd`: terreno, moedas, plantas e histórico devem continuar.
   Clique no espaço vazio para plantar; não há segunda cobrança ou reposição por login.
8. **Menu → Histórico econômico DEV** mostra `unlock_plot`, débito, antes/depois,
   origem e operação. As últimas 30 transações aparecem; o save mantém o histórico.

Terreno 6: 90 moedas/nível 3 e terreno 5. Terreno 7: 180/nível 4 e 6.
Terreno 8: 320/nível 5 e 7. São parcelas **desta amostra**, não limite histórico/final.
Não há premium, expansão moderna, amigo, roubo, animal ou produção implementada.

Compras não concedem XP. XP continua vindo da colheita: morango desbloqueia no
nível 2, trigo no 3. Venda continua manual e produtos podem ser guardados. Sem
sementes, produtos ou cultivos, mantenha duas moedas após expandir para poder
comprar uma semente e retomar o ciclo. O painel informa quando falta essa reserva.

## Mouse, toque e câmera

- Clique/toque em vazio planta; maduro colhe; cuidados seguem ferramenta escolhida.
- Arrasto visita cada canteiro uma vez e mantém intenção. Bloqueados são ignorados,
  sem abrir compra no meio do gesto; começar neles não planta os vizinhos.
- Fundo, Câmera, botão direito/meio ou Espaço+arrasto fazem pan. Roda/pinça dão zoom.
  Câmera/pinça não compram nem plantam. Home reenquadra; 1 semear, 2 cuidados, 3 câmera.
- Hover/toque prolongado informam estado/preço sem gastar. Esc fecha painel e cancela.
- Tab/Enter e campos numéricos mantêm acesso por teclado. Rolagem move conteúdo
  dos painéis, sem agir sobre a fazenda no fundo. Menu tem movimento reduzido.

O solo passa a ser contínuo, sem caminhos entre cada canteiro. Alvos são footprints
isométricos, não as folhas/bordas do sprite. Avalie se os espaços individuais ficam
legíveis ao plantar e passar o mouse. Caminho, fonte, atlas e acabamento continuam
em revisão; não são arte final. Áudio final ausente; slot de compra preparado.

## Saves e falhas

Tempo normal: `user://g14_local.json`, perfil `local.land.real.v4`.
60×: `user://g14_fast.json`, perfil `local.land.fast60.v4`. Schema 4/catalog
`g14.land.v1`; independentes de G1.1–G1.3, sem migração ou alteração daqueles saves.
Uma instância gravadora por arquivo. Não editar/apagar save com o jogo aberto.
Após falha de gravação, novas mutações param: resolva o armazenamento e use
Menu → Reabrir save. Não recebe carteira/terreno novo por um arquivo inválido.
O relógio/arquivo local é manipulável; isto não é segurança online.

## Checks, simulação e capturas

```powershell
$godot = 'C:/Users/guilh/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'
$python = 'C:/Users/guilh/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
./tools/play_land.ps1 -Godot $godot -Fast
# Tempo normal: omita -Fast
./tools/check.ps1 -Godot $godot -Python $python
./tools/simulate_land.ps1 -Godot $godot -Python $python
./tools/capture_land.ps1 -Godot $godot -Python $python
Start-Process (Resolve-Path '.local/g14/index.html')
```

Simulações podem levar alguns minutos. Capturas usam fixtures próprias, relógio
controlado e compras/XP realmente concedidos pelo serviço; não mexem nos saves do
jogador. Há 16 PNGs reais em PC 1920×1080 e retrato 1080×1920. Não são certificação
de celular físico, densidade/safe area ou desempenho Android. Teste de aparelho,
acabamento, áudio final, segurança online e avaliação humana permanecem pendentes.
Pare no G1.4; não avançar para G1.5 ou G2.
