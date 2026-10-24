# G1.2 — como jogar e avaliar

## Abrir sem navegar pelo editor

1. No Explorador de Arquivos, abra `D:\Projetos\ColheitaFelizProMax\colheita`.
2. Dê dois cliques em **JOGAR_G12_TESTE.cmd**.
3. Aguarde a janela do Godot. Este é o jogo interativo; a galeria HTML só contém imagens.

O iniciador usa Godot do PATH ou procura a versão 4 stable em Downloads. Não
instala engine, não baixa nada nem muda políticas do Windows. Nesta máquina o
executável encontrado é 4.7.2 stable. Se não achar, use o comando abaixo com o
caminho do seu Godot, ou importe `game/project.godot`, abra
`game/scenes/farm/g12/farm.tscn` e pressione **F6**. F5 continua no estudo antigo.

## Primeiro teste de cuidados

1. **Inventário → Trigo** seleciona uma semente. Toque num terreno vazio para
   plantar. No teste 60×, trigo leva cerca de **120 segundos** sem cuidados.
   Morango leva 15 s e cenoura 2 s; use trigo para ter tempo de testar ferramentas.
2. Passe o mouse sobre a planta: o cartão mostra cultura, quanto falta, água,
   ervas e pragas. No celular, **segure por cerca de meio segundo**; isso consulta
   sem plantar, colher ou gastar item. Após plantar/cuidar, o cartão também aparece.
3. **Cuidados → Regar**, depois toque na planta. Hidratação e benefício são salvos.
   Tentar regar de novo mostra mensagem; não acumula bônus nem consome item.
4. Ervas podem aparecer a partir de 20% do ciclo e pragas a partir de 35%, por
   chance. No trigo acelerado são cerca de 24 /42 s a partir do plantio. Não é
   garantido em toda planta. Se aparecer, **Cuidados → Ervas/Pragas · remover** e
   toque no alvo. Atraso é recuperado. Não criar conta/amigo ou usar cheat para testar.
5. **Cuidados → Comum**, toque na planta ainda crescendo. Estoque cai 8→7 no
   primeiro uso e o cartão mostra o novo tempo restante. Repetir tem limite.
6. **Superfertilizante** exige seleção explícita para armar um uso; não é compatível
   com trigo. Teste em morango/cenoura ou use testes automatizados para fronteiras
   rápidas. Arrasto não gasta vários Supers. Amor está desabilitado para gate futuro.
7. Quando aparecer estrela de pronto, um toque colhe, sem confirmação. Inventário
   recebe o produto. Feche/reabra pelo mesmo iniciador: estoque, horários e cuidados
   permanecem. Cultura não morre por ausência.

Para cuidar de vários terrenos, selecione a ferramenta e arraste. O gesto mantém
a primeira intenção e visita cada canteiro uma vez. Maduro inicial continua
colhendo diretamente; iniciar gesto de colheita não planta vizinhos vazios.
Arrastar fundo, **Câmera**, botão direito/meio ou Espaço+arrasto move sem cuidar.
Roda/pinça muda zoom; Home reenquadra. Menu permite movimento reduzido e reabrir
save após uma falha de armazenamento resolvida. Esc fecha/cancela gesto.

## Normal versus teste

O `.cmd` inicia debug 60×, flag **--g12-fast**, save `user://g12_fast.json`.
Sem a flag, G1.2 usa tempo normal e `user://g12_local.json`.
No perfil 60×, o contador mostra segundos lógicos e avança 60 por segundo real.
Nenhum dos dois altera saves G1.1. São fazendas de desenvolvimento independentes,
sem migração automática nem restock ao abrir. Uma instância gravadora por save.
Dados editáveis/relógio local não são anti-cheat ou servidor online.

```powershell
$godot = 'C:/Users/guilh/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'
$python = 'C:/Users/guilh/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
./tools/play_care.ps1 -Godot $godot -Fast
# Para tempo normal, omita -Fast:
./tools/play_care.ps1 -Godot $godot
```

## Checks, simulações e imagens

```powershell
./tools/check.ps1 -Godot $godot -Python $python
./tools/simulate_care.ps1 -Godot $godot -Python $python
./tools/capture_care.ps1 -Godot $godot -Python $python
Start-Process (Resolve-Path '.local/g12/index.html')
```

Os checks usam relógio simulado; não precisa aguardar horas. Quatro processos
separados validam plantar/regar/fertilizar, reaparecer sem reroll, remover,
colher e reenvios sem consumir/gratificar duas vezes. Capturas usam fixture isolada,
forçam ocorrências só para mostrar os sprites e não tocam seus saves. São 18 PNGs
reais 1920×1080/1080×1920 de cena, cartão, ferramentas, cuidados e colheita.

Teste manual real de celular/dp/insets continua pendente. Avalie conforto do cartão,
leitura dos insetos/ervas, clareza de ferramenta/estoque, Super armado e se cuidados
parecem opcionais. Áudio final ausente; FX específicos ainda provisórios. Trigo e
morango têm pendências visuais herdadas. Não apagar/editar save enquanto aberto.
Se houver falha, a UI bloqueia mutações e não redefine a fazenda automaticamente.

**G1.2 experiência: PENDING HUMAN APPROVAL. Não avançar para G1.3 ou G2.**
