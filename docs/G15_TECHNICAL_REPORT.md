# G1.5 — Relatório técnico

Data: 2026-10-26. Branch: `feature/g1-5-historical-crops`. Base preservada: `a27e6a8`.

**G1.5 técnico: PASS. G1.5 experiência: PENDING HUMAN APPROVAL.** G1.4 permanece com aprovação humana formal pendente; a autorização recebida vale exclusivamente para G1.5.

## Entrega

Cena isolada G1.5 com seis culturas: cenoura, morango e trigo preservados; feijão de três colheitas; rosa vermelha; abóbora sazonal original. Catálogo documental mais amplo com fontes e confiança em [G15_HISTORICAL_CATALOG.md](G15_HISTORICAL_CATALOG.md). Feijão e rosa têm presença histórica documentada; valores novos são provisórios. Abóbora é modernização demonstrativa, não reconstrução histórica.

Dados de cultivo, cuidados, fertilizantes, economia, evento e arte estão em `game/data/farming/g15/`. Domínio, serviço e UI novos ficam em diretórios `cultures/`. Cenas e fontes anteriores não foram substituídos. Limites, preços e regras de expansão G1.4 permanecem inalterados.

## Estado e transações

Schema 5 guarda layout, saldo inicial, procedência de migração, histórico sazonal e séries de colheitas. A série congela total e duração/estágios de recuperação no plantio. Cada colheita usa cycle_id novo, incrementa completed e concede produtos/XP uma única vez; series.id permanece. Recuperação começa no instante da coleta, sem conceder colheitas durante ausência. A última coleta remove a série e libera o solo.

Cuidados e modificadores pertencem à perna atual. Recuperação reinicia condições e limites de uso; não repõe estoque. Comum e rápido aceitam novas culturas; super permanece restrito às antigas. Receitas idempotentes precedem novas mutações; falhas de gravação não publicam o estado candidato.

Evento tem relógio de calendário separado do relógio acelerado de crescimento, janela UTC, nível, teto acumulado e recibos de aquisição persistidos. Encerramento bloqueia somente novas compras, sem confiscar sementes, plantas ou produtos. Flores guardam ID próprio e uso futuro declarado `gift_future`, sem sistema social ou venda compulsória.

## Compatibilidade

Importador copia schemas 1–4 para arquivo novo, valida origem e destino e verifica bytes originais intactos. Preserva farm/owner IDs, layout, estoque, timers e recompensas já recebidas. Não concede moedas ou XP retrospectivos. Perfis normal/acelerado não podem ser convertidos entre si. Receitas antigas são normalizadas para replay sem duplicação; procedência registra hash e revisão. Layouts legados de quatro terrenos mantêm posições originais; schema 4 mantém expansão e histórico.

Persistência local continua de desenvolvimento, com um escritor e substituição local por arquivo temporário. Não há CAS distribuído, garantia universal contra perda de energia ou autoridade online. Relógio, save e RNG locais não são confiáveis contra fraude. Não houve migração de banco, pagamentos ou backend novo.

## Evidência

Suite completa G0–G1.4 passou; G1.5 passou inicialmente 128 checks na suite e, após ampliar interação/resoluções, 136 checks isolados, zero falhas. Testa plantio, estágios, primeira/segunda/última colheita, recuperação serializada em JSON, estoque, fertilizantes/cuidados, replay, falha de gravação, eventos, importações reais em subprocesso e arquivos originais preservados. UI validada em 1920×1080, 1080×1920, 1280×720 e 720×1280, com eventos mouse/toque. Importação headless/editor sem parsing errors.

Trinta simulações de serviço real em três dias; resultados e limitações em [G15_BALANCE.md](G15_BALANCE.md). Vinte capturas reais com Godot 4.7.2 Compatibility / RX 7600 em PC e retrato, fixtures isoladas; inspeção visual do contexto em recuperação e loja especial. Não são mockups nem imagens retocadas.

## Arte e pendências

Atlas raster original, sprites distintos e dois frames de abóbora; origem, prompt, hash e restrições em [G15_ART_REPORT.md](G15_ART_REPORT.md). Status ART_REVIEW, não arte final nem licença de distribuição aprovada. Preservada a arte anterior. Restam direção artística humana, consistência de detalhe/alpha/estágios, áudio final, celular físico, acessibilidade ampliada, balanceamento de longo prazo e autoridade/segurança online. Não foi medido orçamento de desempenho em aparelhos reais; capturas não certificam FPS mobile.

Guia executável: [G15_TEST_GUIDE.md](G15_TEST_GUIDE.md). Nenhum avanço para G1.6/G2.
