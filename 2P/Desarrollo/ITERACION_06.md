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
| I6-08 | Superposiciones y encuadre | Por implementar | Reservar espacio medido para texto y acciones en inventario, recompensa y derrota. Corregir el coste sobre el nombre del botón de mesa y la cara recortada de Ignacio en ADV. |
| I6-09 | Escala y anclaje de sprites | Por implementar | Revisar las figuras al lado de Klein, de una puerta y del mobiliario. Ajustar pivote, perspectiva, colocación, sombra y huella de colisión en la misma pasada. |
| I6-10 | Reacciones de los crupieres durante la mano | Propuesto para Kenned | Conectar las líneas de la sección 9 a hitos de la vista pública. El bocadillo se lee junto al retrato y el jugador puede seguir actuando. |
| I6-11 | Derrota ilustrada | Propuesto para Kenned | Adaptar la escena de porcelana de la sección 14.4 y conectar el nuevo intento. Preparar el encargo de arte cuando quede elegido su encuadre. |

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

- Godot 4.7.2 y GUT. Pasaron 287 pruebas y 2.649 aserciones.
- Medición al 140 % de las intervenciones de los siete recursos de diálogo. Los 47 cruces detectados con la barra inferior bajaron a cero.
- Capturas del inicio con y sin partida guardada y de «Cómo jugar» a 1024 × 576 y 1280 × 720. La segunda portada, los dos pasillos y el cuadro NVL ampliado se revisaron por separado.

## Arte de portada

Los fondos [Invitación](juego/casino/interfaz/menus/arte/portada_invitacion.webp) y [Corvera](juego/casino/interfaz/menus/arte/portada_corvera.webp) se generaron con ImageGen y se importaron como WebP de 1920 × 1080. El encargo usó el grabado de la Máscara, la invitación, la fachada y el retrato de Klein como referencias. En la primera pieza, la mano, el lacre y el reloj cuentan la llegada de la invitación. En la segunda, Klein mira la puerta del casino desde la calle. Ambas dejan oscura la izquierda para el título y los botones de Godot.
