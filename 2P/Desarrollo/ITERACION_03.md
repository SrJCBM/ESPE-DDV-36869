# Iteración 03 · Pulido, balance y deuda técnica

**En curso desde el 22 de noviembre de 2026.** Parte de una revisión del juego hecha con el paquete de skills de desarrollo de videojuegos (`gamedev-skills/awesome-gamedev-agent-skills`) y de los comentarios de Damián en la [revisión de la iteración 2](ITERACION_02.md#revisión-con-damián). La revisión propuso siete puntos de mejora; aquí se ordenan de completado a por implementar. Rama de trabajo: `kenned/i2-feedback-revelacion`.

## Estado

| ID | Mejora | Punto de la revisión | Estado | Evidencia o pendiente |
| --- | --- | :---: | --- | --- |
| I3-01 | Respuesta visual al resolver la mano | 2 | **Completado** | `835ddff`. 141 pruebas, 6 nuevas en `test_feedback_resultado.gd` |
| I3-02 | Balance de la Coleccionista, el Dueño y el Sello | 3 | **Completado** | `d477d3a`. [BALANCE_CAMPANA.md](BALANCE_CAMPANA.md); Word v2.4 y MD alineados |
| I3-03 | Regla del crupier visible en la mesa | 5 | Pendiente | Incluye el comentario de Damián sobre el umbral del Dueño |
| I3-04 | Pruebas de invariantes de zonas y de barajado | 7 | Pendiente | Antes de I3-05, como red de seguridad |
| I3-05 | Deuda técnica | 6 | Pendiente | Strategy por crupier, catálogo en Resources, palos como constantes, dividir `mesa_ui.gd`, ajustes persistentes |
| I3-06 | Recompensa de cartas tras cada mesa | 4 | En pausa | Diseño acordado; se retoma cuando el equipo lo indique |
| I3-07 | Sonido | 1 | Diferido | Se hará con la tarea del docente sobre sonido diegético y no diegético |
| I3-08 | Colisiones de la exploración | — | Pendiente | Comentario 3 de Damián; no formaba parte de los siete puntos |

## Completado

### I3-01 · Respuesta visual al resolver la mano

Al plantarse, cada Máscara se voltea con un leve rebote al revelarse. La fórmula del resultado cuenta desde cero hasta el aporte de la mano y el boleto sube con ella; termina con un pequeño realce. Con un Punto exacto las cartas saltan una tras otra; con una Quiebra tiemblan con un tinte rojizo que se desvanece y el texto del exceso hace un pulso.

- Las animaciones solo recorren textos ya calculados por el controlador y siempre terminan en el texto final exacto.
- Se interrumpen sin dejar valores a medias al iniciar otra mano, abrir una ventana o activar movimiento reducido. Con movimiento reducido no hay ninguna.
- Solo se mueve el dibujo de la carta, no el botón: el foco y los clics no cambian.
- Archivos: `cartas/carta_ui.gd`, `mesa/mesa_ui.gd`, `tests/test_feedback_resultado.gd` y `juego/README.md`.
- Duraciones ajustables: `DURACION_SACUDIDA` en `carta_ui.gd` y `DURACION_CUENTA` en `mesa_ui.gd`. Kenned lo probó con la demostración guiada y se aceptó sin cambios.

### I3-02 · Balance de la campaña

| Regla | Antes | Ahora |
| --- | --- | --- |
| La Coleccionista (meta · campanadas) | 600 · 14 | **700 · 12** |
| El Dueño de la Casa (meta · campanadas) | 800 · 16 | **750 · 18** |
| Sello del prudente | Dos usos por mesa | **Un uso por mesa** (propuesta de Julio) |

En 1.000 campañas simuladas sin compras, la Coleccionista pasa de superarse el 100 % al 94 % de las veces y el Dueño del 13 % al 35 %, dentro del objetivo del 30–40 %. Precios y amuletos no cambian: las fichas siguen siendo escasas para que comprar sea una decisión. El mismo commit:

- añade `tests/sim_campana.gd`, que simula campañas completas con los comandos reales;
- edita el documento de diseño v2.4 en su mismo archivo con el coste por mano, la Quiebra segura y las reglas nuevas;
- integra el ajuste del 14 de noviembre en [ITERACION_01.md](ITERACION_01.md#ajuste-de-jugabilidad-del-14-de-noviembre), borra `AJUSTE_JUGABILIDAD_I1.md` y corrige los MD que seguían con el coste por carta.

Límite conocido: quien compra Corona y Sello supera la Coleccionista siempre y el Dueño el 94 % de las veces. La ventaja viene sobre todo de la Corona, que se mantiene hasta observar a más jugadores.

## Por implementar

### I3-03 · Regla del crupier visible en la mesa

Hoy la regla especial de cada crupier solo se lee en la ayuda (H) y el umbral del Dueño cambia sin aviso; Damián no notó que bajaba. Criterios:

- La mesa muestra siempre, sin abrir la ayuda, la regla del crupier aplicada a la mano en curso. Por ejemplo: «Esta mano: umbral 23 · baja a 22 al cerrarla» o «Retendrá tu carta más alta».
- Cuando el umbral del Dueño cambia entre manos, el cambio se señala de forma visible (antes → después) y también con texto, sin depender de la animación.
- No tapa cartas, patrones ni acciones a 1024 × 576 y 1280 × 720.
- **Decisión pendiente de Julio:** la otra idea de Damián, que el umbral solo baje si la mano no terminó en Quiebra, cambia la regla. Si se adopta, actualizar controlador, pruebas, `BALANCE_CAMPANA.md` y Word, y volver a medir.

### I3-04 · Pruebas de invariantes y de barajado

- Tras miles de acciones aleatorias legales en las cuatro mesas, cada carta está en una sola zona y el total `mazo + mano + descarte + retenidas` no cambia.
- Barajar 4 cartas 24.000 veces: cada uno de los 24 órdenes cerca de 1.000; un chi-cuadrado mayor que 41 indica sesgo.
- La misma semilla y las mismas acciones reproducen el mismo estado final.

### I3-05 · Deuda técnica

- **Strategy por crupier:** las reglas del Recaudador, la Coleccionista y el Dueño dejan de ser comparaciones de texto repartidas por el controlador y la campaña; añadir una mesa será crear una clase. Ya estaba previsto en [ARQUITECTURA_Y_PATRONES.md](ARQUITECTURA_Y_PATRONES.md).
- **Catálogo en Resources:** objetos de tienda y reglas de mesa en `.tres`, como las cartas.
- **Palos como constantes:** sustituir los textos sueltos (`"velas"`, `"mascaras"`) para que una errata falle al cargar.
- **Dividir `mesa_ui.gd`** (unas 1.000 líneas) en franja de patrones, boleto, controles y revelación.
- **Ajustes persistentes:** guardar movimiento reducido con `ConfigFile` en `user://`, como pide el documento de diseño.
- Todo sin cambiar reglas: las pruebas existentes y las de I3-04 deben seguir pasando.

### I3-06 · Recompensa de cartas (en pausa)

Diseño acordado el 22 de noviembre. Tras superar el Custodio, el Recaudador y la Coleccionista, la casa ofrece tres cartas normales distintas entre sí (palo y valor del 1 al 10, con las reglas de siempre). Se elige una o ninguna; cada carta nueva también diluye las demás. La baraja crece como máximo de 24 a 27. Al retomarlo: medir el efecto con `sim_campana.gd` y actualizar Word y ayuda.

### I3-07 · Sonido (diferido)

Queda para la tarea que pondrá el docente sobre sonido diegético y no diegético. Cuando llegue, partir de buses separados (música, efectos, interfaz y ambiente), sliders en decibelios y variación de los efectos repetidos. La campanada al iniciar cada mano es un candidato natural.

### I3-08 · Colisiones de la exploración

Comentario 3 de Damián: en algunas esquinas el visitante pasa por encima de mesas u objetos. Criterios:

- Revisar cada sala y ajustar los obstáculos al mobiliario dibujado, sin cerrar pasos necesarios hacia puertas, mesas y personajes.
- Añadir una prueba por sala que intente atravesar cada mueble y compruebe que el visitante se detiene.
- Revisión visual a 1024 × 576 y 1280 × 720.

## Verificación

```powershell
& $GodotExe --headless --path '2P/Desarrollo/juego' -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
& $GodotExe --headless --path '2P/Desarrollo/juego' --script res://tests/sim_campana.gd -- --semillas=1000
```

Estado al cerrar I3-02: **142 pruebas, 1.251 aserciones, todas pasan**. Cada punto se cierra con su commit, sus pruebas y la actualización de esta tabla.
