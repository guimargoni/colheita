# Canteiros modulares e expansão da propriedade

G0.5-R. Preparação artística/contratual; **nenhum sistema de desbloqueio implementado**.
Quantidade inicial/final, custos, requisitos de nível e ritmo de expansão continuam
indefinidos (`null` no contrato) e exigem decisão documentada do diretor.

## Separação de dados

Identidade: célula/plot_id estáveis. Layout: posição, footprint, região e rota.
Acesso: locked/available, futura autoridade servidor. Cultivo: empty/planted/
growing/needs_water/mature, sem misturar com acesso. Skin: material visual.
Estado indisponível não deve receber ação agrícola mesmo que a textura mostre
solo. Fixture do laboratório usa um estado simplificado só para inspeção.

Uma grade pode acomodar dezenas de canteiros, regiões bloqueadas, alamedas,
construções e decoração. Expansão acrescenta posições/regiões, não renumera tudo.
Personalização futura respeita ocupação e sockets; não há editor de layout neste gate.

## Kit de desenho a produzir antes de substituir

1. Base 64×32 em projeção 2:1 num canvas 72×64, pivô (36,48).
2. Solo e borda separados das plantas; quatro sockets fixos no chão. Estágio não
   deve mudar contorno do footprint. Não embutir a moldura em cada cultura.
3. Bordas N/E/S/W com vizinhança (mask 4 bits), variante isolada, terminal e
   canto. Bordas compartilhadas desenhadas uma vez; evitar espessura dupla.
4. Caminho, cerca e transição grama/solo usam a mesma malha. Folhas podem exceder
   base; extensão máxima no contrato para testar oclusão em arranjos densos.
5. Estados visualmente distintos sem depender só da cor: vazio com sulcos;
   plantado com sementes; crescendo com massa verde; sede com ícone; maduro com
   fruto e marcador; bloqueado com sinal/borda e vegetação não cultivada.

Atlas G0.5 já traz solo+planta na mesma célula, margens e bases variáveis. É
**comparador provisório**, não kit modular pronto. Guias do laboratório mostram
base ideal e tornam desvios visíveis; não escondem folgas ajustando zoom.

## Teste de arranjos

Fixtures: bloco compacto 4×4, denso 8×8 e regiões com alamedas numa grade 12×12.
Só uma parcela aparece disponível na fase visual cedo; tarde muda a fotografia
de estados, sem comprar/desbloquear nada. Existem 16, 64 e 100 posições nos três
arranjos atuais; são cargas de QA descartáveis, não decisões de produto.
Testes verificam IDs, centros, bordas semiabertas, contagem, região bloqueada,
conexão nas duas direções e invariância ao variar palette/fixture extent.

Aceite artístico posterior: sem fresta ou linha dupla a 1×/4×, caminhos contínuos,
raízes sempre sobre solo, estados legíveis em 20 toques e sem colisão de sockets.
Teste estrutural passar não certifica pixels ou bordas do atlas antigo.

## Interação futura compatível

Reutilizar o árbitro G0.4 (tap/hold/paint/pinch), trocar o picker por índice
espacial de footprints/IDs quando autorizado. Acesso é filtro antes da ação;
arrasto deduplica IDs, câmera nunca age em solo. Não usar índices 0..3 ou 0..15
como contrato de rede. Nesta entrega laboratório só inspeciona; G0.4/G0.5 mantêm
suas interações originais. Custos/economia/backend continuam fora do escopo.
