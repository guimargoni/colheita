# G0.4 — checkpoint preservado

2026-10-22. Direção A e interação direta aprovadas pelo diretor no pedido G0.5.
Arte geométrica, UI e áudio sintetizado continuam placeholders, sem aprovação final.

Implementação local: 16 canteiros, plantar/regar/colher, crescimento de 9 s,
arrastar com deduplicação, inspeção por hover/hold, pan independente, pinch,
atalhos, HUD responsivo e painéis demonstrativos. Sem economia persistente,
backend ou multiplayer. Os gates anteriores continuam acessíveis por F6.

Auditoria antes de G0.5: faltavam relatório e teste de regressão específico.
Foram adicionados 15 checks de estados, arrasto rápido, pinch, hold, toque
através do viewport em 1920×1080 e 1080×1920 e bloqueio por modal.
Corrigidos textos que excediam botões móveis e inspeção repetida a cada frame.
Capturas reais disponíveis pelo script `tools/capture_experience.ps1` em
`.local/g0_4/`; não são arte final nem benchmark de hardware móvel.

Validação em aparelho físico, conforto auditivo e qualidade artística permanecem
humanos. O checkpoint técnico não transforma placeholders em conteúdo de release.
Não houve avanço para G1.
