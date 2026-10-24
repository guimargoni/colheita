# G1.1 — teste manual do diretor

## Executar

Godot 4.7.2 stable: importe `game/project.godot`, abra
`game/scenes/farm/g11/farm.tscn` e **F6**. F5 e todas as cenas G0 continuam intactas.
O cabeçalho informa **LOCAL DEV** e mostra semente selecionada/estoque real local.
Primeiro save inicia com quatro terrenos vazios e 12 sementes de cada cultura.

1. **Sementes** (2) abre três opções: cenoura, morango e trigo. Toque numa para
   selecionar e voltar. **Semear** (1) ativa plantio; novo toque cicla a seleção.
2. Toque em terra vazia: planta e consome uma semente. Arraste sobre outros vazios
   para repetir a mesma ação; retornar não consome outra semente no mesmo terreno.
3. Hover ou toque longo inspeciona estado/tempo restante; mouse e hold não colhem.
4. Feche enquanto cresce e reabra com F6. O mesmo terreno/ciclo continua. Aguarde
   maturidade; o crescimento depende do horário, não do tempo de programa aberto.
5. Toque no maduro: fica vazio, toca FX e credita produto. **Inventário** mostra
   estoque; fechar/reabrir deve manter produtos e sementes. Clique rápido várias
   vezes: só a primeira colheita daquele ciclo credita produto; toque seguinte
   no vazio é um novo plantio legítimo e consome semente.
6. Arrasto iniciado em maduro só colhe maduros; não planta vizinhos vazios.
7. **Câmera** (3), arrastar fundo, botão direito/meio ou Espaço+arrasto movem sem
   agir em culturas; roda/pinça muda zoom. Home reenquadra. Menu oferece movimento
   reduzido e reabertura do save após uma falha resolvida; Esc fecha/cancela.

Não há rega funcional, fertilizante, venda, moedas, XP, desbloqueio ou social.
As interações antigas de rega continuam preservadas nos protótipos G0.

## Teste acelerado, separado do save normal

Na raiz do repositório, usando os executáveis locais desta máquina:

```powershell
$godot = 'C:/Users/guilh/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'
$python = 'C:/Users/guilh/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
& $godot --path game res://scenes/farm/g11/farm.tscn -- --g11-fast
```

Apenas build debug aceita `--g11-fast`. Cabeçalho/status identificam teste 60×;
cenoura 2 s, morango 15 s e trigo 120 s reais. Contadores são segundos do perfil
acelerado. Fechar e reabrir **com a mesma flag** continua acelerado offline. Não
importa, converte ou altera a fazenda normal. Sem flag, o tempo é real 1×.

Saves em `user://g11_local.json` e `user://g11_fast.json` (AppData do projeto no
Windows). Para localizar, use Godot **Projeto > Abrir pasta de dados do usuário**.
Uma instância gravadora por save. Não apagar/editar enquanto aberto. Se houver erro
de IO/schema, a UI informa e bloqueia ações; o arquivo não é resetado. Faça backup
antes de qualquer recuperação manual. Não há segurança anti-cheat nesse armazenamento.

## Checks e capturas

```powershell
./tools/check.ps1 -Godot $godot -Python $python
./tools/capture_farming.ps1 -Godot $godot -Python $python
Start-Process (Resolve-Path '.local/g11/index.html')
```

Checks determinísticos não esperam tempos reais: incluem fonte controlada,
fronteiras exatas, falha de escrita e três processos separados plant/harvest/replay.
Capturas usam GPU real, relógio controlado e fixture em memória, sem tocar saves
normais/rápidos. Galeria contém 18 imagens 1920×1080 e 1080×1920, inspeção de cada
cultura, inventário antes/depois, plantio e estágio seguinte. Não são mockups.

Para janelas manuais exatas:

```powershell
& $godot --path game --resolution 1920x1080 res://scenes/farm/g11/farm.tscn
& $godot --path game --resolution 1080x1920 res://scenes/farm/g11/farm.tscn
```

Celular físico/dp/insets e desempenho Android continuam pendentes. Avaliar também
se textos/FX permanecem legíveis e não ocultam a ação. Trigo é placeholder visual
identificado; proximidade dos canteiros e substituição do caminho são pendências
artísticas conhecidas, não falhas escondidas. Não avançar de G1.1 sem avaliação humana.
