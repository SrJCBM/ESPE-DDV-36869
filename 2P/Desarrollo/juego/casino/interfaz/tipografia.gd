class_name Tipografia
extends RefCounted
## Tamaño mínimo de letra en el lienzo de 1440 × 810 (revisión de interfaz, 27 nov 2026). A 1080p
## equivale a unos 21 px, por encima de los 18 px que piden las guías de accesibilidad para PC.
## Las fábricas de rótulos (Libro.rotulo, Piezas.etiqueta, Piezas.boton_texto) lo aplican solas;
## un texto decorativo que deba ser menor (el valor impreso en una carta) no pasa por ellas.

const MINIMA := 16

static func tamano(puntos: int) -> int:
	return maxi(puntos, MINIMA)
