# Arte de I4 · Sellos, fichas y mesa del Custodio

Las piezas se generaron con la herramienta integrada ImageGen para La Última Mesa. Se conservan los originales PNG con alfa y las versiones optimizadas para Godot. La paleta y los materiales siguen la [dirección artística](DIRECCION_ARTISTICA.md).

| Pieza | Original | Archivo para Godot | Tamaño |
| --- | --- | --- | --- |
| Sello del Custodio | [Tríptico](recursos/i4/sellos_original.png) | [Reloj](../juego/recursos/hud/sello_custodio.png) | 256 × 256 |
| Sello del Recaudador | Mismo tríptico | [Balanza](../juego/recursos/hud/sello_recaudador.png) | 256 × 256 |
| Sello de la Coleccionista | Mismo tríptico | [Vitrina](../juego/recursos/hud/sello_coleccionista.png) | 256 × 256 |
| Ficha del casino | [PNG](recursos/i4/ficha_original.png) | [Ficha](../juego/recursos/hud/ficha_casino.png) | 256 × 256 |
| Tapete del Custodio | [PNG](recursos/i4/tapete_original.png) | [Tapete](../juego/mesa/arte/tapete_custodio.webp) | 1152 × 768 |
| Aro de campanadas | [PNG](recursos/i4/dial_aro_original.png) | [Aro](../juego/mesa/arte/dial_campanadas_aro.png) | 384 × 384 |
| Base de campanadas | [PNG](recursos/i4/dial_base_original.png) | [Base](../juego/mesa/arte/dial_campanadas_base.png) | 384 × 384 |

- Los sellos se cortaron en tercios iguales del tríptico. Usar las tres imágenes en orden, con el mismo tamaño. Los huecos pueden usar su silueta en relieve tenue y una indicación de estado.
- El dial usa la base debajo, el aro encima y las cifras en un control independiente. Las dos capas coinciden en un lienzo común con pivote en **(192, 192)**. Animar solo el aro. Las marcas grabadas son ornamentales y el contador nativo comunica la cantidad real.
- El tapete conserva el centro oscuro para la mano. La prueba de composición lo encuadra entre el título y la franja de patrones, en `Rect2(390, 203, 740, 342)` sobre el lienzo de 1440 × 810. Las cartas quedan delante y el borde termina antes de la franja. El saldo, las cifras y los nombres se componen en Godot.
- La ficha y las capas del dial se recortaron y centraron. El tapete se redujo a WebP con alfa. Los originales son arte generado para este repositorio.

## Pedido · corredor según el plano

**Para Julio.** El fondo actual de `juego/casino/arte/corredor.webp` (1672 × 941) tiene seis puertas al norte y solo una barandilla al sur. La diapositiva «Plano del casino» pide cuatro mesas al norte y el vestíbulo y la tienda al sur. Mientras tanto el juego apaga las dos puertas de la izquierda y dibuja dos vanos provisionales sobre la barandilla.

- **Norte.** Cuatro puertas de mesa en las posiciones actuales de las puertas 3 a 6 (ejes a 538, 739, 940 y 1141 px sobre 1280 de ancho): verde acolchada, roja, violeta y la del amanecer. Donde hoy están las dos primeras puertas, pared con apliques o una vitrina, sin puertas.
- **Sur.** Dos aberturas en la barandilla, bajo las puertas I y II (ejes a 538 y 739 px): el vestíbulo, con un arco de recepción y luz cálida, y el Gabinete de la anfitriona, con una vitrina visible al fondo. Deben leerse como salidas hacia el espectador, sin texto.
- **Se conserva.** Encuadre, perspectiva, alfombra roja, suelo de mármol, paleta y tamaño de 1672 × 941. Sin letreros ni números: placas, luz y candados se componen en Godot.
- **Entrega.** PNG original en `Diseno/recursos/i4/` y WebP en el mismo `corredor.webp`. Si los ejes cambian, basta con ajustar `PUERTAS` en `casino/exploracion/plano_galeria.gd`.

> Original reusable game background for La Última Mesa, a supernatural late-Victorian casino. Dark forest emerald, aged brass, subdued amber, restrained fine copperplate hatching. No text, letters, numerals, signatures or logos. Same camera, perspective, red carpet runner and green marble floor as the existing gallery corridor. The far (north) wall holds exactly four ornate arched doors evenly spaced on the right two thirds: green tufted leather, deep red lacquer, violet stained glass, and a dark sunrise-ray door; the left third is wall with brass sconces and a glazed cabinet, no doors. The near (south) brass balustrade is interrupted by two open archways on the left half, aligned under the first two north doors: a warmly lit reception arch and a doorway revealing a curiosity cabinet. Wide landscape 16:9, flat even composition for a walkable 2D top-down room.

## Prompts de generación

### Tríptico de sellos

> Original reusable game UI art for La Última Mesa, a supernatural late-Victorian casino. Dark forest emerald, aged brass, subdued amber, restrained fine copperplate hatching. No text, letters, numerals, signatures, logos, mockup or UI controls. True alpha outside the art, no checkerboard or background. Flat orthographic front/top view. Premium hand-engraved detail that reads at gameplay size. Generate ONE coherent horizontal triptych artwork for three unlockable progression seals. Three square brass relief plaques, left to right: an antique clock face with hands but no digits; a clearly recognizable symmetric scale balancing two hanging pans; a small glazed cabinet displaying a fan of playing cards. All three the same visual scale and proportion, individually recognizable at 42 px. Each has a simple thin squared brass plate, green-black interior, subtle relief, and unified decorative framing. Three distinct isolated square tiles centered at exactly one sixth, one half, five sixths of the image width, all centered vertically, evenly spaced with generous transparent gutters and outer clearance, each wholly contained in its own third. One straight row only, maximum landscape width. The equal three slots form a visually continuous set when joined. Keep the clock without Roman numerals.

### Ficha del casino

> Original reusable game UI art for La Última Mesa, a supernatural late-Victorian casino. Dark forest emerald, aged brass, subdued amber, restrained fine copperplate hatching. No text, letters, numerals, signatures, logos, mockup or UI controls. True alpha outside the art, no checkerboard or background. Flat orthographic front/top view. Premium hand-engraved detail that reads at gameplay size. Single compact icon of a round antique casino token for a balance HUD, straight-on, clear silhouette, six cuts in an aged brass rim, dark emerald enamel inside, with a small engraved four-point diamond at center. Warm directional lighting, high value contrast across the rim, tactile slightly worn texture, readable at 28 px. One token centered on square canvas with clear alpha margin, absolutely no digits or glyphs, no contact shadow or extra coin.

### Tapete del Custodio

> Original reusable game UI art for La Última Mesa, a supernatural late-Victorian casino. Dark forest emerald, aged brass, subdued amber, restrained fine copperplate hatching. No text, letters, numerals, signatures, logos, mockup or UI controls. True alpha outside the art, no checkerboard or background. Flat orthographic front/top view. Premium hand-engraved detail that reads at gameplay size. Create an empty top-down oval gaming table mat, landscape close to 3:2. As an isolated UI backdrop behind cards, it is a subtly lit dark forest-green (#0B2119) felt oval with a thin double border and sparse engraved aged-brass flourishes along the perimeter, with a few understated clockwork details at the top and bottom. The entire inner 75 percent is nearly plain, uniform dark green with extremely faint worn felt fibers, so cards and text will dominate. Seamless low-contrast tonal transitions, restrained antique casino, perfectly front-on, no perspective, no furniture, no legs, no props, no portrait, no cards. Full oval centered with transparent margins, no drop shadow outside.

### Aro de campanadas

> Original reusable game UI art for La Última Mesa, a supernatural late-Victorian casino. Dark forest emerald, aged brass, subdued amber, restrained fine copperplate hatching. No text, letters, numerals, signatures, logos, mockup or UI controls. True alpha outside the art, no checkerboard or background. Flat orthographic front/top view. Premium hand-engraved detail that reads at gameplay size. Create a rotational countdown HUD overlay: a perfectly centered, perfectly circular OPEN annular ring like the brass bezel of a late-Victorian timepiece. RIM ONLY: the entire circular interior is a true transparent alpha hole at least 74 percent of outer diameter, as are the outer corners. A slender antique brass outer edge with ten clean evenly spaced inset tick marks, a few unobtrusive engraved details and a warmer top marker. Keep thickness consistent and symmetrical, designed to spin around exact center. No clock face, fill, center, hands, dials, digits or numerals. Transparent square image.

### Base de campanadas

> Original reusable game UI art for La Última Mesa, a supernatural late-Victorian casino. Dark forest emerald, aged brass, subdued amber, restrained fine copperplate hatching. No text, letters, numerals, signatures, logos, mockup or UI controls. True alpha outside the art, no checkerboard or background. Flat orthographic front/top view. Premium hand-engraved detail that reads at gameplay size. Create the independent background layer for a round HUD clock dial: one perfectly circular centered flat disk of very dark emerald-green enamel with barely visible subdued engraved radial grain and a dark thin recessed edge. It sits under a separately rendered brass ring and bright numbers. About 85 percent of the disk interior stays dark uniform. No ring-shaped metal bezel, no marks, hands, numerals, divisions, indicators, highlights or words. True transparent outer corners, square frontal output.
