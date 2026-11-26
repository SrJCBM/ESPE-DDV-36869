# Arte de la historia (I5-10)

Las cinemáticas y las conversaciones ya hacen referencia a estas imágenes por su id. Mientras falte un archivo, el juego dibuja un recuadro de «Ilustración pendiente» con su id y su descripción. En cuanto se guarda el archivo con el nombre correcto, aparece sin cambiar ningún guion.

| Carpeta | Nombre del archivo | Uso |
| --- | --- | --- |
| `ilustraciones/` | `<id>.webp`, por ejemplo `taller_ferrer.webp` o `cg_invitacion.webp` | Fondos y CG a 1920 × 1080 o mayor, en 16:9 |
| `retratos/` | `<personaje>_<expresion>.webp`, por ejemplo `anfitriona_seria.webp` o `custodio_duelo.webp` | Recortes de 900 × 1200 con transparencia. Si falta una expresión, se usa el recorte neutral cuando existe y, como último recurso, el retrato general |

Los recortes se muestran directamente sobre el escenario, sin panel de fondo. Los nombres de los retratos de los visitantes incluyen la etapa de porcelana, por ejemplo `amparo_triste_p2.webp`.

Los ids, las descripciones y las indicaciones para generarlas están en [ILUSTRACIONES_PENDIENTES.md](../../Diseno/ILUSTRACIONES_PENDIENTES.md). Las conversaciones que las usan están en `datos/dialogos/` (`prologo.tres`, `llegada_vestibulo.tres`, `recaudador.tres` y `coleccionista.tres`, entre otras).
