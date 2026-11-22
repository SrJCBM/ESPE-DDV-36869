# Revisión técnica de I1 · mesa del Custodio

**Fecha:** 13 de noviembre de 2026. **Versión:** 0.1.0. **Entorno:** Godot `4.7.2.stable.official.ed1daf0bf`, GDScript, Compatibility y GUT 9.7.1. La base de Kenned `5d73d50` se conserva en el historial; la implementación se integra en `main` local.

## Alcance comprobado

- Catálogo exacto de 24 cartas; identidades opacas e independencia entre catálogo e intentos.
- Mano, mazo, descarte y reciclaje sin duplicados ni incorporación de la mano actual al descarte reciclado.
- Iniciar cuesta una campanada; pedir, plantarse y devolver Llave son gratis. Las solicitudes rechazadas conservan el estado. *Esta revisión se hizo con el coste anterior, en el que pedir también gastaba una campanada; el coste por mano rige desde el 14 de noviembre ([ITERACION_01.md](ITERACION_01.md#ajuste-de-jugabilidad-del-14-de-noviembre)) y la suite vigente lo comprueba.*
- Llave inicial o recién pedida, una devolución por mano, reemplazo diferente añadido al final y sin devolución encadenada.
- Máscaras ocultas: la vista, la ampliación, el tooltip y la etiqueta accesible no revelan el valor. El intervalo usa cotas conservadoras.
- Cuatro palos, cinco patrones y sus condiciones; Quiebra produce cero. El orden real de robo se conserva.
- Resolución única, protección frente a reentrada por señales, victoria antes de derrota con cero y reinicio desde ambos finales.
- Command, estados concretos de State, Observer mediante señales y fábrica simple identificables en el código y las pruebas.

## Pruebas y resultados

| Comprobación | Resultado observado |
| --- | --- |
| Suite completa de seis scripts GUT | **78/78 pruebas, 730 aserciones, código 0**; sin errores, avisos ni nodos huérfanos en el registro |
| Revisión independiente de reglas y vista | 49/49 pruebas y 583 aserciones; sin defectos reproducibles encontrados en el alcance I1 |
| Revisión independiente de interfaz | 23/23 pruebas y 116 aserciones; sin defectos críticos ni importantes encontrados |
| R01–R20 | Cubiertos por baraja, acciones/estados, puntuación y vista; los ejemplos de aceptación coinciden con el GDD v2.4 |
| Demostración del encuentro | 102 → Quiebra → 119 = **221 puntos** y victoria; quedaban 3 campanadas con el coste anterior y quedan **7** con el vigente |
| Teclado | Enter/Espacio ejecutan botones nativos una vez; atajos bloqueados tras ayuda; foco conservado al actualizar cartas y recuperado al cerrar ventanas |
| Movimiento reducido y cancelación | Estado final inmediato; reiniciar durante transiciones no restaura puntuaciones ni cartas antiguas |
| Revisión visual mediante capturas | Inicio, Máscara, ayuda, cuatro páginas del libro, confirmación, Llave, desglose, Quiebra y victoria; tamaños 1024×576, 1280×720 y 1920×1080 según cada caso |
| Contraste de pares informativos | Tinta/papel 9.33:1, texto secundario/papel 5.61:1, marfil/panel 12.28:1, texto secundario/panel 8.49:1 y tinta/oro 6.22:1; referencia de diseño, no certificación de accesibilidad |
| Exportación Windows release | Código 0; ejecutable actualizado de **120 946 712 bytes**, `.pck` incrustado; GUT, pruebas y capturas excluidos |
| Arranque del ejecutable exportado en Julio | Headless y con renderer gráfico: código 0; sin salida de error. Es una comprobación de arranque local, no un piloto ni una prueba en otro equipo |
| Ejecución de depuración por Godot MCP | Godot 4.7.2; ejecución y parada comprobadas, salida de errores vacía tras corregir avisos |

Comando reproducible desde la raíz, con `$GodotExe` apuntando al editor 4.7.2:

```powershell
& $GodotExe --headless --path '2P/Desarrollo/juego' -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

Las capturas locales se generan con `tests/qa_visual.gd` en `juego/exportaciones/qa/`, excluida de Git y de la exportación. No representan sesiones con participantes. Las instrucciones completas de ejecución y exportación están en [juego/README.md](juego/README.md).

## Pulido y correcciones

- El bloque continuo de ayuda se sustituyó por **El libro del Custodio**: apuesta, palos, patrones/puntos y controles. Conserva las reglas y presenta ejemplos independientes de la partida.
- El desglose usa el boleto de la casa para destacar el aporte, acumulado y meta; las confirmaciones tienen acciones diferenciadas y foco inicial seguro en Cancelar.
- Las cartas conservan sus nodos por identidad: pedir o revelar ya no destruye el foco. El orden visual continúa dependiendo de la vista autorizada.
- Reparto breve, revelación y énfasis compartido por ratón y teclado. Los Tweens quedan ligados a los nodos y se cancelan al sustituir animaciones o activar movimiento reducido.
- La barra de progreso se dimensiona después de aplicar su tema para evitar el mínimo inicial que la hacía demasiado gruesa.
- La ejecución de depuración por MCP detectó avisos por un alias de clase y dos ternarios entre entero y null. Se corrigieron con un nombre de comando inequívoco y variables Variant explícitas; la ejecución por MCP posterior no registró avisos ni errores.
- Se excluyó `exportaciones/*` del preset para impedir que las capturas de revisión entren en el ejecutable. El preset registra versión 0.1.0.0.
- No se incorporaron frameworks externos de cartas o animaciones; se estudiaron como referencias y se mantuvo el núcleo propio.

## Pendientes de aceptación

| Actividad | Estado y responsable |
| --- | --- |
| I1-07: tres participantes ajenos al diseño | **Pendiente; Julio lo ejecutará.** Usar el protocolo y tabla de [ITERACION_01.md](ITERACION_01.md#piloto-de-usabilidad) |
| Correcciones derivadas del piloto | Pendientes hasta contar con observaciones reales |
| Abrir y jugar esta versión exportada en otro equipo | Pendiente; Ariel registra versión, recorrido y resultado |
| Aceptación de diseño y revisión humana cruzada | Pendiente del equipo |
| Publicación de la integración | Integración local; push no realizado en esta entrega |

I1-02 e I1-04 de Ariel quedan Completado. Las otras entregas implementadas permanecen Por revisar; I1-00 continúa En curso por el entorno del tercer integrante. No se declara cerrada toda I1 hasta resolver los pendientes humanos. LAN, campaña, objetos, ajustes persistentes y balance con usuarios pertenecen a trabajo posterior.
