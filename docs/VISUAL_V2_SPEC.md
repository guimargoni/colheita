# Fundação visual integrada v2

2026-10-28. Missão expressa de reestruturação visual; base `faa22bf`, branch `feature/integrated-visual-foundation`. Cena e launcher principais mantidos. Baseline: regressões integradas e social PASS antes das mudanças.

Separar estado funcional, contrato de aparência, resolvedor tema/skin, renderizadores por família, relógio/animação e efeitos/áudio. Manifesto visual versionado com fontes, fallback explícito, footprint/pivô estáveis; nomes de PNG nunca entram nos IDs de domínio. Preferências cosméticas locais independentes do save econômico, inclusive preview de visitas. Tema não é evento; nenhum tema concede sementes ou recompensa.

Padrão e Halloween demonstrativo com arte própria e fallback documentado. Skin individual da casa não muda dimensão ou alvo. Projeção ortográfica 2:1, paredes verticais, contato no solo, luz superior esquerda, sombra inferior direita; sem skew dos sprites para fingir perspectiva. Normalizar tamanho preservando proporção do recorte; inspeção humana ainda necessária.

UI nativa Godot: dock de ferramentas ilustradas, carteira compacta, cards reutilizáveis, estados/foco, contextualização, menus menores. Sem emojis ou substituição de entidades por geometria. Transições/FX não autorizam recompensas e respeitam movimento reduzido.

Ampliação parametrizada para 16 parcelas, quatro iniciais, preços/níveis progressivos provisórios. Preservar oito IDs/coordenadas/custos antigos, saldo, ciclos e histórico. Migração aditiva validada e persistida atomicamente antes do uso; falha não publica candidato. Sem alterar cenas antigas. Não adicionar pesca: apenas planejar área, contratos de produção/inventário/raridade e limites futuros.

Aceitação: trocar tema/skin sem reconstruir cena ou alterar snapshot; planta madura clara com FX zero; ação/hover/gesto e visitas preservados; roundtrip de save antigo ampliado sem perdas ou recompensa duplicada; fallback conhecido; animação por segundos e fases independentes; captura real PC/retrato e vídeo, benchmark com intensidades distintas. Resultado artístico sujeito a checklist humano, separado dos testes.
