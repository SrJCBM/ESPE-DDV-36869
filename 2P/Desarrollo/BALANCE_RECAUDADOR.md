# Balance del Recaudador · ¿la comisión cambia cómo conviene jugar?

**19 de noviembre de 2026 · Kenned.** Precios y reglas actuales, sin cambios. Los resultados alimentan la decisión del equipo junto con los comentarios que recoja Ariel.

## Resultado

200 repartos; cada semilla produce la misma baraja en las cuatro combinaciones. Mesa del Recaudador: umbral 21, meta 400, 12 campanadas y una ficha por cada carta pedida tras el reparto.

| Recorrido | Estilo | Saldo al sentarse | Fichas en comisiones (media por intento) | Manos en que quiso pedir sin saldo | Intentos ganados |
|---|---|---:|---:|---:|---:|
| Ahorra | Se planta pronto | 45 | 18,0 | 0 | **178 / 200** |
| Ahorra | Pide una carta más | 45 | 31,0 | 0 | 89 / 200 |
| Compra | Se planta pronto | 18 | 13,0 | 55 (en 22 intentos) | **198 / 200** |
| Compra | Pide una carta más | 18 | 17,6 | 967 (en 168 intentos) | 135 / 200 |

## Conclusión

- **La comisión no cambia el estilo que conviene.** Plantarse pronto gana más en los dos recorridos. Pedir una carta más cuesta 89 victorias a quien ahorra y 63 a quien compra.
- **Quedarse sin fichas no castiga a quien compra: lo frena.** Con 18 fichas, el estilo arriesgado se queda sin saldo en casi 6 manos por intento y se ve obligado a plantarse. Por eso gana 135 veces frente a 89 de quien ahorra, aunque juega igual.
- **La comisión sí pesa en la economía.** Quien ahorra gasta de 18 a 31 de sus 45 fichas, más que el precio de una Corona. Esas fichas ya no llegan a la tienda antes de la Coleccionista.
- **Límite de la comparación.** La fila «Compra» mezcla dos efectos: menos saldo y los objetos (Corona +2 con una Máscara oculta al plantarse; Sello del prudente, hasta dos campanadas). Parte de las 198 victorias viene de los objetos, no de la comisión.

## Mano que lo ilustra

Semilla 0, sexta mano. Hasta aquí los dos recorridos jugaron exactamente igual. Ambos tienen **1 de Máscaras, 1 de Llaves, 2 de Llaves, 7 de Relojes y 8 de Máscaras**. A la vista hay 9 puntos conocidos y dos Máscaras ocultas, con un intervalo de 11 a 29. La regla base dice plantarse; el estilo arriesgado quiere una carta más.

| | Decisión | Mano final | Resultado |
|---|---|---|---|
| Compra (0 fichas) | No puede pagar la comisión y se planta | Total 18 | Mano larga + Corona: 18 × 5 = **90 puntos** |
| Ahorra (26 fichas) | Paga una ficha y pide | Recibe 9 de Relojes (vale 8): total 26 | **Quiebra, 0 puntos** |

Ambos superan la mesa en ese intento (419 y 430 puntos). La comisión impidió una carta que convertía 90 puntos en cero. Sin la Corona, la misma mano habría valido 54.

## Cómo se jugó

- **Recorridos.** Ambos salen del Custodio con 30 fichas: diez iniciales más el premio con dos Puntos exactos (10 + 5 × 2), como en el ejemplo del GDD. *Ahorra* no compra nada. *Compra* adquiere Corona del riesgo (15) y Sello del prudente (12). Ninguno modifica la baraja, para conservar los mismos repartos.
- **Se planta pronto.** Pide mientras el punto medio del intervalo visible quede seis o más por debajo del umbral. Es la misma regla de la simulación de [ITERACION_02.md](ITERACION_02.md).
- **Pide una carta más.** Igual, pero cuando la regla indica plantarse, pide una carta adicional una vez por mano.
- **En ambos estilos.** Con Quiebra segura devuelve la Llave elegible de mayor valor. La estrategia solo usa la vista pública: nunca conoce Máscaras ocultas ni el orden del mazo.
- **Sin saldo.** Si quiere pedir y no tiene fichas, se planta. Esa mano se cuenta una vez en la cuarta columna.

## Repetir la prueba

La simulación usa `CampanaCasino`, `ControladorMesa` y los comandos reales del juego.

1. Abrir el proyecto con Godot 4.7.2 y ejecutar **GUT → Run All**, o solo `tests/test_balance_recaudador.gd`. Por consola:

   ```powershell
   & $GodotExe --headless --path '2P/Desarrollo/juego' -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_balance_recaudador.gd -gexit
   ```

2. La tabla y la mano de ejemplo aparecen en la salida de GUT. También se guardan en `juego/exportaciones/qa/balance_recaudador.md` y `.json`, fuera de Git.
3. Para probar otros supuestos, editar las constantes de `tests/sim_recaudador.gd`: `SEMILLAS`, `SALDO_TRAS_CUSTODIO`, `RECORRIDOS` (compras), `ESTILOS` y `MARGEN`.
