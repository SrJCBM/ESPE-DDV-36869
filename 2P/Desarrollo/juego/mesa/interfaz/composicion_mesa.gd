extends RefCounted
## Distribución de la mesa sobre el lienzo de 1440 × 810 (I4-05). Reúne las medidas en un solo
## lugar para que mesa_ui.gd solo conecte componentes. A 1024 × 576 todo se escala por 0,711.

## Columna central: el tapete gana el espacio que dejaban los botones.
const NOMBRE := Rect2(429, 108, 610, 62)
const ESTADO := Rect2(431, 170, 680, 26)
const TAPETE := Rect2(390, 196, 740, 360)
const MANO := Rect2(420, 212, 680, 330)
const ALTO_CARTA := 262.0
## Lectura de la mano en una sola línea bajo el tapete: intervalo o suma junto al umbral.
const LECTURA_TITULO := Rect2(431, 560, 160, 40)
const LECTURA := Rect2(590, 558, 235, 40)
const EXPLICACION := Rect2(827, 558, 284, 48)
const RESULTADO := Rect2(431, 552, 680, 40)
const RESULTADO_DETALLE := Rect2(432, 588, 680, 26)
## Franja oscura de patrones al pie de la columna central y su espacio de detalle.
const FRANJA := Rect2(420, 618, 702, 60)
const PATRONES := Rect2(431, 624, 680, 48)
const DETALLE := Rect2(432, 684, 684, 44)
## Columna derecha: dial, boleto compacto y acciones apiladas con el mismo ancho.
const DIAL := Rect2(1222, 104, 166, 166)
const ETIQUETA_DIAL := Rect2(1190, 292, 240, 26)
const BOLETO := Rect2(1157, 330, 238, 150)
const BOLETO_TITULO := Rect2(1180, 350, 195, 20)
const BOLETO_PUNTOS := Rect2(1181, 372, 196, 52)
const BOLETO_BARRA := Rect2(1182, 434, 192, 5)
const DESGLOSE := Rect2(1157, 494, 238, 34)
const PEDIR := Rect2(1160, 560, 230, 64)
const PLANTARSE := Rect2(1160, 636, 230, 64)
