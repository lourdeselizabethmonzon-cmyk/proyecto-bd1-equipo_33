# DOCUMENTACIÓN DE EVIDENCIAS: MANEJO DE TRANSACCIONES

## 1. PRESENTACIÓN Y OBJETIVO

En esta sección se detallan las pautas, el desarrollo y la estructura para la presentación de evidencias visuales del funcionamiento de las transacciones implementadas en la base de datos de **Corrientes Porá Bus**, demostrando el control de atomicidad y consistencia ante escenarios de ejecución correctos e incorrectos.

---

## 2. CASOS DE PRUEBA EJECUTADOS

### 2.1. Prueba Exitosa (COMMIT)
* **Descripción:** Se ejecuta el registro de un pasaje dentro del límite de butacas disponibles del colectivo asignado.
* **Resultado Esperado:** La operación se procesa con éxito, se genera el registro en las tablas `Venta` y `Pasaje`, y se confirma de forma permanente mediante `COMMIT TRANSACTION`.
* **Evidencia Visual Incluida:** Captura de pantalla de SQL Server Management Studio (SSMS) donde se observa:
  * El mensaje de salida indicando que la transacción fue exitosa.
  * La confirmación de las filas afectadas e insertadas en la base de datos.

### 2.2. Prueba con Fallo y Reversión (ROLLBACK)
* **Descripción:** Se intenta registrar una compra de pasajes que supera la capacidad máxima de butacas permitidas para el colectivo en ese viaje.
* **Resultado Esperado:** El sistema detecta la falta de disponibilidad, dispara una excepción lógica y ejecuta `ROLLBACK TRANSACTION`, cancelando toda la operación.
* **Evidencia Visual Incluida:** Captura de pantalla de SQL Server Management Studio (SSMS) donde se observa:
  * El mensaje impreso por la transacción confirmando la ejecución del `ROLLBACK`.
  * La comprobación de que **NO** se creó ningún registro parcial ni en `Venta` ni en `Pasaje`, garantizando la propiedad de atomicidad.

---

## 3. ORGANIZACIÓN Y REGISTRO VISUAL

1. **Paso 1:** Ejecutar el script de prueba de `COMMIT` en SSMS.
2. **Paso 2:** Ejecutar el script de prueba de `ROLLBACK` en SSMS.
3. **Paso 3:** Capturar la ventana de salida de mensajes de SSMS.
4. **Paso 4:** Guardar la imagen en el directorio: `docs/etapa-5/transacciones/evidencias/`.

---

## 4. CAPTURA DE PANTALLA ADJUNTA

[Prueba de Transacciones en SSMS](image.png)
