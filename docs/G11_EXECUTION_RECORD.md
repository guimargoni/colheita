# G1.1 — registro de entrega

2026-10-24. **G1.1: PASS técnico; aguardando avaliação humana.**
Branch `feature/g1-1-farming-foundation`, criada da base limpa `a30f74f`.
Nenhuma alteração prévia não commitada encontrada; sem merge, conflitos ou push.
Não avançar para G1.2/G1.3/G2. Autorização do briefing registrada em ADR-014.

## Entrega e arquivos

Criados:

- `game/data/farming/crops.json`, `farm_fixture.json`, `fertilizers.json`.
- `game/scripts/domain/farming/crop_catalog.gd`, `farm_state.gd`,
  `growth_rules.gd`, `inventory.gd`, e os quatro `.gd.uid`.
- `game/scripts/services/farming/farm_service.gd`, `local_farm_service.gd`,
  `farm_clock.gd`, `farm_store.gd`, e os quatro `.gd.uid`.
- `game/scripts/ui/farming/farm_presenter.gd`, `farm_inventory_panel.gd`,
  e os dois `.gd.uid`.
- `game/scripts/visual/g11_view.gd` e `.gd.uid`.
- `game/scenes/farm/g11/farm.tscn`, `farm.gd` e `farm.gd.uid`.
- `game/tests/farming_tests.gd`, `farming_restart_probe.gd`, `capture_farming.gd`,
  e os três `.gd.uid`.
- `tools/capture_farming.ps1`, `gallery_farming.py`.
- `docs/G11_ARCHITECTURE.md`, `G11_CONTENT_AND_ART.md`, `G11_TEST_GUIDE.md`
  e este registro.

Alterados:

- `README.md`: entrada F6 e documentação da agricultura local.
- `docs/DECISIONS.md`: ADR-014, escopo autorizado e limites do gate.
- `docs/GDD.md`: addendum do ciclo local DEV sem mudar autoridade online.
- `docs/ROADMAP.md`: extensão G1.1 explicitamente pedida (colheita/estoque mínimos).
- `docs/TECHNICAL_ARCHITECTURE.md`: ponte para implementação e limitações locais.
- `tools/check.ps1`: inclui os testes G1.1 mantendo todos os anteriores.

Não foram alterados PNGs, manifests de assets, catálogos/contratos de arte, cenas
G0, arquivos de câmera/gestos anteriores ou `project.godot`. Sem novo áudio, arte,
dependência, segredo, credencial ou chamada remota. Recortes e sprites reutilizados
estão descritos em `G11_CONTENT_AND_ART.md`; trigo é placeholder explícito.

Artefatos ignorados: `.local/g11/check.log`, `capture.log`, `capture_errors.log`,
`index.html` e 18 PNGs em `captures/`. Arquivos de teste usam `.local/g11/tests/`
com nomes próprios; saves normais/acelerados do usuário não são tocados pelos checks
ou capturas. Nenhum save/cache/extração/captura foi incluído no commit.

## Comandos e ferramentas executados

Leitura: `Get-Content -Raw` do briefing, AGENTS, GDD, arquitetura, roadmap, arte,
UX, economia/progressão e implementação existente. Buscas `rg`, `rg --files`.
Git: `git status --short`, `git branch --show-current`, `git branch --list`,
`git log -3 --oneline`, `git switch -c feature/g1-1-farming-foundation`,
`git diff --check`. `Copy-Item` criou controller/renderer independentes a partir
de G0.6; alterações nessas cópias não afetam os arquivos históricos.

Godot/Python locais conforme guia:

```powershell
& $godot --headless --path game --editor --quit
& $godot --headless --path game --script res://tests/farming_tests.gd
./tools/check.ps1 -Godot $godot -Python $python
./tools/capture_farming.ps1 -Godot $godot -Python $python
```

O teste executa três processos Godot separados com `farming_restart_probe.gd`,
fases plant/harvest/replay, horário controlado e save isolado em disco. O wrapper
de captura usa processo gráfico oculto (`Start-Process -WindowStyle Hidden`),
Compatibility, limite de 60 s e verifica erros. Inspeção visual real via `view_image`
das capturas desktop e inventário em retrato. Galeria Python usa só biblioteca
padrão e não retoca imagens. Não foi usada geração/edição de imagem neste gate.

Preservação conferida com `git diff --exit-code a30f74f --` sobre `project.godot`,
cenas art/experience/comparison, assets, prototype, renderers G0.6/v2, áudio,
UI Kit e dados art/prototype: nenhuma diferença. Novos arquivos ficam isolados.
Erros de tipagem/compilação detectados durante desenvolvimento foram corrigidos;
save inválido agora retorna erro controlado sem gerar erro de parsing no engine.

## Validação final

| Check | Resultado |
|---|---|
| Política de repositório | PASS; 5.946 gráficos /6.158 fontes históricos preservados |
| Fundação | PASS |
| G0.3 | PASS, 480 checks |
| G0.4 | PASS, 15 checks |
| G0.5 | PASS, 418 checks |
| G0.5-R | PASS, 1.148 checks |
| Amostra v2 | PASS, 154 checks |
| G0.6 | PASS, 329 checks |
| G1.1 | PASS, 126 checks |
| Capturas reais | PASS, 18 PNGs 1920×1080 /1080×1920 |
| Parsing/runtime final | sem erros reportados |

G1.1 cobre plantio válido/ocupado/bloqueado/sem semente; consumo e crédito;
fronteiras de estágios de todas as culturas; maturidade exata e duradoura;
ausência longa; reabertura de serviço e de processos; colheita precoce/duplicada;
recibos conflitantes; ciclo antigo; IO falho, revisão obsoleta, JSON/schema/perfil
inválidos; fonte 60× persistente; modelo sem teto 4/16; preparação de fertilizantes;
mouse, teclado, toque, arrasto de intenção única, hold, câmera, pinça e painel.

Sem blocker de execução local. **Não é aprovação de segurança online**. Usar uma
instância gravadora por save; falta transação/autoridade remota. Pendentes de revisão
humana: tempos/produção provisórios, UX em aparelho físico, trigo/morango, bordas
adjacentes e substituição artística do caminho. Áudio final e normalização dos
sprites permanecem pendentes do G0.6. Ver arquitetura/guia para detalhes e limites.
