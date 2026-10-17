## CONSULTA 2: Reporte Agregado por Vendedor

Durante años, la falta de centralización y el manejo mediante planillas manuales provocaron severas dificultades cotidianas en la empresa: cierres de caja y arqueos manuales propensos a errores al finalizar cada turno, una total falta de informes y estadísticas para evaluar el rendimiento comercial, y una marcada ausencia de control sobre el personal y auditoría de ventas, impidiendo saber con certeza qué volumen de transacciones y dinero recaudó cada empleado.

Frente a esta problemática, el uso de un Sistema de Gestión de Bases de Datos relacional permite centralizar y auditar cada transacción en tiempo real vinculando al vendedor con sus comprobantes emitidos. A través de SQL, la gerencia puede consolidar métricas clave de recaudación y productividad de manera instantánea, dejando atrás los arqueos manuales en papel y transformando registros dispersos en información estratégica para la toma de decisiones.

### Desarrollo

Para consolidar el desempeño de cada vendedor dentro de un período determinado, la consulta vincula las transacciones con los datos del personal mediante combinaciones internas (`INNER JOIN`) dentro de la cláusula `FROM`:

* **Vinculación relacional:** El motor relaciona Venta, Empleado, Persona y Pasaje a través de sus claves primarias y foráneas (`v.Id_Empleado = e.Id_Persona`, `e.Id_Persona = p_emp.Id_Persona`, `v.Id_Venta = pas.Id_Venta`), asegurando la trazabilidad exacta entre el empleado responsable y cada boleto efectivamente emitido.
* **Filtrado temporal:** La cláusula `WHERE v.Fecha BETWEEN '2026-09-01' AND '2026-10-31'` delimita el análisis a un rango de fechas específico, permitiendo evaluar cierres mensuales o períodos de auditoría puntuales sin interferencia de datos fuera de término.

Por otro lado, en la cláusula `SELECT` y mediante el uso de `GROUP BY`, se aplican funciones escalares y funciones de agregación para resumir la actividad comercial:

* **Identificación del vendedor:** Se extrae el legajo del empleado y se utiliza el operador de concatenación (`+`) sobre nombre y apellido (`p_emp.Nombre_1 + ' ' + p_emp.Apellido_1 AS Vendedor`) para obtener una salida clara y legible del personal auditado.
* **Conteo de transacciones únicas (`COUNT DISTINCT`):** Dado que una venta puede contener múltiples pasajes, se aplica `COUNT(DISTINCT v.Id_Venta) AS CantidadVentasRealizadas`. Esto evita duplicar comprobantes y refleja con exactitud la cantidad real de clientes atendidos o transacciones concretadas.
* **Volumen de pasajes emitidos:** Mediante `COUNT(pas.Id_Pasaje) AS TotalPasajesVendidos`, se contabiliza la cantidad total de boletos físicos comercializados por cada agente.

Por último, el cálculo económico y la jerarquización del reporte se resuelven de forma directa en el motor:

```sql
SUM(pas.Precio_Unitario) AS RecaudacionTotal
...
GROUP BY 
    e.Legajo,
    p_emp.Nombre_1,
    p_emp.Apellido_1
ORDER BY 
    RecaudacionTotal DESC;
    