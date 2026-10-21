# G0.3 — Teste e revisão pelo diretor

G0.3 está **em avaliação**, sem aprovação artística. Não avançar para G1.

## Abrir

1. Abra Godot **4.7.2 stable** (build padrão, sem .NET).
2. Importe `D:\Projetos\ColheitaFelizProMax\colheita\game\project.godot` e escolha **Edit**.
3. Pressione **F5**. O menu oferece **Explorar proposta A** e **Explorar proposta B**.
4. Para abrir isoladamente, use **F6** em `scenes/comparison/proposal_a.tscn` ou `proposal_b.tscn`. O bootstrap anterior continua em `scenes/boot/boot.tscn`.

Nenhum pack, Python, extração, configuração de conta ou acesso à rede é necessário para executar o projeto.

## Controles

| Ação | Mouse/teclado | Toque |
|---|---|---|
| Explorar | Arrastar com botão esquerdo ou central | Arrastar um dedo no mapa |
| Aproximar | Roda ou botões + / − | Pinça de dois dedos ou + / − |
| Inspecionar canteiro | Clique sem arrastar | Toque sem arrastar |
| Foco nos canteiros | Botão Canteiros | Botão Canteiros |
| Restaurar visão geral | Botão com casa ou Home | Botão com casa |
| Comparar | Botão A ↔ B | Botão A ↔ B |
| Voltar ao menu | Comparar ou Escape | Comparar |
| Movimento reduzido | Pausar / Animar | Pausar / Animar |

Os painéis Loja, Amigos e Inventário são prévias estáticas de composição. **Voltar à fazenda** fecha cada painel. Não há compras, saldos reais, coleta ou persistência. A área de expansão é somente referência espacial, não interação de desbloqueio.

## Desktop e retrato sem depender do tamanho físico do monitor

Em PowerShell 7, a partir de `D:\Projetos\ColheitaFelizProMax\colheita`:

```powershell
$godot = 'C:\Users\guilh\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
$python = 'C:\Users\guilh\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
# Janelas proporcionais, que cabem no monitor:
& $godot --path game --resolution 1280x720
& $godot --path game --resolution 540x960
```

Feche uma execução antes de iniciar a seguinte, ou use terminais separados. A UI se reorganiza com a janela. As janelas acima têm os aspectos 16:9 e 9:16; as capturas abaixo são renderizadas exatamente em **1920×1080** e **1080×1920**, sem depender da área útil do monitor.

## Abrir ou reproduzir as capturas

As capturas já produzidas estão em `.local/g0_3/captures/`. Abra `.local/g0_3/index.html` no navegador ou execute:

```powershell
Start-Process (Resolve-Path '.local/g0_3/index.html')
```

Para regenerar tudo (requer display/GPU; não usar `--headless`):

```powershell
./tools/capture_visuals.ps1 -Godot $godot
```

Esse script abre o processo do Godot com janela oculta no Windows, renderiza as cenas reais, verifica erros e gera a galeria. São dez PNGs: menu + visão geral A/B + foco A/B, nas duas resoluções. Animações ficam congeladas em 2 s para comparação equivalente. Nenhuma imagem é retocada. Os arquivos ficam fora de `game/` e ignorados pelo Git.

## Roteiro de revisão (10–15 minutos)

1. Em desktop, abra A, confira os 16 canteiros, casa, cachorro, animais, caminhos e espaço para expansão. Abra B e compare os mesmos elementos.
2. Alterne usando A ↔ B. Observe profundidade, legibilidade das plantas, sombra e separação dos canteiros. A volta à visão geral ao alternar para evitar transportar um pan inadequado de uma projeção à outra.
3. Em retrato, compare primeiro as visões gerais. Depois use **Canteiros** nas duas propostas; compare tamanhos, silhuetas e espaço entre as fileiras. Recorte das bordas no foco é intencional; arraste para explorar.
4. Clique/toque em pelo menos quatro canteiros (primeiro, último e dois do meio). Só o contorno e a legenda devem mudar. Moedas e nível permanecem constantes.
5. Arraste e aproxime. Solte o mouse fora do mapa e retorne: a câmera não deve continuar arrastando. Use a casa para restaurar.
6. Abra Loja, Amigos e Inventário e volte. O HUD deve continuar visível, sem transações ou erros.
7. Use Pausar e observe plantas/animais/fumaça parados; use Animar para retomar.
8. Consulte o Debugger: nenhum erro de script. A demonstração é silenciosa por escopo.
9. Se houver aparelho físico disponível futuramente, verificar toque/pinça, escala física e áreas seguras. A renderização em retrato e os eventos sintéticos desta entrega não equivalem a esse teste.

## Registrar a decisão

O diretor pode preencher abaixo ou responder na conversa. Nenhuma opção está pré-aprovada.

- Preferência: A / B / solicitar nova iteração.
- Motivo principal: profundidade / leitura / identidade / reaproveitamento / outro.
- Canteiros no desktop: aprovado / ajustar.
- Canteiros no retrato, visão geral e foco: aprovado / ajustar.
- Casa, animais, árvores e cercas: quais famílias precisam de redesenho?
- HUD e navegação: aprovado / ajustar.
- Paleta e densidade de decoração: aprovado / ajustar.
- Custo e prioridade artística: concordar / revisar estimativas.
- Licenças: encaminhamentos necessários antes de qualquer integração de packs.

## Checks técnicos

```powershell
./tools/check.ps1 -Godot $godot -Python $python
```

Executa checks do repositório, importação/parsing, testes G0.1, testes G0.3 nas duas resoluções e boot do menu. A captura não faz parte da CI headless. Nenhum resultado automático aprova o gate criativo.
