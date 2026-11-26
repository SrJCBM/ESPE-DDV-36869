# Iteración 06 · Lectura y presencia narrativa

**Objetivo.** Que el jugador reconozca desde la portada que entra a una novela visual y pueda explorar, comprar y jugar una mano con la información necesaria para cada decisión. La campaña jugable de [I5](ITERACION_05.md) es la base.

## Entregas

| ID | Entrega | Estado | Cómo comprobarla |
| --- | --- | --- | --- |
| I6-01 | Portada ilustrada | Implementada y verificada | La invitación y la llegada de Klein a Corvera alternan con un fundido cada 14 s. «Entrar al casino» o «Continuar» conserva el foco mientras cambia la imagen. El ajuste de movimiento reducido deja el fondo fijo. Se revisó con y sin partida guardada. |
| I6-02 | Visitantes en sus salas | Colocación inicial implementada | Amparo y los jugadores de porcelana están en el vestíbulo, Tobías en el pasillo del Custodio y Benavides en el del Recaudador. El ajuste de proporciones, anclaje y sombras está en I6-09. |
| I6-03 | Lectura accesible y ayuda breve | Implementada y verificada | Los siete recursos de diálogo conservan libre la barra inferior al 140 %. «Cómo jugar» reúne movimiento, mano y salida en tres bloques breves. El recorte de la cara de Ignacio y las superposiciones de otras pantallas se registran en I6-08. |
| I6-04 | Composición y lectura de la mesa | Por implementar | Redistribuir la mesa según el estado de la mano. Dar protagonismo a las cartas, mantener visible el coste real y ofrecer los patrones en una consulta breve. Ver [alcance de la mesa](#i6-04--composición-y-lectura-de-la-mesa). |
| I6-05 | Inventario, baraja, vitrina y recompensa | Por implementar | Presentar fichas, sellos y objetos con sus ilustraciones. Usar un álbum de cartas por palos con detalle al enfocar. En la vitrina se leen el precio y el estado de las piezas. En la recompensa, las tres cartas y «Omitir» tienen espacio propio. |
| I6-06 | Encuentros de exploración | Propuesto | Dar un diálogo breve a Amparo, Tobías y Benavides con las líneas de la sección 10 del guion. Sobre su figura, la pista de E aparece por proximidad. Usar la porcelana para indicar su evolución por sellos cuando esa parte del guion se conecte. Coordinar con los menús posvictoria de I5-11. |
| I6-07 | Prueba del recorrido y la lectura | Pendiente | Pedir a tres personas que abran una partida, lleguen al Custodio, resuelvan una Máscara, encuentren la tienda y expliquen qué cambiaría una compra. Anotar dónde se detienen, qué dato buscan y si necesitan abrir la ayuda. |
| I6-08 | Superposiciones y encuadre | Implementada y verificada · rama `kenned/i6-correcciones` | El panel compartido mide título y párrafo antes de colocar cartas y botones, y crece si hace falta. «Nuevo intento» en la derrota. El coste de la mesa va en su propia línea. La toma de Ignacio ya no muestra la cara recortada. Ver [avance de I6-08](#avance-de-i6-08). |
| I6-09 | Escala y anclaje de sprites | Por implementar | Revisar las figuras al lado de Klein, de una puerta y del mobiliario. Ajustar pivote, perspectiva, colocación, sombra y huella de colisión en la misma pasada. |
| I6-10 | Reacciones de los crupieres durante la mano | Primer tramo implementado · rama `kenned/i6-reacciones` | El Custodio comenta Punto exacto, Al filo, Quiebra y la cercanía a la meta en un bocadillo junto a su retrato, sin pausar la mano ni quitar el foco. Ver [avance de I6-10](#avance-de-i6-10). |
| I6-11 | Derrota ilustrada | Encuadre propuesto · arte de Julio | Encuadre de `cg_derrota_manos` en [ILUSTRACIONES_PENDIENTES.md](Diseno/ILUSTRACIONES_PENDIENTES.md#cg_derrota_manos--fin-del-intento-i6-11-guion-144): las manos de Klein volviéndose porcelana sobre el tapete, con la vitrina vacía al fondo. La secuencia se monta cuando llegue el arte. |

## Revisión de las pantallas

| Pantalla | Hallazgo | Próximo ajuste |
| --- | --- | --- |
| Inicio | El panel verde sobre el vestíbulo oscurecido podía pertenecer a cualquier menú. | La portada ya usa dos momentos del prólogo, con título y primera acción en la zona oscura izquierda. |
| Mesa | En el Recaudador, «−1 campanada» se superpone a «Iniciar mano». En la mano activa cinco patrones compiten con las cartas y el total. | Separar nombre, tecla y coste. En reposo, encuadrar el tapete y la primera acción. Con cartas, poner el total y el posible riesgo junto a la mano. |
| Oferta de la Anfitriona | La escena tiene retrato y atmósfera. Las explicaciones de cada objeto pueden ensanchar la lista de opciones. | Enseñar los tres iconos y un efecto al enfocarlos. Verificar el cuadro con los tres objetos, teclado y texto al máximo. |
| Inventario | Los sellos se describen en una frase larga que invade «Ver baraja». | Usar los tres sellos ilustrados, el contador de fichas y fichas visuales para los objetos. Dar un acceso visible a la baraja y mostrar el efecto del objeto enfocado. |
| Vitrina y baraja | La vitrina ya distingue las piezas. La baraja repite el palo en cada carta y el resumen ocupa un lateral de texto. | Dejar una cabecera ilustrada por palo y una página o cuadrícula con el valor visible. Mostrar el detalle ganado o ajustado al enfocar. Probar una baraja ampliada y preservar los datos ocultos de una mano en curso. |
| Recompensa | El párrafo de victoria queda detrás de la fila de cartas. El panel comparte con inventario y derrota una lista que arranca a altura fija en `libro.gd`. | Medir el alto del encabezado y el cuerpo antes de ubicar las acciones. Dar al jefe una intervención propia y mostrar en la recompensa el saldo ganado, la elección y «Omitir». |
| Escenarios | En el vestíbulo, el piano y las figuras se leen como recortes pequeños en medio del mármol. Benavides y el banco parecen aislados en el pasillo. El vano rectangular del vestíbulo sobresale del arte. | Colocar el piano junto a un muro y a un punto de luz, situar la mesa de jugadores en un lateral y acercar el banco de Benavides a un tramo de pared con espacio para las piernas. Revisar el vano como parte del fondo. Mantener el corredor y los umbrales despejados. |
| Diálogo | El texto al 140 % ya conserva libre la barra. En la toma de Ignacio, el recorte de la cara aparece incompleto en el pie mientras su figura grande ya está en escena. | Mostrar a Ignacio mediante su figura y la placa del nombre en esa toma. Cuando se necesite el recorte pequeño, reservarle un área que no cruce la barra y verificar también el rostro del Dueño y la Anfitriona. |
| Derrota | «La Casa gana» reutiliza el panel genérico. El botón tapa el párrafo y dice «Volver al vestíbulo», aunque el flujo actual reinicia en la entrada. | Aplicar I6-08 al aviso compartido. En I6-11, contar la transformación en porcelana y usar una acción que describa el paso real, como «Nuevo intento». |

## I6-04 · Composición y lectura de la mesa

La mesa se organiza por lo que el jugador puede decidir en cada momento. En la espera tiene el arte del crupier y el tapete, el objetivo de la mesa, las campanadas y **Iniciar mano**. Durante la mano se priorizan las cartas, la suma o el intervalo de las Máscaras, el umbral y **Pedir / Plantarse**. El coste de iniciar o pedir se muestra como una ficha breve con icono y cantidad en su propio espacio. En el Recaudador se conserva el saldo a la vista.

La fila fija de cinco patrones pasa a una consulta accesible por foco y teclado. Junto a la mano cabe, por ejemplo, **Mano larga · 4/5** cuando ese progreso ayude a tomar una decisión. Al plantarse se muestra el resultado y los patrones obtenidos en el desglose. Las cartas, el retrato y el tapete ganan superficie cuando hay espacio. A 1024 × 576, las cartas de una mano larga conservan tamaño legible mediante el desplazamiento horizontal. Se comprueba también a 1280 × 720, 1920 × 1080 y en una ventana panorámica. Las reglas y su balance son los de la campaña actual.

## Avance de I6-08

Implementado por Kenned el 26 de noviembre de 2026 en la rama `kenned/i6-correcciones`, que parte de `8afcc6d`.

| Pantalla | Causa | Corrección |
| --- | --- | --- |
| **Recompensa, inventario y derrota** | En `libro.gd` el párrafo tenía 124 px fijos desde y = 118 y la lista empezaba siempre en y = 196. Un párrafo de más de tres líneas quedaba detrás de las cartas o de los botones | El panel mide el título y el párrafo con la fuente real antes de colocar la lista. Crece centrado hasta 770 px si las cartas y los botones no caben, y si aun así no caben, la lista se desplaza. Las etiquetas reciben su ancho antes del texto, para que el salto de línea no las estire |
| **Derrota** | La acción decía «Volver al vestíbulo», pero el juego reinicia en la entrada | La acción es **Nuevo intento** |
| **Mesa** | En el botón de 230 px, el título iba de x = 46 a 156 y el coste, alineado a la derecha, de 118 a 218, así que «−1 campanada» pisaba «INICIAR MANO» | Con coste, el nombre ocupa la mitad superior y el coste la inferior, debajo del nombre. Sin coste, el nombre queda centrado. Vale también para «PEDIR / −1 ficha» en el Recaudador |
| **Prólogo, toma de Ignacio** | La cara pequeña se recortaba de la parte alta del retrato y llegaba hasta la barra de Historial, Auto y Saltar | Si quien habla está en escena, su figura y la placa con su nombre lo identifican, así que no se muestra la cara. Cuando habla alguien fuera de escena, la cara mide 88 px y termina 18 px por encima de la barra |

**Validación.**

- `tests/qa_i6_08.gd` reproduce los seis casos (victoria del Custodio con su frase completa, inventario con un sello, mesa del Recaudador al iniciar y al pedir, derrota del Recaudador y toma de Ignacio) y guarda el antes y el después a 1024 × 576 y 1280 × 720. Las comparativas están en [`Diseno/recursos/i6/`](Diseno/recursos/i6/): [1024 × 576](Diseno/recursos/i6/i6-08_antes_despues_1024x576.jpg) y [1280 × 720](Diseno/recursos/i6/i6-08_antes_despues_1280x720.jpg).
- `tests/test_superposiciones_i6.gd` (9 pruebas) comprueba que en los tres paneles el párrafo cabe entero y termina antes de la lista, que el panel no sale del lienzo y que el coste y el nombre del botón no se cruzan al iniciar ni al pedir. También comprueba que «Nuevo intento» lleva a la entrada y que en la toma de Ignacio no hay cara recortada.
- Recompensa con ratón y con teclado: elegir una carta la añade una sola vez y una segunda elección se rechaza; «Continuar sin carta» no añade nada; Enter sobre la carta enfocada la elige y cierra el panel.
- GUT: **296 pruebas y 2.693 aserciones**, todas pasan.

## Avance de I6-10

Primer tramo implementado por Kenned el 26 de noviembre de 2026 en la rama `kenned/i6-reacciones`, que parte de `kenned/i6-correcciones`.

| Pieza | Resultado |
| --- | --- |
| **Líneas** | `datos/reacciones/reacciones.tres` (`ReaccionesCrupier`) guarda las variantes del Custodio de la §9.1 para Punto exacto, Al filo, Quiebra y `meta_cerca`. Los demás jefes y disparadores se añaden como datos |
| **Cuándo** | Solo al resolver la mano, comparando la vista pública anterior con la nueva (la misma que emite `ControladorMesa.vista_actualizada`). La mano ya está revelada, así que ninguna reacción anticipa una Máscara oculta. Una por acción: si coinciden varias, gana la de mayor prioridad (Quiebra y Punto exacto 8, Al filo y `meta_cerca` 6). `meta_cerca` salta al cruzar el 85 % de la meta, sin victoria |
| **Bocadillo** | `mesa/interfaz/bocadillo_crupier.gd`, sobre el retrato con la cola hacia su rostro: nombre del crupier y la frase. No recibe clics ni foco, la mano sigue activa, y se retira a los 3 s o con la siguiente acción. Nunca repite seguida la misma variante |
| **Ajuste** | «Comentarios de los crupieres» en Opciones (Lectura y accesibilidad), activado por defecto y guardado en `user://ajustes.cfg` |

**Pruebas.** `tests/test_reacciones_i6.gd` (10 pruebas):

- disparadores y prioridades;
- líneas de 90 caracteres como máximo y sin repetir la última;
- Punto exacto en una mano real sin quitar el foco ni pausar la mano;
- Quiebra que se retira al actuar;
- el bocadillo desaparece a los 3 s;
- ningún comentario al pedir con una Máscara oculta;
- el ajuste lo desactiva y está en Opciones.

Capturas a 1024 × 576 y 1280 × 720 con `tests/qa_i6_10.gd`. GUT: **306 pruebas y 2.736 aserciones**.

**Siguiente.** Los demás disparadores del Custodio (sentarse, iniciar la mano, pedir arriesgado, campanadas bajas…) y los otros tres jefes, con la probabilidad del 35 % de la §9 para los comunes.

## Guion para los siguientes encargos

- **I6-10 · Reacciones.** La [sección 9 del guion](Diseno/GUION_PROLOGO_Y_DIALOGOS.md#9-reacciones-de-los-jefes-durante-la-partida) ya contiene líneas para los cuatro jefes, incluidos Punto exacto, Al filo, Quiebra y `meta_cerca` cuando falta menos del 15 % para la meta. El primer tramo puede probarse en el Custodio con esos hitos. Usar la vista pública que emite `ControladorMesa.vista_actualizada`, priorizar un solo comentario por acción, retirarlo en tres segundos o al actuar y añadir el ajuste para desactivarlo. Todo se muestra después de resolver, sin pausar la mano, cambiar el foco ni anticipar el valor de una Máscara oculta. Mantener estos comentarios distintos de las preguntas posvictoria de [I5-11](ITERACION_05.md#i5-11--menús-posvictoria-de-los-jefes).
- **I6-11 · Derrota.** La [sección 14.4](Diseno/GUION_PROLOGO_Y_DIALOGOS.md#144-fin-del-intento--la-casa-gana) ya plantea la última campanada, las manos que se vuelven porcelana y la Anfitriona que escribe otra invitación. Para la primera entrega, montar esa secuencia breve con las variantes que tengan datos disponibles, conservar la línea del jefe cuando aporte algo y dar acceso al nuevo intento. Encargar una CG de las manos de Klein sobre el tapete según ese encuadre. La transición al taller y los ecos entre intentos se retoman cuando quede definida la progresión persistente del guion.

## Orden de trabajo

1. Corregir los cruces de texto, botones y arte observados en las capturas (I6-08).
2. Rediseñar la mesa y ajustar los sprites en contexto (I6-04 e I6-09).
3. Pulir el inventario, la vitrina, la recompensa y la baraja con saldos distintos y una baraja modificada (I6-05).
4. Conectar las reacciones durante la mano, la derrota ilustrada y los encuentros del recorrido (I6-10, I6-11 e I6-06).
5. Cerrar con el piloto (I6-07) y registrar qué entendió cada participante antes de añadir instrucciones.

## Verificación local

- Godot 4.7.2 y GUT. Pasaron 287 pruebas y 2.649 aserciones. Tras I6-08: 296 pruebas y 2.693 aserciones.
- Medición al 140 % de las intervenciones de los siete recursos de diálogo. Los 47 cruces detectados con la barra inferior bajaron a cero.
- Capturas del inicio con y sin partida guardada y de «Cómo jugar» a 1024 × 576 y 1280 × 720. La segunda portada, los dos pasillos y el cuadro NVL ampliado se revisaron por separado.

## Arte de portada

Los fondos [Invitación](juego/casino/interfaz/menus/arte/portada_invitacion.webp) y [Corvera](juego/casino/interfaz/menus/arte/portada_corvera.webp) se generaron con ImageGen y se importaron como WebP de 1920 × 1080. El encargo usó el grabado de la Máscara, la invitación, la fachada y el retrato de Klein como referencias. En la primera pieza, la mano, el lacre y el reloj cuentan la llegada de la invitación. En la segunda, Klein mira la puerta del casino desde la calle. Ambas dejan oscura la izquierda para el título y los botones de Godot.
