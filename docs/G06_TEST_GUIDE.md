# G0.6 — guia do diretor criativo

## Abrir a demonstração

1. No Godot **4.7.2 stable**, importe `game/project.godot` e escolha Editar.
2. Abra `game/scenes/art/g06/g06.tscn` no painel de arquivos.
3. Pressione **F6**. F5 permanece abrindo o estudo anterior, por preservação.
4. Compare com F6 em `game/scenes/art/pilot/pilot.tscn`; nenhum arquivo antigo
   precisa ser substituído. Não há servidor, instalação de addon ou credencial.

## Teste de cinco minutos

- Sem zoom, reconheça casa, galinha, culturas/estágios e o caminho de entrada.
- Clique/toque no morango maduro: colhe imediatamente e toca FX curto. Toque
  novamente: planta a semente selecionada, mesmo com a animação ainda tocando.
- Selecione **Regar** (tecla 2), toque no canteiro com sede. Crescimento local
  acelerado é simulado. Nenhum saldo é alterado e nada é salvo.
- Com **Semear** (1), arraste por vários canteiros prontos. Retorne ao primeiro:
  o mesmo gesto não repete ação. Se Semear já está selecionado, tocá-lo troca semente.
- Arraste no fundo, use **Câmera** (3), botão direito/meio ou Espaço+arrasto:
  deve mover sem plantar/colher. Roda/pinça muda zoom ancorado. **Home** reenquadra.
- Segure no canteiro para inspecionar. Passe mouse para destaque; não confirmar
  ações agrícolas. Use Tab/Enter para foco/botões.
- **Menu** ou **Estúdio** abre a avaliação, movimento reduzido, reenquadramento
  e um botão realmente desabilitado. **Esc** fecha/cancela gesto.
- Verifique repetição rápida, fonte e contraste, pés da galinha entre poses,
  contatos das cercas, leitura da terra e se a casa parece apoiada no terreno.
- Em celular físico, testar ainda dp/insets, conforto de alvos e gestos. A captura
  retrato em PC não substitui essa validação. Áudio final permanece ausente.

## Comandos reproduzíveis (raiz do checkout)

```powershell
$godot = 'C:/Users/guilh/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe'
$python = 'C:/Users/guilh/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
./tools/check.ps1 -Godot $godot -Python $python
./tools/capture_g06.ps1 -Godot $godot -Python $python
Start-Process (Resolve-Path '.local/g06/index.html')
```

Para executar janelas exatas separadamente:

```powershell
& $godot --path game --resolution 1920x1080 res://scenes/art/g06/g06.tscn
& $godot --path game --resolution 1080x1920 res://scenes/art/g06/g06.tscn
```

A resolução retrato pode exceder o monitor; a galeria usa SubViewport real de
1080×1920, sem depender do tamanho físico da janela. Captura requer GPU/display
normal, não `--headless`. Saídas ignoradas em `.local/g06/`, sem versionar PNGs
de teste, cache `.godot` ou os anexos do diretor.

## Aprovação

Na galeria, comparar antes/depois, casa/solo/animal aproximados e poses/FX.
Julgar os dez critérios artísticos do briefing: composição, integração da casa,
horta, caminhos/cercas, proporções animais, vegetação, alinhamento, consistência
dos sprites, HUD e fluidez. Registrar aprovado/revisar e motivo por família;
aceite conceitual do estilo não significa aprovação dos assets de release.
**G0.6 artístico: PENDING HUMAN APPROVAL. Não avançar para G1.**
