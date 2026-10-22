# Contrato de skins — cozy.iso.v1

G0.5-R, proposto. Skin é apresentação, não licença para mudar ocupação ou regras.
Identidade do plot, acesso, crescimento e hit area permanecem fora do material.

Obrigatório por variante: id, versão de contrato, source/author/license/status,
canvas, pivô, footprint, sockets nomeados, bounds máximos, shadow anchor,
estados/direções/frames disponíveis e fallback explícito. Igualdade obrigatória de
footprint, pivô e sockets; bounds podem variar **dentro** do envelope aprovado.
Sombra mantém direção/luz e contato. Trocar skin não desloca canteiro, caminho,
cerca, seleção ou câmera, nem altera custo, tempo ou produção.

Camadas: chão; base/bordas; cultura; objeto alto; sombra; VFX/marcador. Culturas
não incluem moldura do canteiro. Fallback por família completa; não misturar uma
casa hiper-realista com personagens simplificados para preencher lacuna.
Skins que exigem novo footprint são outro tipo de objeto, com aprovação própria.

Pilotos de catálogo: `cozy.base` NOT_PRODUCED e `cozy.autumn` PALETTE_TEST_ONLY.
O botão Paleta no laboratório apenas aplica tint ao comparador antigo; **não é
uma skin sazonal entregue**. Geometria/IDs são os mesmos antes/depois. Variação
de neve, vegetação e objetos exige desenhos próprios e teste de oclusão.

QA futuro: comparar malha/hit map e sockets antes/depois, todos os estados e
arranjos densos, contraste de locked/empty/mature, câmera desktop/retrato. Nenhuma
skin final é aprovada nesta etapa. Valores desse contrato ficam no JSON e testes;
assets reais terão metadados de instância antes da promoção.
