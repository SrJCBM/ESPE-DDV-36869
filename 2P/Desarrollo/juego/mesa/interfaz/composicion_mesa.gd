extends RefCounted
## Distribución de la mesa sobre el lienzo de 1440 × 810 (I4-05, recompuesta en I6-04). Reúne las
## medidas en un solo lugar para que mesa_ui.gd solo conecte componentes. A 1024 × 576 todo se
## escala por 0,711.

## Columna central. El tapete y las cartas ganan el espacio que ocupaba la fila fija de patrones.
const NOMBRE := Rect2(429, 108, 610, 62)
const ESTADO := Rect2(431, 170, 360, 26)
## Patrón cercano junto a la mano (p. ej., «Mano larga · 4/5»), alineado a la derecha del estado.
const CERCANO := Rect2(800, 170, 320, 26)
const TAPETE := Rect2(390, 196, 740, 400)
const MANO := Rect2(410, 210, 700, 372)
## Alto de una carta a tamaño completo (hasta tres). Con cuatro o cinco se reducen con su
## proporción para verse enteras; desde la sexta, la mano se desplaza (mano_mesa.gd).
const ALTO_CARTA := 300.0
## Lectura de la mano en una sola línea bajo el tapete: intervalo o suma junto al umbral.
const LECTURA_TITULO := Rect2(431, 606, 160, 40)
const LECTURA := Rect2(590, 604, 200, 44)
const EXPLICACION := Rect2(792, 604, 190, 48)
const RESULTADO := Rect2(431, 600, 540, 40)
const RESULTADO_DETALLE := Rect2(432, 638, 540, 26)
## Consulta de patrones: un botón al final de la lectura abre la franja en el mismo lugar.
const CONSULTA := Rect2(990, 610, 132, 34)
const FRANJA := Rect2(420, 602, 702, 62)
const PATRONES := Rect2(431, 609, 680, 48)
const DETALLE := Rect2(432, 672, 684, 44)
## Con la consulta abierta, el botón pasa a la línea de detalle y el texto se acorta.
const CONSULTA_ABIERTA := Rect2(990, 676, 132, 34)
const DETALLE_CONSULTA := Rect2(432, 672, 548, 44)
## Columna derecha: dial, boleto compacto y acciones apiladas con el mismo ancho.
const DIAL := Rect2(1222, 104, 166, 166)
const ETIQUETA_DIAL := Rect2(1190, 292, 240, 26)
const BOLETO := Rect2(1157, 330, 238, 150)
const BOLETO_TITULO := Rect2(1180, 350, 195, 20)
const BOLETO_PUNTOS := Rect2(1181, 372, 196, 52)
const BOLETO_BARRA := Rect2(1182, 434, 192, 5)
const DESGLOSE := Rect2(1157, 494, 238, 34)
const PEDIR := Rect2(1157, 560, 238, 64)
const PLANTARSE := Rect2(1157, 636, 238, 64)
