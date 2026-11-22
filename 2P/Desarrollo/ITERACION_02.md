# Iteración 02 · La casa de los tres sellos

**Versión 0.2.0 · 18 de noviembre de 2026.** Campaña jugable con ayuda por mesa, objetivo de exploración y personajes ampliados. La revisión con un jugador se completó y sus hallazgos pasan a la [iteración 3](ITERACION_03.md).

El visitante recorre el casino aprobado en clase, prepara su baraja entre encuentros y sale al amanecer si supera las cuatro mesas. La campaña dura un intento y el progreso se conserva durante la sesión. La prioridad siguiente es revisar orientación y balance con el equipo. La red queda para un incremento posterior.

## Recorrido de prueba

1. Abrir el proyecto con Godot 4.7.2 y pulsar **F5**. Caminar con **WASD o flechas** hasta el mostrador iluminado del vestíbulo. **E** abre el diálogo y otra pulsación entrega la invitación. El inventario (**I**) debe mostrar 24 cartas y diez fichas. Hablar otra vez permite pedir indicaciones.
2. Salir por el sur. En la galería, examinar la puerta del Recaudador antes de ganar el primer sello. Debe indicar el requisito. Entrar al gabinete, seleccionar la Lente y confirmar. El saldo baja a cuatro. Volver al mostrador y cancelar una compra conserva el saldo.
3. Sentarse ante el Custodio. Al recibir una Máscara, usar la Lente para conocer su valor antes de decidir. Se gasta una unidad. La mesa entrega diez fichas más cinco por cada Punto exacto al ganar. Levantarse permite volver a la tienda o a la galería.
4. El Recaudador adelanta quince fichas una sola vez y cobra una por petición adicional. La Coleccionista retiene la carta más alta, con desempate por la última robada. El Dueño reduce el umbral de la mano siguiente hasta 17. Se puede consultar la bolsa en cada mesa con **I**.
5. Tras la cuarta victoria, rodear la mesa del Dueño y abrir el portón del norte con **E**. Una derrota termina el intento. El siguiente comienza de nuevo en recepción.

## Entregas

| Entrega | Estado técnico | Evidencia |
| --- | --- | --- |
| Salas y personajes | Implementada | Siete fondos originales de 1672 × 941, seis figuras de exploración, cuatro retratos nuevos y el Custodio original. [Atlas editable en Figma](https://www.figma.com/design/FtJBoUubQ3lC4jlsZ9RxNq?node-id=57-4115) |
| Exploración | Implementada | Movimiento con colisiones, diálogo por proximidad, indicación de puertas y retorno a la galería. |
| Objetos y economía | Implementada | La Lente revela solo las Máscaras presentes. Corona, Sello del prudente y Moneda mellada aplican sus efectos. La tienda confirma el precio y admite ajustes o eliminación de cartas. [Gabinete y figuras](https://www.figma.com/design/FtJBoUubQ3lC4jlsZ9RxNq?node-id=60-4103) |
| Encuentros | Implementada | La misma mesa de cartas recibe las reglas del anfitrión y el inventario del intento. Las tres primeras victorias abren puertas y la cuarta habilita el portón. |
| Revisión con usuarios | Completada | Damián jugó la campaña antes del balance del 22 de noviembre. Tres observaciones: dificultad, umbral del Dueño y colisiones. [Detalle](#revisión-con-damián) |

## Revisión con Damián

Damián jugó la versión 0.2.0 completa, antes del balance de la campaña y de las mejoras de la iteración 3. Sus comentarios se registran tal como los expresó y cada uno tiene destino en la [iteración 3](ITERACION_03.md).

| # | Comentario | Lectura del equipo | Destino |
| --- | --- | --- | --- |
| 1 | «Sentí el juego muy fácil.» | Coincide con la simulación: la Coleccionista la superaba el 100 % de quienes llegaban y quien compra Corona y Sello superaba al Dueño el 84 % de las veces. | I3-02 endureció la Coleccionista y redujo el Sello a un uso. Quien compra sigue superando al Dueño el 94 % de las veces, así que conviene repetir la prueba con él. |
| 2 | «No me di cuenta de que el jefe iba bajando su límite en cada ronda. Debería haber algo más llamativo visualmente, o que solo baje si no me excedí del límite.» | El cambio de umbral solo se veía en el número y en la ayuda (H). La segunda idea cambia la regla del Dueño. | I3-03 mostrará la regla del crupier y el cambio de umbral en la mesa. Bajar solo sin Quiebra queda como decisión de diseño para Julio. |
| 3 | «Debería haber más colisiones con el entorno. Al mover al personaje por las esquinas, en algunos sitios puedo pasar por encima de mesas u objetos cuando no debería.» | Los obstáculos de algunas salas no cubren todo el mobiliario dibujado. | I3-08: revisar y completar las colisiones de cada sala. |

Sus comentarios no cubren si encontró la salida sur, si distinguió fichas de campanadas ni cuándo usar la Lente: esas preguntas quedan para el próximo piloto.

## Entrega de Kenned

I2-K1, I2-K2 e I2-K3 están aceptadas. Kenned entregó la ayuda y el objetivo en `1ba87b6` y documentó su prueba de Windows a 1024 × 576 y 1280 × 720 en la [tarea #1](https://github.com/SrJCBM/ESPE-DDV-36869/issues/1). En `235a92f` amplió las figuras de exploración y ajustó el orden de dibujo para mantener visibles las placas y los indicadores.

| Actividad | Criterio de aceptación |
| --- | --- |
| I2-K1 · Ayuda de la mesa activa | Al pulsar **H**, el libro toma meta, umbral, presupuesto y coste de la mesa actual. El Recaudador distingue el reparto inicial gratuito de la petición adicional de una ficha. Con el Dueño, el libro refleja el umbral vigente. El acceso independiente de I1 conserva la ayuda del Custodio. |
| I2-K2 · Objetivo discreto a la izquierda | Durante la exploración se ve un objetivo breve en la esquina superior izquierda del área de juego. Un pequeño rombo de latón y texto marfil lo distinguen del aviso de interacción con **E**. Usar sombra o una franja translúcida ajustada al texto. Reservar un margen bajo el encabezado y dejar libres puertas, cartas y controles. |
| I2-K3 · Prueba en otro equipo | Importar con Godot 4.7.2, ejecutar GUT y probar el exportado de Windows. Registrar resolución, resultado y pasos de cualquier fallo. Añadir pruebas para el coste que muestra la ayuda y los cambios de objetivo. |

### Comportamiento del objetivo

- Al llegar se lee «Habla con la anfitriona». Al recibir la baraja cambia a «Encuentra la mesa del Custodio». Los tres sellos llevan sucesivamente al Recaudador, a la Coleccionista y al Dueño. La cuarta victoria muestra «Abre el portón del amanecer».
- Derivar el texto del progreso de la campaña. Visitar la tienda, cancelar una compra o volver al vestíbulo conserva el objetivo. Un intento nuevo comienza con la invitación.
- Mostrar un único objetivo, de hasta dos líneas. Ocultarlo mientras están abiertos los diálogos, el inventario, la tienda o una mesa de cartas. Al volver a caminar reaparece el objetivo vigente.
- Probar a **1024 × 576** y **1280 × 720**. Acercarse a una puerta, abrir un diálogo y ganar un sello. Comprobar que **E** sigue disponible, que el indicador deja pasar los clics y que el objetivo cambia una sola vez.

## Comprobaciones

La versión integrada pasó **134 pruebas y 1182 aserciones** con Godot 4.7.2 desde una copia limpia. Se comprobó el indicador en el vestíbulo a 1024 × 576 y se exportó y ejecutó la compilación de Windows.

Godot 4.7.2 y GUT ejecutaron 120 pruebas con 1051 aserciones. La regresión de campaña usa barajas normales con semillas fijas y las acciones de la interfaz. Completa las cuatro mesas, abre el portón y empieza otro intento. También se probaron compras rechazadas, límites de amuletos, revelación parcial, cobro de recompensas, retenciones y la convivencia con el acceso directo a I1.

En una simulación de 180 campañas, una estrategia fija compró una Lente al inicio, adquirió Corona y Sello cuando pudo y pidió si el punto medio del intervalo visible quedaba seis o más por debajo del umbral. Superó el Custodio 159 veces, el Recaudador 141, la Coleccionista 141 y el Dueño 107. Son resultados acumulados de esa estrategia. Antes de ajustar los precios o la dificultad, el equipo observará qué hacen personas que juegan por primera vez. El 22 de noviembre se ajustaron meta y campanadas de la Coleccionista y el Dueño, sin tocar precios ni amuletos: [balance de la campaña](BALANCE_CAMPANA.md).

El ejecutable de esta versión se llama `LaUltimaMesa-I2.exe`. Para el piloto de I1 se conserva el ejecutable que compartió Ariel y la escena `principal/principal.tscn`. [Ejecución, pruebas y exportación](juego/README.md).
