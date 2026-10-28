# INFORME TÉCNICO: MANEJO DE TRANSACCIONES EN SQL SERVER EXPRESS

## 1. DEFINICIÓN Y OBJETIVO

Una transacción es un conjunto de operaciones SQL que se ejecutan como una única unidad lógica de trabajo. Su objetivo principal es garantizar que, si una de las operaciones falla, todas las anteriores se deshacen por completo, manteniendo la integridad de la base de datos. Esto se sustenta en las propiedades **ACID**:

* **Atomicidad:** Todo el bloque se ejecuta con éxito o no se aplica nada.
* **Consistencia:** La base de datos pasa de un estado válido a otro estado válido.
* **Aislamiento:** Las transacciones concurrentes no interfieren entre sí.
* **Durabilidad:** Una vez confirmada, los cambios persisten aunque ocurra un fallo en el sistema.

---

## 2. VENTAJAS Y APLICACIONES

En un sistema de gestión de bases de datos relacionales, el uso de transacciones es crítico porque una operación comercial como una venta de pasajes no afecta a una sola tabla de forma aislada.

* **Evita datos inconsistentes:** Una venta involucra al menos las tablas de `Venta`, `Pasaje` (detalle) y el control de asientos/cupos del viaje. El sistema no puede registrar una venta y dejar el pasaje o el asiento sin asociar por un corte de energía o error de validación.
* **Centraliza la seguridad lógica:** Permite validar reglas de negocio complejas antes de hacer permanentes los cambios en el motor de SQL Server.

---

## 3. IMPLEMENTACIÓN EN SQL SERVER EXPRESS

Para gestionar transacciones de manera explícita en T-SQL, se utilizan tres comandos fundamentales:

1. **`BEGIN TRANSACTION`:** Abre el bloque de control, marcando el inicio de la unidad lógica de trabajo.
2. **`COMMIT TRANSACTION`:** Confirma de forma permanente todos los cambios realizados dentro de la transacción si las validaciones son correctas.
3. **`ROLLBACK TRANSACTION`:** Revierte y deshace todas las operaciones realizadas desde el inicio de la transacción si se detecta un error o infracción a una regla de negocio.

---

## 4. CASO CONCRETO APLICADO A "CORRIENTES PORÁ BUS"

### 4.1. Problema de Negocio
Un cliente desea comprar pasajes para un viaje determinado. El sistema debe registrar la cabecera de la venta, generar el detalle del pasaje y validar en tiempo real que la cantidad solicitada no supere la capacidad máxima (cupo de butacas disponibles) del colectivo asignado.

### 4.2. Regla Lógica Aplicada
1. Se registra la venta en la tabla `Venta`.
2. Se intenta registrar el pasaje en la tabla `Pasaje`.
3. Se evalúa mediante una condición lógica si los asientos ocupados más los solicitados superan el límite del coche.
4. Si excede la capacidad, se ejecuta un `ROLLBACK TRANSACTION` para cancelar la operación y no dejar registros parciales. Si hay disponibilidad, se ejecuta un `COMMIT TRANSACTION`.

---

## 5. DEMOSTRACIÓN Y RESULTADOS OBTENIDOS

Para comprobar el funcionamiento, se diseñaron y ejecutaron dos escenarios de prueba en el script (`scripts.sql`):

* **Prueba Correcta (Con stock/cupo disponible):** Se procesó una compra dentro del límite de butacas. Como resultado, la venta se registró correctamente y se confirmó con `COMMIT TRANSACTION`.
* **Prueba Incorrecta (Superando la capacidad):** Se intentó comprar más pasajes de los disponibles en el colectivo. El sistema detectó el desborde, disparó el `ROLLBACK TRANSACTION` y no quedó ningún registro parcial en las tablas `Venta` o `Pasaje`, demostrando fehacientemente la propiedad de atomicidad.
