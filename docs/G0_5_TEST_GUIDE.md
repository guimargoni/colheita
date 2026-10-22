# G0.5 — teste pelo diretor criativo

Abra este repositório na branch `foundation/g0-5-art-bible`. Godot **4.7.2 stable**,
GDScript, renderer Compatibility; sem addons, contas, backend ou credenciais.

1. Godot Project Manager → Import → `game/project.godot` → Edit. Aguarde imports.
2. **F5** abre o pátio G0.5. Moedas/XP são prévia estática; sem persistência.
3. Dois canteiros maduros: toque/clique no centro do morango e da cenoura para colher.
4. Com Semear ativo, clique no solo vazio; aparece muda. Clique em Semear outra
   vez para alternar semente, ou escolha na Loja (sem compra real).
5. Selecione Regar ou tecla **2**, toque na muda azulada/com sede. Aguarde 9 s de
   ciclo demonstrativo e colha. Não há custo nem prêmio econômico.
6. Arraste de um canteiro para outro e retorne: cada um recebe no máximo uma ação
   por gesto. Repita rapidamente; os efeitos não devem bloquear novo toque.
7. Ferramenta Câmera (**3**), botão direito/meio ou Espaço+arrastar deslocam a
   câmera sem colher. Fundo vazio também inicia pan. Roda aproxima; dois dedos
   fazem pinch, sem ação agrícola. Enquadrar/Home restaura a câmera.
8. Hover ~450 ms ou segurar ~550 ms inspeciona sem agir. Setas escolhem canteiro,
   Enter age quando nenhum botão tem foco; Tab navega controles, Esc fecha painel.
9. Ajustes → UI Kit: compare principal/secundário, pressionado, indisponível,
   cartão, indicador e painel. Indisponível não responde. Hover em botões mostra tooltip.
10. Ajustes → Abóbora: quarto canteiro vira conceito maduro; observe olhos piscarem
    a cada 4 s, brilho delicado e colheita teal/dourada. Sem evento ou economia.
11. Ajustes → Movimento reduzido; depois normal. Os sprites congelam, mas as
    ações continuam respondendo. SFX temporários são opcionais, **não áudio final**.
12. F8 ou Ajustes → Antes/depois alterna o renderer geométrico de referência no
    mesmo recorte e câmera. A cena integral G0.4 permanece em
    `scenes/experience/experience.tscn` (F6); G0.3 em `scenes/comparison/`.

## Resoluções exatas e capturas

PowerShell, da raiz do repositório:

```powershell
$godot = 'C:\Users\guilh\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
$python = 'C:\Users\guilh\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $godot --path game --resolution 1920x1080
& $godot --path game --resolution 1080x1920
./tools/capture_art.ps1 -Godot $godot
Start-Process (Resolve-Path '.local/g0_5/index.html')
./tools/check.ps1 -Godot $godot -Python $python
```

Se a tela física não comportar 1080×1920, a janela pode ser limitada pelo sistema;
o script de captura sempre usa SubViewport com resolução exata. Também há teste
automatizado 720×1280. Em outra máquina ajuste os dois caminhos; capturas exigem
display/GPU e **não** funcionam com `--headless`. Checks usam headless normalmente.
Android/iOS não exportados nesta entrega; toque automatizado não substitui aparelho.

Capturas PNG reais, sem retoque, ficam em `.local/g0_5/captures/`:
`art_{1920x1080|1080x1920}_{before|after|halloween|ui_kit}.png`.
Antes/depois preservam câmera, anchors, viewport e estados; mantêm o HUD G0.5
para controlar a comparação. O antes é o renderer G0.4 adaptado ao recorte de
quatro canteiros, não uma captura histórica integral. G0.4 integral é regenerável
com `tools/capture_experience.ps1`. Material gerado permanece ignorado pelo Git.

## Registrar avaliação

Anotar resolução/aparelho, acertos em 20 toques, leitura das duas culturas,
qualidade de grama/sombras/contornos, carisma da casa/animais, conforto da UI,
foco/disabled, loops e problemas de recorte. Aprovar/revisar/rejeitar por família,
sem considerar G0.5 artisticamente aprovado por passar nos testes técnicos.
Consultar limitações e status em `G0_5_QUALITY_REPORT.md`. Parar em G0.5.
