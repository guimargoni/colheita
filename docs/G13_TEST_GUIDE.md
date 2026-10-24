# G1.3 — como jogar e avaliar

**G1.3 experiência: PENDING HUMAN APPROVAL.** Economia local de desenvolvimento;
não é release, segurança online ou aprovação artística.

## Abrir o jogo

1. Abra `D:\Projetos\ColheitaFelizProMax\colheita` no Explorador de Arquivos.
2. Dê dois cliques em **JOGAR_G13_TESTE.cmd** e aguarde a janela do Godot.
3. A galeria `.local/g13/index.html` contém imagens; o `.cmd` abre o jogo interativo.

Requer Godot 4 stable instalado; não baixa nada nem altera política de execução.
O iniciador procura o engine no PATH e em Downloads. Alternativa: importe
`game/project.godot`, abra `game/scenes/farm/g13/farm.tscn` e pressione **F6**.
F5 mantém a cena artística anterior. F6 usa tempo normal; o `.cmd` usa 60×.

## Roteiro de dez minutos

1. Novo save: 40 moedas, quatro sementes de cenoura, nível 1. **Loja** mostra preços,
   sementes na bolsa e quantidade na loja. Morango exige nível 2; trigo, nível 3.
2. Ajuste a quantidade com **+ / −**, campo numérico ou teclado. Compre cinco
   cenouras: total 10 moedas, saldo 30, sementes 9. Não há confirmação rotineira.
3. Tente comprar 100: veja saldo insuficiente, sem alteração parcial. Volte à fazenda.
4. **Semear** seleciona/cicla sementes; **Inventário → Semear Cenoura** também
   seleciona. Clique/toque/arraste pelos canteiros vazios para plantar.
5. No 60× a cenoura leva cerca de 2 s, morango 15 s e trigo 120 s. Clique na madura:
   produto vai ao inventário, XP sobe; **moedas não sobem até você vender**.
6. **Inventário**: escolha quantidade e **Vender**, preservando parte dos produtos.
   Marque culturas e **Vender todos os produtos selecionados** para vender a cesta
   inteira. O botão fica fixo no rodapé; a lista de culturas rola. Sem seleção,
   aparece mensagem, sem venda. O valor por produto e o total ficam visíveis.
7. Venda/reinvista, colha oito cenouras no total: nível 2 desbloqueia morango.
   Barra mostra XP **do nível atual até o próximo**, não XP total da conta.
   Colheitas de morango dão 4 XP; trigo libera com 32 XP totais (nível 3).
8. **Menu → Histórico econômico DEV**: confira compra, venda, saldo anterior/posterior,
   origem, horário lógico e operação. Mostra as últimas 30; save guarda o histórico.
9. Feche e reabra o mesmo iniciador: moedas, XP, sementes, produtos, desbloqueios,
   estoque da loja e cuidados devem continuar. Não há reposição por reiniciar.
10. Teste **Cuidados** no trigo: rega/ervas/pragas/fertilizantes preservam regras G1.2.
    Super exige armar um uso; Amor continua indisponível. Nenhuma ferramenta concede
    moedas/XP só por gastar item. Colheita madura permanece direta.

Roda do mouse/pinça: zoom. Fundo, Câmera, botão direito/meio ou Espaço+arrasto: pan.
Home reenquadra; 1 semear, 2 cuidados, 3 câmera; Esc fecha painel/cancela gesto.
Hover ou toque prolongado inspeciona sem agir. Painéis bloqueiam ações no fundo;
use rolagem/arrasto na lista, Tab para foco e teclado para campos/botões.
Menu oferece movimento reduzido e reabertura após resolver falha de armazenamento.

## Saves e limites

- Teste 60×: `user://g13_fast.json`, perfil `local.economy.fast60.v3`.
- Normal: `user://g13_local.json`, perfil `local.economy.real.v3`.
- Schema 3, catálogo `g13.economy.v1`; sem migração automática de G1.1/G1.2.
- Uma instância gravadora por save. Não editar/apagar save enquanto aberto.
- Save inválido não reinicia carteira; falha de gravação bloqueia mutações até
  reabrir o estado confirmado. Relógio/arquivos locais são manipuláveis.

## Comandos reproduzíveis

```powershell
$godot = 'C:/Users/guilh/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'
$python = 'C:/Users/guilh/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
./tools/play_economy.ps1 -Godot $godot -Fast
# Tempo normal:
./tools/play_economy.ps1 -Godot $godot
# Checks completos, incluindo gates preservados:
./tools/check.ps1 -Godot $godot -Python $python
# 27 cenários, pode levar alguns minutos:
./tools/simulate_economy.ps1 -Godot $godot -Python $python
# Capturas gráficas reais e galeria:
./tools/capture_economy.ps1 -Godot $godot -Python $python
Start-Process (Resolve-Path '.local/g13/index.html')
```

Capturas usam fixture e relógio controlados; não alteram seus saves. Há PC
1920×1080 e retrato 1080×1920. Aprovação de toque/gestos simulados não equivale a
teste de celular físico, densidade/insets ou performance Android.

Arte/FX, fonte e áudio final continuam em revisão; sem masters aprovados, silêncio.
Avaliar prazer de comprar/vender, clareza de estoque, diferença guardar/vender,
tempo até desbloqueios, rolagem e conforto. Não avançar para G1.4 ou G2.
