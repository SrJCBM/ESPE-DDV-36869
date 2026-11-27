# Iteración 06 · Lectura y presencia narrativa

**Objetivo.** Que el jugador reconozca desde la portada que entra a una novela visual y pueda explorar, comprar y jugar una mano con la información necesaria para cada decisión. La campaña jugable de [I5](ITERACION_05.md) es la base.

## Entregas

| ID | Entrega | Estado | Cómo comprobarla |
| --- | --- | --- | --- |
| I6-01 | Portada ilustrada | Implementada y verificada | La invitación y la llegada de Klein a Corvera alternan con un fundido cada 14 s. «Entrar al casino» o «Continuar» conserva el foco mientras cambia la imagen. El ajuste de movimiento reducido deja el fondo fijo. Se revisó con y sin partida guardada. |
| I6-02 | Visitantes en sus salas | Colocación inicial implementada | Amparo y los jugadores de porcelana están en el vestíbulo, Tobías en el pasillo del Custodio y Benavides en el del Recaudador. El ajuste de proporciones, anclaje y sombras está en I6-09. |
| I6-03 | Lectura accesible y ayuda breve | Implementada y verificada | Los siete recursos de diálogo conservan libre la barra inferior al 140 %. «Cómo jugar» reúne movimiento, mano y salida en tres bloques breves. El recorte de la cara de Ignacio y las superposiciones de otras pantallas se registran en I6-08. |
| I6-04 | Composición y lectura de la mesa | Implementada | Cada jefe tiene su propio tapete. Durante la mano, las cartas crecen y el patrón cercano se lee junto a la mano. T consulta patrones. Si se elige una Llave, Esc cancela esa elección. El coste tiene icono de ficha o campana. |
| I6-05 | Inventario, baraja, vitrina y recompensa | Implementada | Los sellos, las fichas y los objetos se ven en el inventario. La baraja muestra el detalle al enfocar y desplaza las filas largas. La vitrina conserva el precio y explica el bloqueo. En la recompensa se puede elegir una carta, leer al crupier u omitir. |
| I6-06 | Encuentros de exploración | Implementada | E abre las conversaciones de Amparo, Tobías y Benavides al acercarse. Su retrato cambia al conseguir los primeros dos sellos. Con tres sellos, la interacción pasa a examinar la figura de porcelana. |
| I6-07 | Prueba del recorrido y la lectura | Pendiente de piloto | Tres personas se orientan desde una partida nueva, resuelven una Máscara y explican qué cambiaría una compra. Ver [piloto](#piloto-de-i6-07). |
| I6-08 | Superposiciones y encuadre | Implementada y verificada · rama `kenned/i6-correcciones` | El panel compartido mide título y párrafo antes de colocar cartas y botones, y crece si hace falta. «Nuevo intento» en la derrota. El coste de la mesa va en su propia línea. La toma de Ignacio ya no muestra la cara recortada. Ver [avance de I6-08](#avance-de-i6-08). |
| I6-09 | Escala y anclaje de sprites | Implementada y verificada · rama `kenned/i6-mesa` | Las figuras se apoyan por la base de su parte visible, guardan escala con Klein y llevan sombra de contacto. El piano y el banco de Benavides quedan contra un muro, la mesa de jugadores en un lateral y el vano del este dentro de su nicho. Las huellas de colisión siguen a cada figura. |
| I6-10 | Reacciones de los crupieres durante la mano | Implementada | Los cuatro jefes comentan acciones y resultados según la vista pública. Opciones permite deshabilitarlos durante la mesa. Ver [avance de I6-10](#avance-de-i6-10). |
| I6-11 | Derrota ilustrada | Implementada para la ruta principal | El crupier despide a Klein, las manos se vuelven porcelana y la Anfitriona escribe otra invitación. **Nuevo intento** vuelve a la entrada. La variante de sombra depende de los eventos y finales. |

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

## Avance de I6-04 e I6-09

Implementado por Kenned el 26 de noviembre de 2026 en la rama `kenned/i6-mesa`, que parte de `kenned/i6-reacciones`. No se añadió arte para la mesa: se usan el tapete, el dial, la ficha del HUD y la campana del cuadro ADV. Para I6-09 se usaron las figuras de exploración que subió Julio.

**I6-04 · Mesa**

| Estado | Qué se ve |
| --- | --- |
| **Espera** | El tapete con «La mesa te espera» y el objetivo: meta, umbral y campanadas, más una línea sobre el coste de cada mano. Sin lectura ni patrones. El foco está en **Iniciar mano**. |
| **Mano** | El tapete crece (740 × 400) y las cartas llegan a 210 × 300. Hasta cinco cartas se ven siempre enteras, reducidas con su proporción. Desde la sexta conservan ese tamaño y la mano se desplaza hasta la última robada. A 1024 × 576 cada carta mide 90 px de ancho o más. Junto a «Mano N» aparece el patrón cercano, si ayuda a decidir: uno activo («Punto exacto · activo») o uno al que le falta una carta («Mano larga · 4/5»). Un patrón que depende de una Máscara oculta nunca se anuncia como activo. |
| **Consulta de patrones** | La fila fija de cinco patrones pasa a un botón **PATRONES · T**. Al abrirla, la franja ocupa el lugar de la lectura y el foco pasa al primer patrón; enfocarlo resalta sus cartas y explica cómo conseguirlo. **T**, **Esc** o **CERRAR · T** la cierran y devuelven el foco al botón. Abrir la ayuda, el inventario o un desglose también la cierra. La [revisión de Kenned](#revisión-de-kenned-tras-jugar) la sustituyó por una fila siempre visible. |
| **Resuelta** | Se lee la fórmula del resultado y los patrones obtenidos. **VER DESGLOSE** abre el detalle. |
| **Costes** | Iniciar o pedir llevan una ficha con icono y cantidad en su propio espacio: la campana para «−1 campanada» y la ficha del casino para «−1 ficha». El texto completo queda como nombre accesible y en el tooltip. En el Recaudador, el saldo sigue en la cabecera y en la placa de la regla. |

Las acciones ocupan el ancho completo de su columna (238 px), igual que el boleto. Se comprobó a 1024 × 576, 1280 × 720, 1920 × 1080 y en una ventana panorámica de 2560 × 1080. Las reglas y su balance no cambian.

**I6-09 · Figuras**

| Pieza | Resultado |
| --- | --- |
| **Apoyo** | Cada figura se coloca por la base de su parte opaca, no por el borde de la imagen. El recorte de los jugadores tenía 34 px transparentes bajo la mesa y flotaba. |
| **Escala** | El alto es el de la parte visible, entre 0,8 y 1,2 veces el de Klein (104): Tobías 96, Benavides sentado 96, Amparo con el piano 112, los jugadores 118. Las anfitrionas y los jefes, tras el mostrador o la mesa, conservan su escala. |
| **Sombra** | Sombra de contacto con el mismo estilo que la de Klein, salvo donde un mueble la tapa. |
| **Colocación** | El piano, contra el muro norte y bajo el aplique. La mesa de los jugadores, en el lateral oeste junto a la lámpara de pie. El banco de Benavides, contra el muro del pasillo bajo la caja fuerte, con sitio para las piernas. El vano del este se dibuja dentro del nicho, entre las molduras, sin marco que sobresalga. |
| **Huella** | Las colisiones del piano, la mesa de jugadores, Tobías y el banco siguen la base de cada figura. Klein se detiene delante y la puerta del este sigue al alcance. |

**Pruebas.** `tests/test_mesa_i6_04.gd` (10 pruebas) y `tests/test_sprites_i6_09.gd` (8). Se actualizaron las de la mesa de I4 y la del coste de I6-08 para la ficha y la consulta. Las capturas se generan con `tests/qa_i6_04.gd` (cuatro resoluciones) y `tests/qa_i6_09.gd`. Comparativas: [mesa](Diseno/recursos/i6/i6-04_mesa_antes_despues.jpg), [consulta y resoluciones](Diseno/recursos/i6/i6-04_consulta_y_resoluciones.jpg) y [figuras](Diseno/recursos/i6/i6-09_sprites_antes_despues.jpg). GUT: **324 pruebas y 2.858 aserciones**.

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

La ampliación sobre `2fd6a5d` conecta las líneas de la [sección 9](Diseno/GUION_PROLOGO_Y_DIALOGOS.md#9-reacciones-de-los-jefes-durante-la-partida) para los cuatro jefes. El controlador sigue publicando únicamente la información que el jugador conoce. El bocadillo prioriza un comentario por acción y retira el anterior al actuar. Los comentarios habituales tienen una probabilidad del 35 %. Se ajustó el alto para que quepa la última línea y el cambio en Opciones se aplica a la mesa abierta.

## Derrota y recuerdos

La derrota usa la última vista de la mesa para la frase del crupier. El juego funde a [las manos de porcelana](juego/historia/ilustraciones/cg_derrota_manos.webp) con un chasquido al transformarse y termina con la Anfitriona y **Nuevo intento**. La variante de sombra y los ecos persistentes forman parte del trabajo narrativo futuro. Los cuatro recuerdos de victoria quedan disponibles al volver a hablar con cada jefe. [I5-11](ITERACION_05.md#i5-11--menús-posvictoria-de-los-jefes).

## Piloto de I6-07

Cada participante empieza con una partida nueva. Se le pide llegar a la primera mesa, resolver una mano con una Máscara, localizar la tienda después de conseguir el sello y explicar qué cambiaría una compra en su próxima mano. Se registra el primer punto de duda, si usa el plano o la ayuda, y cómo interpreta el coste y el efecto del objeto. Los resultados de las tres sesiones se añadirán aquí. El mismo recorrido cubre la orientación que quedó pendiente en I4.

La [guía del piloto](Diseno/PILOTO_I6_07.md) reúne el guion que se lee a cada participante, las cinco tareas con su límite de tiempo y su pista mínima, la hoja de registro y el resumen de las tres sesiones. La versión de prueba se exporta a `juego/exportaciones/piloto_i6_07/` desde `main`, ya con las correcciones de la auditoría. Ahí mismo, `tests/qa_piloto_i6_07.gd` genera una partida de respaldo con el primer sello, por si alguien no gana al Custodio en el tiempo de la sesión.

## Correcciones de la auditoría

La auditoría de pantallas del 26 de noviembre encontró tres fallos en la mesa. Se corrigieron antes del piloto, con `tests/test_auditoria_i6.gd` (6 pruebas):

| Id | Fallo | Corrección |
| --- | --- | --- |
| F1 | El bocadillo del crupier cortaba la segunda línea de las reacciones largas. | Julio ajustó el alto al número de renglones. La prueba nueva recorre todas las líneas del guion de los cuatro jefes y exige que se vean enteras. |
| F2 | Si la última campanada terminaba con un patrón, el crupier lo festejaba sobre «Derrota · fin del intento». | Al terminar el intento, la única reacción posible es la de victoria o derrota. |
| F3 | Con seis cartas o más, la mano resuelta escondía una carta tras la barra gris de Godot. | Al resolver, las cartas se encogen hasta caber todas. Durante la mano se conserva el desplazamiento desde la sexta, con una barra fina de latón. Con seis cartas, el subtítulo «Cuenta como N» de los Relojes se recorta: queda como ajuste menor de la carta. |

### Revisión de Kenned tras jugar

Al jugar la versión del piloto salieron otros seis ajustes. Se integraron en `main` con `tests/test_revision_pantallas.gd` (7 pruebas):

| Pantalla | Antes | Ahora |
| --- | --- | --- |
| Levantarse con P tras ganar | El juego se cerraba (`set_input_as_handled` sobre un viewport nulo). | La mesa toma el viewport antes de salir del árbol. |
| Recompensa | Tres cartas pequeñas dentro del libro, con «Leer al crupier» y «Volver a las cartas». | Pantalla propia: retrato del crupier con su frase de victoria en un bocadillo, tres cartas grandes que llegan boca abajo y se voltean, y un panel que explica el efecto de la carta y muestra con barras cómo cambia el reparto de la baraja (D12). La primera pulsación elige y la segunda, o «Añadir a la baraja», confirma; Esc sigue sin carta. Las preguntas al crupier quedan para la revisita. |
| Inventario de la mesa y pertenencias | Texto plano. | Tarjetas con la ilustración del objeto, su efecto y marcas de usos: lo que queda en esta mesa o lo que da por mesa, y las cargas de la Lente. La Corona se marca como pasiva. |
| Título «LA ÚLTIMA MESA» | En la esquina de la mesa, del casino y del libro desde I1. | Solo en el menú de inicio y en la ventana. |
| Patrones | Consulta que se abría con T y tapaba la suma y el umbral. | Fila propia y siempre visible bajo la lectura. T lleva el foco a los patrones y Esc lo devuelve. Sin el patrón cercano sobre el tapete, que repetía el mismo progreso. |
| Llaves | Ambas Llaves iniciales mostraban «Cambiar». Es correcto según R07. | Se mantiene R07. En la mesa del Custodio, la pista lo enseña: con dos Llaves iniciales, se puede cambiar cualquiera, pero solo una y antes de pedir; tras pedir, solo la recién recibida. |
| Lente en el inventario de la mesa | Aparecía como «Agotada» (0 / 2) aunque se hubiera elegido otro objeto. | Solo aparece si se lleva alguna. |
| Portadas del menú de inicio | Dos imágenes fijas que se fundían cada 14 s. | Cada una se desliza despacio hacia la izquierda (72 px) antes de fundirse con la siguiente; quietas con movimiento reducido. |

Antes de compartir el piloto, `tests/test_entrega_i6_07.gd` recorre una campaña entera por los caminos del juego con cada objeto inicial: las cuatro mesas, levantarse con P, la recompensa con el teclado, una compra, guardar y continuar, el portón final y una derrota. Comprueba que el inventario de cada mesa y las pertenencias enseñen solo lo que se lleva y que no aparezca ningún error del motor. Con ella pasan 350 pruebas.

### Tutorial en contexto

Para que alguien de 13 años aprenda jugando, sin pantallas de reglas: nueve frases de ocho palabras como máximo (`casino/interfaz/consejos/consejos.gd`). Cada una sale una sola vez, en el momento en que hace falta, en un globo que señala con una flecha la parte de la pantalla de la que habla y la enmarca. El globo no bloquea el ratón ni el teclado y desaparece al actuar. Cuando coinciden varios, sale el más importante y el resto espera a que su situación vuelva a darse. No sale ninguno sobre el final del intento.

| Momento (la primera vez) | Frase | Señala |
| --- | --- | --- |
| Al sentarse a una mesa | «Acércate al Umbral sin pasarte.» | El umbral |
| Primera mano repartida | «P: otra carta. S: plantarte y cobrar.» | Pedir y Plantarse |
| Primera Llave que se puede cambiar | «Puedes cambiar una Llave antes de pedir.» | La mano |
| Primera Máscara boca abajo | «Las Máscaras se descubren al plantarte.» | La mano |
| Primera quiebra | «Te pasaste: esta mano vale 0.» | El resultado |
| Primer patrón | «¡Patrón! Multiplica tus puntos.» | La fila de patrones |
| Quedan dos campanadas | «Cada mano gasta una campanada.» | El dial |
| Primera recompensa | «Elige una carta para tu baraja.» | Las tres cartas |
| Se abre la tienda | «Gasta fichas en objetos y cartas.» | La vitrina |

Opciones › «Consejos para aprender a jugar» los apaga y «Repetir los consejos» vuelve a mostrarlos. Los consejos vistos se guardan en los ajustes. Las pruebas usan su propio archivo de ajustes (`tests/preparar_pruebas.gd`, activado desde `.gutconfig.json`; en el panel de GUT del editor hay que ponerlo como Pre-Run Hook). Las cubre `tests/test_consejos.gd`.

## Orden de trabajo

1. Corregir los cruces de texto, botones y arte observados en las capturas (I6-08).
2. Rediseñar la mesa y ajustar los sprites en contexto (I6-04 e I6-09).
3. Pulir el inventario, la vitrina, la recompensa y la baraja con saldos distintos y una baraja modificada (I6-05).
4. Conectar las reacciones durante la mano, la derrota ilustrada y los encuentros del recorrido (I6-10, I6-11 e I6-06).
5. Cerrar con el piloto (I6-07) y registrar qué entendió cada participante antes de añadir instrucciones.

## Verificación local

- Godot 4.7.2 y GUT. Pasaron **329 pruebas y 2.971 aserciones** en la entrega actual; **335 y 2.987** tras las correcciones de la auditoría, y **343 y 3.008** tras la revisión de Kenned. Capturas de esa revisión con `tests/qa_revision_pantallas.gd` y `tests/qa_interfaz_i4.gd -- --vista=recompensa`. La comprobación de colisiones ahora busca puntos libres a lo largo de cada borde para que el piano reubicado no invalide la prueba de la pared norte.
- Capturas de recompensa, inventario, baraja, vitrina, mesa y derrota a 1024 × 576 y 1280 × 720 con `tests/qa_i6_08.gd`. La exportación para Windows se generó con el preset del proyecto.
- Medición al 140 % de las intervenciones de los siete recursos de diálogo. Los 47 cruces detectados con la barra inferior bajaron a cero.
- Capturas del inicio con y sin partida guardada y de «Cómo jugar» a 1024 × 576 y 1280 × 720. La segunda portada, los dos pasillos y el cuadro NVL ampliado se revisaron por separado.

## Arte de portada

Los fondos [Invitación](juego/casino/interfaz/menus/arte/portada_invitacion.webp) y [Corvera](juego/casino/interfaz/menus/arte/portada_corvera.webp) se generaron con ImageGen y se importaron como WebP de 1920 × 1080. El encargo usó el grabado de la Máscara, la invitación, la fachada y el retrato de Klein como referencias. En la primera pieza, la mano, el lacre y el reloj cuentan la llegada de la invitación. En la segunda, Klein mira la puerta del casino desde la calle. Ambas dejan oscura la izquierda para el título y los botones de Godot.
