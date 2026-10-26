# G1.V — Avaliação de desempenho

Medição local Godot 4.7.2 stable, Compatibility, AMD Radeon RX 7600. Quatro execuções, cada uma com 30 frames de aquecimento e 240 frames medidos. Viewport real desktop/retrato, intensidade 100%, rajada de água a cada 12 frames, teto de 96 partículas. Sem salvar capturas durante a amostragem.

| Opção | Resolução | FPS médio | p50 ms | p95 ms | Máximo ms |
|---|---|---:|---:|---:|---:|
| A | 1920x1080 | 179.8 | 5.53 | 7.25 | 12.21 |
| B | 1920x1080 | 179.9 | 5.58 | 6.98 | 9.93 |
| A | 1080x1920 | 180.6 | 5.55 | 6.90 | 9.80 |
| B | 1080x1920 | 179.9 | 5.53 | 7.26 | 12.39 |

Tempo de parede entre process_frame, não tempo isolado de GPU/CPU. O valor próximo a 180 FPS sugere limite de apresentação do ambiente; as pequenas diferenças não demonstram superioridade de uma opção. Não é benchmark de estresse de dezenas de terrenos nem prova de desempenho em celular intermediário. Não houve teste físico mobile, temperatura, bateria, memória de aparelho ou safe areas.

A medição cobre a fazenda com HUD, não a rolagem longa da loja. Perfis reprodutíveis em `game/tests/benchmark_living_farm.gd`; saída bruta ignorada em `.local/g1v/performance.json`. Métricas opcionais ao vivo no menu Ajustes guardam janela de 600 frames, FPS do engine e p95 de delta. Captura/GIF tem I/O e não serve como benchmark.

Medidas preventivas: arrays limitados de partículas (96), ghosts (12), textos (8), terreno pequeno; sem luz dinâmica por planta, sem dependência adicional, sem processo lógico de economia por partícula. Hardware móvel intermediário continua pendente e deve orientar reduções caso necessário.
