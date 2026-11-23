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
