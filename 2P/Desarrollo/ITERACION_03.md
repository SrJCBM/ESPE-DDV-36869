# Iteración 03 · Pulido, balance y deuda técnica

**En curso desde el 22 de noviembre de 2026.** Parte de una revisión del juego hecha con el paquete de skills de desarrollo de videojuegos (`gamedev-skills/awesome-gamedev-agent-skills`) y de los comentarios de Damián en la [revisión de la iteración 2](ITERACION_02.md#revisión-con-damián). La revisión propuso siete puntos de mejora; aquí se ordenan de completado a por implementar. Las entregas I3-01 a I3-05 se integraron en `main`.

## Estado

| ID | Mejora | Punto de la revisión | Estado | Evidencia o pendiente |
| --- | --- | :---: | --- | --- |
| I3-01 | Respuesta visual al resolver la mano | 2 | **Completado** | `835ddff`. 141 pruebas, 6 nuevas en `test_feedback_resultado.gd` |
| I3-02 | Balance de la Coleccionista, el Dueño y el Sello | 3 | **Completado** | `d477d3a`. [BALANCE_CAMPANA.md](BALANCE_CAMPANA.md); Word v2.4 y MD alineados |
| I3-03 | Regla del crupier visible en la mesa | 5 | **Completado** | Placa de regla, aviso del umbral y Dueño sin bajar tras Quiebra. 149 pruebas, 7 nuevas en `test_regla_crupier.gd` |
| I3-04 | Pruebas de invariantes de zonas y de barajado | 7 | **Completado** | 3 pruebas en `test_invariantes.gd`; comprobadas con dos errores introducidos a propósito |
| I3-05 | Deuda técnica | 6 | **Completado** | Cinco reorganizaciones en commits separados, sin cambiar reglas. 159 pruebas |
| I3-06 | Recompensa de cartas tras cada mesa | 4 | **Implementado** | Una de tres cartas o ninguna tras las primeras tres mesas. |
| I3-07 | Sonido | 1 | **Implementado** | Bucle musical, ambiente, efectos de juego y cuatro controles de volumen. |
| I3-08 | Colisiones de la exploración | — | **Implementado** | Huellas por sala, pruebas por mueble y capturas a dos resoluciones. |

## Completado

### I3-01 · Respuesta visual al resolver la mano

Al plantarse, cada Máscara se voltea con un leve rebote al revelarse. La fórmula del resultado cuenta desde cero hasta el aporte de la mano y el boleto sube con ella; termina con un pequeño realce. Con un Punto exacto las cartas saltan una tras otra; con una Quiebra tiemblan con un tinte rojizo que se desvanece y el texto del exceso hace un pulso.

- Las animaciones solo recorren textos ya calculados por el controlador y siempre terminan en el texto final exacto.
- Se interrumpen sin dejar valores a medias al iniciar otra mano, abrir una ventana o activar movimiento reducido. Con movimiento reducido no hay ninguna.
- Solo se mueve el dibujo de la carta, no el botón: el foco y los clics no cambian.
- Archivos: `cartas/carta_ui.gd`, `mesa/mesa_ui.gd`, `tests/test_feedback_resultado.gd` y `juego/README.md`.
- Duraciones ajustables: `DURACION_SACUDIDA` en `carta_ui.gd` y `DURACION_CUENTA` en `mesa/respuesta_resultado.gd` (antes en `mesa_ui.gd`, ver I3-05). Kenned lo probó con la demostración guiada y se aceptó sin cambios.

### I3-02 · Balance de la campaña

| Regla | Antes | Ahora |
| --- | --- | --- |
| La Coleccionista (meta · campanadas) | 600 · 14 | **700 · 12** |
| El Dueño de la Casa (meta · campanadas) | 800 · 16 | **750 · 18**; con I3-03, **750 · 17** |
| Sello del prudente | Dos usos por mesa | **Un uso por mesa** (propuesta de Julio) |

En 1.000 campañas simuladas sin compras, la Coleccionista pasa de superarse el 100 % al 94 % de las veces y el Dueño del 13 % al 35 %, dentro del objetivo del 30–40 % (34 % tras la regla nueva del Dueño de I3-03). Los precios se mantienen. El Sello del prudente pasa a una activación por mesa. El mismo commit:

- añade `tests/sim_campana.gd`, que simula campañas completas con los comandos reales;
- edita el documento de diseño v2.4 en su mismo archivo con el coste por mano, la Quiebra segura y las reglas nuevas;
- integra el ajuste del 14 de noviembre en [ITERACION_01.md](ITERACION_01.md#ajuste-de-jugabilidad-del-14-de-noviembre), borra `AJUSTE_JUGABILIDAD_I1.md` y corrige los MD que seguían con el coste por carta.

Límite conocido: quien compra Corona y Sello supera la Coleccionista siempre y el Dueño el 96 % de las veces. La ventaja viene sobre todo de la Corona, que se mantiene hasta observar a más jugadores.

### I3-03 · Regla del crupier visible en la mesa

Antes la regla especial solo se leía en la ayuda (H) y el umbral del Dueño cambiaba sin aviso al iniciar la mano siguiente; Damián no notó que bajaba.

- Una placa **«Regla de la mesa»** bajo el retrato del crupier explica su regla aplicada a la mano en curso: la comisión y el saldo en el Recaudador, la carta que retiene y cuántas lleva la Coleccionista, y el umbral del Dueño. El Custodio y la mesa suelta de I1 no tienen regla especial y no la muestran.
- Con el Dueño, la línea junto al umbral cambia de «No lo excedas.» a «Baja a 23 sin Quiebra.» durante la mano y a «Próxima mano: 23.» entre manos. Al iniciar la mano siguiente, el número del umbral late en oro y la placa dice «El umbral bajó de 24 a 23». Tras una Quiebra explica que el umbral se mantiene; en el mínimo, que ya no baja.
- Todo cambio se explica con texto; con movimiento reducido el número no se anima.
- El controlador añade a la vista pública la mesa, las cartas retenidas y los umbrales anterior y siguiente del Dueño. El tope de 17 es `ReglaDueno.MINIMO` y el valor inicial sale de los datos de la mesa (ver I3-05).
- Archivos: `mesa/controlador_mesa.gd`, `mesa/lectura_mesa.gd`, `mesa/mesa_ui.gd`, `tests/test_regla_crupier.gd` y `tests/qa_regla.gd`, que genera las capturas en `juego/exportaciones/qa/`. Revisado a 1024 × 576 y 1280 × 720: la placa no tapa umbral, cartas ni acciones.
- **Regla nueva del Dueño (decisión de Julio):** como propuso Damián, el umbral solo baja tras una mano cerrada sin Quiebra. La ayuda, el diálogo del Dueño y el Word lo explican. La regla resultó facilitar la mesa (sin compras, del 35 % al 42 %), así que el Dueño pasa de 18 a 17 campanadas y vuelve al 34 % ([balance](BALANCE_CAMPANA.md#el-dueño-solo-baja-tras-una-mano-sin-quiebra)).

### I3-04 · Pruebas de invariantes y de barajado

Red de seguridad para reorganizar el código en I3-05 sin romper reglas. `tests/test_invariantes.gd`:

- **Zonas.** Un agente elige al azar entre las acciones legales de la vista pública (iniciar, pedir, plantarse, devolver Llave y usar la Lente) durante 10.000 acciones, 2.500 por mesa, con amuletos equipados y empezando otra mesa al terminar. Después de cada acción, cada carta de la baraja está en una sola zona (`mazo`, `mano`, `descarte` o `retenidas`) y el total no cambia.
- **Barajado.** 24.000 barajados de 4 cartas reparten las 24 permutaciones con un chi-cuadrado de 21,5; con 23 grados de libertad, superar 41,64 indicaría sesgo (p < 0,01). La semilla es fija para que el resultado no varíe entre ejecuciones.
- **Reproducibilidad.** En cada mesa, la misma semilla y las mismas acciones dan el mismo estado final (cartas por definición, puntos, campanadas, umbral, saldo y Lentes) y otra semilla da otro.
- **Las pruebas detectan errores reales.** Se comprobaron introduciendo dos errores a propósito y restaurando el código después. Si `cerrar_mano` no pasa la mano al descarte, la prueba de zonas falla en el paso 9 del Custodio (17 cartas de 24). Si el barajado elige el intercambio entre todas las posiciones, el chi-cuadrado sube a 6.218.
- No se encontró ningún defecto en el código actual.

### I3-05 · Deuda técnica

Cinco reorganizaciones, cada una en su commit, sin cambiar reglas ni lo que se ve. Después de cada una pasaron las pruebas, incluidas las de I3-04. En las que tocan reglas, la simulación de campaña dio exactamente los mismos porcentajes que antes.

| Commit | Cambio | Detalle |
| --- | --- | --- |
| `12f8597` | Palos como constantes | `datos/cartas/palos.gd` define los cuatro palos y sus nombres. El dominio, el controlador y la interfaz dejan de comparar textos sueltos, y la fábrica rechaza un palo desconocido |
| `f8f39c0` | Strategy por crupier | `dominio/crupieres/`: `ReglaCrupier` es la mesa sin regla especial, y `ReglaRecaudador`, `ReglaColeccionista` y `ReglaDueno` aplican la suya. `FabricaCrupieres` elige la clase según la mesa; añadir una mesa es crear su clase y registrarla. El controlador y la campaña ya no comparan nombres de mesa |
| `4e9f51b` | Datos en Resources | Las condiciones de cada mesa (`datos/mesas/mesas_campana.tres`) y los productos de la tienda (`datos/tienda/catalogo_tienda.tres`) se editan en el inspector, como el catálogo de cartas. El código lee campos con nombre en lugar de posiciones de un arreglo |
| `85421c1` | Ajustes persistentes | `ajustes/ajustes_juego.gd` guarda «movimiento reducido» en `user://ajustes.cfg` con `ConfigFile`. El vestíbulo y la mesa suelta lo aplican al abrir cada mesa; antes se perdía al cambiar de mesa o cerrar el juego. Sin Autoload: solo los puntos de entrada leen el archivo, y las pruebas usan uno propio para no tocar las preferencias reales |
| `90578d6` | Dividir `mesa_ui.gd` | Salen a sus propios scripts los constructores de controles (`piezas_mesa.gd`), el desglose de la mano (`desglose_mano.gd`), la placa de regla (`placa_regla.gd`) y la respuesta visual al resultado (`respuesta_resultado.gd`). El archivo pasa de 1.088 a 876 líneas y conserva la misma interfaz para el controlador y las pruebas |

Al separar las piezas apareció un texto que se había quedado atrás en I3-03: el inventario de la mesa del Dueño seguía diciendo que cada mano bajaba el umbral. Se corrigió en `e21dfce`.

La interfaz de mesa compone la mano visual, la franja de patrones, la selección de Llaves, la revelación y el diálogo modal. El casino delega el montaje de salas, la tienda y la presentación de recompensas. Las reglas de crupier reciben el estado de partida y el controlador publica la mano mediante una proyección que protege los valores todavía ocultos. [Arquitectura y patrones](ARQUITECTURA_Y_PATRONES.md#distribución-en-i3).

### I3-06 · Recompensa de cartas

Tras superar el Custodio, el Recaudador y la Coleccionista, la casa ofrece tres combinaciones distintas de palo y valor (1 a 10). El visitante escoge una carta o continúa sin llevarse ninguna. Se aplica una sola elección por victoria y la baraja inicial puede crecer de 24 a 27. La carta se construye con la fábrica existente y entra al mazo de la siguiente mesa. La derrota y la victoria final cierran el encuentro sin abrir una oferta.

El generador está en `dominio/recompensas`. La campaña valida la decisión y la interfaz reutiliza la carta de mesa. La simulación compara el margen 6 omitiendo las recompensas y tomando la opción de menor valor efectivo.

| Estrategia (1.000 semillas por variante) | Campañas ganadas sin recompensa | Campañas ganadas con recompensa | Dueño superado con recompensa, entre quienes llegaron |
| --- | ---: | ---: | ---: |
| Sin compras | 253 | 316 | 316 de 738 (43 %) |
| Lente, Corona y Sello | 740 | 751 | 751 de 763 (98 %) |

Sin compras, seleccionar la carta de menor valor supera el objetivo anterior del 30–40 % para el Dueño. La selección es opcional y los resultados corresponden a esa estrategia simulada. El siguiente piloto puede comprobar si los jugadores eligen por valor, palo o preferencia.

### I3-07 · Sonido

**Sonido · V** abre el mezclador en exploración y en mesa. Música, Ambiente, Efectos e Interfaz se ajustan por separado y se conservan en `user://ajustes.cfg`. El juego aplica la ganancia en decibelios y silencia el bus en 0 %. Las pistas y los efectos son síntesis original para el proyecto. [Recursos y eventos](juego/audio/README.md).

### I3-08 · Colisiones de la exploración

Las huellas de mesas, sillas, vitrinas y mostradores siguen el arte de cada sala. Las mesas usan polígonos convexos con esquinas recortadas. Las pruebas lanzan al visitante contra los muebles de las seis salas, comprueban el collider que lo detiene y verifican que desde la entrada existe un camino hasta cada interacción. La revisión en 1024 × 576 y 1280 × 720 incluyó las seis salas y la galería.

La construcción de obstáculos vive en `casino/exploracion/plano_salas.gd`. Al sustituir un fondo, revisar sus huellas en la misma escala de 1280 × 720.

## Verificación

```powershell
& $GodotExe --headless --path '2P/Desarrollo/juego' -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
& $GodotExe --headless --path '2P/Desarrollo/juego' --script res://tests/sim_campana.gd -- --semillas=1000
& $GodotExe --headless --path '2P/Desarrollo/juego' --script res://tests/sim_campana.gd -- --semillas=1000 --margen=6 --recompensas
```

I3 pasó **167 pruebas y 1.764 aserciones** en Godot 4.7.2. Los casos cubren el recorrido completo, las recompensas y compras, la validez de las acciones, el orden de revelación de dos Máscaras, la vista de la Coleccionista y la restauración del foco al sustituir un diálogo.
