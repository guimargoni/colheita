# G1.4 — integração histórica e aceite anterior

2026-10-24. O novo briefing declara **G1.3 aprovado funcionalmente** pelo diretor.
Implementação aceita: `62112b1`. O marco local `milestone/g1.3-mechanics-approved`
preserva esse runtime com este registro documental antes de implementar G1.4.
Acabamento artístico, áudio final, aparelho físico, segurança online e balanceamento
final continuam pendentes. O aceite funcional não amplia licenças ou aprova release.

## Origem e integração seletiva

Remote `origin`: `https://github.com/guimargoni/colheita.git`.
`git fetch origin foundation/game-design` atualizou `85cc8a9` →
`1d1dd8e2e27f271f9e338b64ab9bd1c0f8ca96de` com sucesso. A primeira tentativa restrita
falhou por resolução de rede; a busca autorizada funcionou. Não há blocker remoto.

Dois documentos novos foram copiados integralmente por `git show` desse commit:

- `G1H_HISTORICAL_AUDIT.md`, introduzido em `1d1dd8e`.
- `EMOTIONAL_DESIGN_PILLARS.md`, introduzido em `cd4ee3e`.

São os únicos documentos adicionados na linha remota desde a base comum; comparação
por três pontos dos demais documentos não mostrou novas mudanças. Arquivos existentes
mais recentes — GDD, roadmap, decisões, arquitetura, UX, áudio, economia, progressão,
manifestos e contratos artísticos — foram preservados. **Sem merge, cherry-pick,
conflito ou regressão documental por substituição de arquivos antigos.**

A matriz histórica é um snapshot de pesquisa: seus estados “pendente/G1.3 parcial”
refletem a data da autoria, não status atualizado de execução. Seus rótulos de
confiança pertencem à pesquisa original; esta integração não é nova verificação
independente das URLs nem certificação de completude histórica.

## Aplicação ao G1.4

H-010: terrenos bloqueados e conquista de capacidade, com moedas comuns/progressão.
A mecânica é o alvo; a pequena curva de preços e o número de parcelas da amostra
serão hipóteses de desenvolvimento explicitamente identificadas, não números
históricos ou contagem final do jogo. Nenhuma moeda premium, terra vermelha,
expansão moderna, construção ou produção animal será implementada.

Reconstrução histórica passa a ter prioridade; modernizações de sistemas são
posteriores, sem adiar acessibilidade, segurança ou código/arte originais. H-007
registra XP histórico também em outras ações: o G1.3 aceito concede somente na
colheita. Essa diferença é preservada, não corrigida silenciosamente no G1.4.
G1.5/G2 e as sugestões de gates da auditoria não estão autorizados.
