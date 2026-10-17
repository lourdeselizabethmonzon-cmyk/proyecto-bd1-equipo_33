# Comprobante de Venta: Encabezado, Detalle y Total Acumulado

Durante años, al llevar registros en planillas manuales, los datos del cliente, la fecha o el número de factura debían repetirse en cada línea, lo que generaba redundancia, datos desactualizados y un riesgo permanente de inconsistencia.

Frente a esta limitación, el pasaje a un Sistema de Gestión de Bases de Datos relacional permite normalizar la información en entidades separadas (`Venta`, `Cliente_comprador`, `Pasaje`, `Viaje`). De esta forma se garantiza la integridad de los datos, se congelan las tarifas al momento exacto de la transacción y se asegura que cada comprobante emitido sea único, consistente y auditable.

---

## Desarrollo Técnico

### Unificación de Datos y Relaciones

Para unificar los datos generales de la operación (encabezado) con cada uno de los pasajes adquiridos (detalle), se recurre a combinaciones internas múltiples (`INNER JOIN`) dentro de la cláusula `FROM`:

* **Cruce por claves:** El motor compara las claves primarias y foráneas (`v.Id_Cliente = c.Id_Persona`, `v.Id_Venta = pas.Id_Venta`, etc.), evitando el producto cartesiano y trayendo únicamente las filas que guardan una relación lógica estricta.
* **Filtro transaccional:** La cláusula `WHERE v.Id_Venta = 4` actúa como el filtro de selección necesario para restringir el comprobante a la transacción requerida sin traer registros ajenos.

---

### Transformaciones en la Cláusula SELECT

En la cláusula `SELECT`, se aplican operadores y funciones escalares de fila:

* **Identidad del cliente:** Se utiliza el operador de concatenación (`+`) para unificar nombre y apellido en una sola columna legible (`ClienteComprador`).
* **Depuración de hora:** Mediante `CAST(vi.Hora_Salida AS TIME(0))` se eliminan los decimales de microsegundos, adaptando el formato al estándar comercial.
* **Subtotal por renglón:** Al representar cada fila exactamente un pasaje individual, el campo `pas.Precio_Unitario AS SubtotalRenglon` cumple de forma explícita con el cálculo del importe correspondiente a ese renglón particular.

---

### Cálculo Dinámico del Total Acumulado

En lugar de recurrir a fórmulas externas en hojas de cálculo que pueden corromperse, el cálculo se resuelve de manera dinámica dentro del motor utilizando la función analítica de agregación `SUM()` con ventana:

```sql
SUM(pas.Precio_Unitario) OVER(
    PARTITION BY v.Id_Venta 
    ORDER BY pas.Id_Pasaje
) AS TotalAcumuladoComprobante