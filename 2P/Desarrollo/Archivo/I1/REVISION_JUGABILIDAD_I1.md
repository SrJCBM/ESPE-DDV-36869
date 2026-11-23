# Revisión de jugabilidad y recompensas · I1

**Fecha:** 13 de noviembre de 2026. **Base:** GDD v2.4, mesa del Custodio. **Decisión de Julio:** conservar las reglas y revisar primero recompensas y balance. Los cambios de esta revisión corrigen interacción e información; no cambian baraja, costes, meta, umbral ni bonificaciones del juego.

**Antecedente del 13 de noviembre:** las cifras y comparaciones de este informe corresponden al coste por carta anterior. Desde el 14 de noviembre rige una campanada por mano y pedir gratis; consultar [el ajuste vigente](../../ITERACION_01.md#ajuste-de-jugabilidad-del-14-de-noviembre). Reejecutar el diagnóstico usa el núcleo actual y no reproduce las tasas históricas de este informe.

## Qué se pone a prueba

El reto previsto es conseguir **200 puntos con diez campanadas**, eligiendo entre asegurar una mano, pedir para buscar un multiplicador o devolver una Llave elegible. Cada robo tiene incertidumbre incluso sin Máscaras: su valor y palo todavía no se conocen. Las Máscaras añaden incertidumbre dentro de la mano, pero no existe una acción para adivinar su número.

La revisión técnica anterior acreditó funcionamiento y casos de reglas; no acreditó balance ni diversión. El recorrido preparado de 221 puntos muestra una victoria posible, pero no su frecuencia en una baraja normal.

Hay dos aspectos que conviene separar:

- **Información e interacción:** antes solo se veía la suma, sin la puntuación que ofrecía plantarse; los atajos quedaban pegados al borde y la Llave se elegía en una ventana separada. Se corrigieron estos puntos.
- **Recompensa y capacidad de decisión:** iniciar entrega dos cartas por una campanada; pedir entrega una por el mismo coste. Construir una mano larga necesita una compensación suficiente. Ascenso y Racha dependen de un orden que el jugador apenas puede dirigir; una recompensa mayor no elimina ese límite.

## Simulación del controlador real

Se probaron **1.000 semillas compartidas por política**, de 0 a 999. Los bots deciden exclusivamente con `obtener_vista()`: no consultan valores de Máscaras ni cartas futuras. Usan como estimación de cada Máscara la media del catálogo público, `34/6`; el intervalo 1–10 de la UI no representa probabilidades.

Todas las políticas usan la misma regla simple de Llave: devolver una Llave 9 o intentar corregir un exceso mínimo demostrable, salvo conservar un 16/17 conocido. «Sin pedir» puede usar esa devolución gratuita; no significa que ignore las Llaves.

| Política | Media de puntos | Mediana | Victorias | Quiebra por mano |
| --- | ---: | ---: | ---: | ---: |
| Plantarse sin pedir | 147,85 | 143 | 8,8 % | 2,80 % |
| Pedir mientras la estimación sea menor que 9 | 150,49 | 149 | 15,1 % | 5,41 % |
| Pedir mientras sea menor que 11 | 145,06 | 143 | 17,6 % | 12,01 % |
| Pedir mientras sea menor que 13 | 124,67 | 124 | 11,6 % | 26,29 % |
| Pedir mientras sea menor que 15 | 101,44 | 97 | 8,2 % | 41,91 % |

Las decisiones afectan a los resultados: pedir de más eleva las Quiebras, pero plantarse siempre tampoco maximiza las victorias. Maximizar puntos medios y maximizar victorias no dan la misma política.

En la política «hasta 11», sobre **5.138 manos**, Punto exacto apareció en 6,23 %, Al filo en 8,68 %, Ascenso en 7,08 %, Mano larga en 3,13 % y Racha en 1,52 %. Se usaron 0,532 Llaves por intento. Las frecuencias dependen de esa política y no describen todos los estilos de juego.

Estos bots son sencillos: no cuentan cartas, no optimizan según recursos restantes y no buscan deliberadamente cada patrón. Sus derrotas frecuentes justifican revisar el balance, pero **no demuestran que el juego sea imposible ni estiman la tasa de victoria de personas**.

## Comparación de recompensas, sin aplicarlas al juego

Se mantuvieron costes, cartas, meta 200, umbral 17 y políticas. Solo se recalcularon las manos ya reveladas con tres perfiles:

- **A, actual:** valores vigentes del GDD.
- **B, patrones:** Ascenso +3, Mano larga +4 y Racha +3; los demás bonos permanecen iguales.
- **C, Velas:** cada Vela aporta +2 al multiplicador; los patrones permanecen iguales.

| Política | Victorias A | Victorias B | Victorias C |
| --- | ---: | ---: | ---: |
| Sin pedir | 8,8 % | 8,8 % | 43,8 % |
| Hasta 9 | 15,1 % | 21,2 % | 47,4 % |
| Hasta 11 | 17,6 % | 23,3 % | 43,4 % |
| Hasta 13 | 11,6 % | 19,0 % | 31,9 % |
| Hasta 15 | 8,2 % | 12,9 % | 19,6 % |

**Lectura:** B mejora las políticas que piden sin beneficiar al bot que nunca pide; es un candidato para una prueba de recompensas. C facilita ganar, pero también refuerza las manos cortas: sin pedir alcanza 43,8 %, cerca de su mejor resultado de 47,4 %. No lo adoptaría como solución al problema de incentivar construir patrones.

La comparación utiliza un horizonte diagnóstico de un millón de puntos para observar todo el presupuesto; cada perfil termina virtualmente al primer cruce de 200. Las políticas no consultan meta ni puntuación. El perfil A reproduce la simulación original. Los bots no se reoptimizaron para B/C: los porcentajes no seleccionan automáticamente valores definitivos.

## Recomendación de trabajo

1. Probar la UI corregida con las reglas actuales: comprobar si se comprende por qué cerrar, pedir o cambiar una Llave. I1-07 sigue pendiente de comentarios.
2. Registrar puntos, campanadas, Quiebras, patrones obtenidos, decisión de Llave y explicación de la persona. Distinguir una decisión razonada de una victoria por una buena mano.
3. Comparar una variante de recompensas como B con la actual, sin introducir cartas adicionales, selección entre robos ni poderes nuevos. Fijar antes qué se desea mejorar: construir patrones frente a repetir manos cortas.
4. Actualizar GDD, evaluador y pruebas conjuntamente solo si se decide adoptar valores diferentes. B es una hipótesis medida; **no está implementada ni aprobada como balance final**.

El piloto de tres personas sirve para observar comprensión y dificultades; esa muestra no permite fijar una tasa de victoria final ni demostrar balance.

## Correcciones de interacción realizadas

- Clic/Enter en una Llave elegible la selecciona dentro de la mano. Un contorno y el texto «Llave elegida» mantienen visible la elección.
- ✓ Confirmar y × Cancelar aparecen junto a esa carta. Elegir o cancelar no cambia recursos; confirmar reemplaza exactamente la elegida y añade la nueva al final. Se retiraron la ventana de selección y el botón permanente de devolución.
- L recorre las Llaves elegibles y Esc cancela. Abrir ayuda o recibir una vista nueva invalida la elección anterior.
- P/S se muestran dentro de sus botones; H/R junto a sus acciones. Se retiró la fila diminuta inferior. También se separó «DE 10» del contador.
- Sin Máscaras se muestra la puntuación calculada que ofrece plantarse y el multiplicador; con Máscaras no se publica un resultado anticipado. Se indica cuánto falta para la meta.
- Se corrigió el recorte de segundas líneas por el interlineado de Godot, y el color de texto enfocado del botón de confirmación sobre fondo dorado.
- La botonera se vuelve a centrar tras el ordenamiento del reparto para mantenerse junto a la Llave elegida, incluso si se selecciona antes de que termine el frame.

La suite técnica del 13 de noviembre pasó **90 pruebas y 790 aserciones**. Se revisaron capturas a 1024×576, 1280×720 y 1920×1080; la revisión independiente comprobó además 22 condiciones de teclado, foco, sustitución, contención y privacidad. La validación vigente se recoge en [REVISION_I1.md](REVISION_I1.md). Estas comprobaciones no sustituyen I1-07.

## Reproducir el diagnóstico

Desde la raíz del repositorio, con `$GodotExe` apuntando a Godot 4.7.2:

```powershell
$Analisis = (Resolve-Path '2P/Desarrollo/Analisis/diagnostico_balance.gd').Path
& $GodotExe --headless --path '2P/Desarrollo/juego' --script $Analisis -- --muestras=1000
```

El script usa el controlador real, verifica cada puntuación del perfil A y guarda `juego/exportaciones/analisis/balance_i1.json`, excluido de Git y del ejecutable. Los perfiles de comparación solo existen en el diagnóstico.

## Referencia revisada

Se clonó **Codex-Code-Game-Studios**, commit `9a182e29f8d9b46394851830ba27213fbe4da950`, fuera del proyecto. Se leyeron las guías de diseño, balance, revisión de prototipos y sus plantillas relevantes. Es una colección de procesos y herramientas de desarrollo; no aporta por sí sola mecánicas ni balance a esta mesa. No se ejecutó su instalador ni se incorporaron sus agentes, hooks o configuraciones al repositorio.

Sus criterios útiles son explicitar decisiones del jugador, parámetros, incentivos, métricas y aspectos todavía no validados. Referencias: [README](https://github.com/Euraika-Labs/Codex-Code-Game-Studios/blob/9a182e29f8d9b46394851830ba27213fbe4da950/README.md), [plantilla de diseño](https://github.com/Euraika-Labs/Codex-Code-Game-Studios/blob/9a182e29f8d9b46394851830ba27213fbe4da950/docs/studio/templates/game-design-document.md) y [revisión de balance](https://github.com/Euraika-Labs/Codex-Code-Game-Studios/blob/9a182e29f8d9b46394851830ba27213fbe4da950/.agents/skills/balance-check/SKILL.md).
