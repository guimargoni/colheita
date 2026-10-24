# G1.2 — validação humana das mecânicas

Data: **2026-10-24**. Responsável pelo aceite: diretor criativo, por instrução
explícita nesta conversa: “registre a validação humana do G1.2 e preserve o estado
atual como marco aprovado”. Este registro documenta a declaração do diretor;
não presume um roteiro de testes manuais que não foi informado.

**Mecânicas G1.2: APROVADAS HUMANAMENTE.**

## Estado preservado

- Branch: `feature/g1-2-crop-care`.
- Implementação aprovada: `5300061` (`feat: add G1.2 crop care and contextual growth status`).
- Marco local: tag anotada `milestone/g1.2-mechanics-approved`, apontando para o
  commit deste registro e das atualizações de status, com runtime idêntico a `5300061`.
- Nenhuma alteração de código, configuração, assets ou saves integra este aceite.
  G1.1 e os gates artísticos anteriores permanecem preservados. Sem push.

## Escopo do aceite

Mecânicas locais entregues no G1.2: plantio e colheita direta, rega, ervas/pragas
com recuperação, fertilizantes funcionais e limites de uso, proteção de uso único
do Super, cartão contextual de crescimento, gestos de cuidado e persistência local.
Amor continua reservado e desabilitado. O aceite não cria sistemas adicionais.

O relatório técnico e o registro de execução documentam o PASS original de
176 checks G1.2, regressões anteriores, nove simulações e 18 capturas reais do Godot.
Esses resultados são evidência técnica da entrega, separada da aprovação humana.
A atualização documental não representa nova execução desses testes de gameplay.

## Pendências que continuam abertas

| Área | Situação após o aceite |
|---|---|
| Acabamento artístico | Pendente; sprites, animações e FX provisórios mantêm seus estados de revisão. |
| Áudio final | Pendente; pontos de integração não equivalem a masters aprovados. |
| Celular físico | Pendente; capturas em retrato e gestos simulados não certificam aparelho real, desempenho ou conforto. |
| Segurança online | Pendente; não implementada/certificada. Relógio, RNG e saves locais não são autoridade confiável de produção. |
| Balanceamento definitivo | Não aprovado; parâmetros e estoques de desenvolvimento permanecem provisórios. |
| Licenças e distribuição | Nenhuma autorização ampliada; revisão de assets e flags de release permanecem como estavam. |

A aprovação é das mecânicas deste protótipo local. Não é aprovação geral de arte,
áudio, experiência em hardware móvel, segurança, economia definitiva ou release.

## Limite de continuidade

Parar no G1.2 e aguardar nova orientação. Este marco não autoriza G1.3, G2,
economia definitiva, multiplayer nem alterações nos gates anteriores.

Referências: [relatório técnico](G12_TECHNICAL_REPORT.md),
[registro histórico de execução](G12_EXECUTION_RECORD.md),
[guia de teste](G12_TEST_GUIDE.md), [arte e áudio](G12_ART_AND_AUDIO.md),
[balanceamento](G12_BALANCE.md) e ADR-016 em [DECISIONS](DECISIONS.md).
