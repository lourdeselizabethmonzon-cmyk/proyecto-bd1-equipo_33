# INFORME TÉCNICO: TRIGGERS DE AUDITORÍA EN SQL SERVER EXPRESS

## 1. DEFINICIÓN Y OBJETIVO

Un trigger (o disparador) es un bloque de código procedimental que el motor de base de datos ejecuta de manera automática e inmediata ante la ocurrencia de un evento de manipulación de datos (`INSERT`, `UPDATE` o `DELETE`) sobre una tabla o vista. A diferencia de las rutinas convencionales que exigen una invocación manual, su activación es implícita y controlada por el propio sistema gestor, lo que convierte a estos artefactos en el mecanismo estándar para implementar soluciones de auditoría interna y trazabilidad.

En arquitecturas cliente/servidor donde múltiples puestos de trabajo acceden concurrentemente a una misma fuente de datos, el seguimiento de las operaciones adquiere un carácter crítico. La auditoría en este ámbito se define como el registro sistemático y persistente de las transacciones realizadas por los usuarios, y tiene como objetivo fundamental garantizar la rendición de cuentas respondiendo con exactitud cuatro interrogantes operativas:

- **¿Qué se hizo?:** Registro de la acción ejecutada (`UPDATE` o `DELETE`), contrastando el valor anterior con el valor nuevo a través de las tablas lógicas del motor relacional (`deleted` e `inserted`).
- **¿Quién lo hizo?:** Individualización de la cuenta o usuario responsable de la transacción (`SYSTEM_USER`).
- **¿Dónde se hizo?:** Identificación de la terminal o estación de trabajo desde la cual se originó el comando (`HOST_NAME()`).
- **¿Cuándo se hizo?:** Marca temporal exacta de la confirmación transaccional (`GETDATE()`).

---

## 2. VENTAJAS Y APLICACIONES

En un sistema de gestión de bases de datos relacionales, el uso de triggers de auditoría aporta ventajas estructurales clave frente a los controles por software:

- **Automatización total:** Se ejecutan de forma automática ante cada modificación o baja física, sin depender de llamadas manuales desde la aplicación cliente.
- **Seguridad y auditoría infalible:** Registran cualquier alteración sobre tablas críticas, incluso si la sentencia se ejecuta directamente por consola o gestor de base de datos (SSMS).
- **Centralización de reglas:** La lógica de control se programa una sola vez en el motor relacional, asegurando que todos los puestos cumplan idénticos criterios de registro.
- **Trazabilidad exacta:** Permiten comparar el estado anterior y el nuevo al instante mediante las tablas lógicas del sistema (`deleted` e `inserted`).
- **Validaciones avanzadas:** Permiten auditar columnas sensibles de forma aislada sin afectar la persistencia del resto de la entidad.

---

## 3. IMPLEMENTACIÓN EN SQL SERVER EXPRESS

En SQL Server Express, los disparadores de auditoría se configuran mediante la cláusula `AFTER UPDATE, DELETE`. Durante el ciclo de vida de la sentencia, el motor gestiona automáticamente dos estructuras temporales en memoria:

1. **`UPDATE` (Modificación):** El motor carga ambas estructuras concurrentemente.
   - `deleted`: contiene la imagen previa de la fila (valor anterior).
   - `inserted`: contiene la fila con las modificaciones aplicadas (valor nuevo).
   - *Mecánica:* El trigger compara ambas tablas (`inserted.columna <> deleted.columna`) e inserta en la tabla de auditoría exclusivamente los atributos que sufrieron variaciones.
2. **`DELETE` (Baja física):** El motor carga únicamente la estructura `deleted`.
   - `deleted`: almacena el registro completo antes de ser destruido.
   - `inserted`: permanece vacía.
3. **`INSERT` (Alta):** Carga únicamente la estructura `inserted`. En auditoría de datos operacionales no se requiere disparador para altas, dado que la fila entrante persiste de forma íntegra en la tabla de negocio con su clave primaria y marca temporal.

---

## 4. CASO CONCRETO APLICADO A "CORRIENTES PORÁ BUS"

### 4.1. Problema de Negocio
Uno de los principales problemas planteados en el sistema fue la falta de control del personal y auditoría de ventas: no quedaba un registro claro de qué empleado realizó cada operación, en qué boletería o en qué horario exacto, lo que imposibilitaba determinar responsabilidades ante una anulación indebida de pasajes cobrados, una adulteración de precios o faltantes de dinero en caja.

### 4.2. Reglas Lógicas Aplicadas
- **RN03 – Inmutabilidad del Pasaje y Tarifas:** Una vez emitido un pasaje o asignada una tarifa base a un viaje, cualquier modificación posterior sobre los precios debe quedar registrada identificando el valor previo, el nuevo valor, la cuenta de usuario y la fecha exacta.
- **RN07 – Trazabilidad de Anulaciones:** Las cancelaciones de ventas confirmadas (`Estado = 'Cancelada'`) deben auditarse de forma obligatoria para evitar fraudes de anulación sobre boletos cobrados en boletería.
- **RN08 – Trazabilidad y Responsabilidad de Emisión:** Toda transacción debe asociarse de forma verificable al operador y a la terminal física desde donde se procesó la solicitud.

---
