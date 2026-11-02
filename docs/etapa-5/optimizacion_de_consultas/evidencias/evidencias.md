# Evidencias de Ejecución - Optimización de Consultas

## 1. Descripción del Caso
El objetivo de este caso es optimizar la generación de informes analíticos de ventas por rango de fechas en el sistema **CorrientesPoraBus**. Ante un alto volumen transaccional, se busca evitar costosos recorridos completos de tabla (*Table Scans*) mediante la implementación de índices no clúster y la medición precisa de recursos computacionales.

* **Tablas involucradas:** `Venta`, `Cliente_comprador`, `Persona` y `Pasaje`.
* **Mejoras aplicadas:**
  - Creación de índices no clúster (`IX_Venta_Fecha` y `IX_Venta_Cliente`) para acelerar las operaciones de búsqueda y filtrado.
  - Activación de diagnósticos de E/S y rendimiento (`SET STATISTICS IO` y `SET STATISTICS TIME`).

---

## 2. Evidencia de Resultados (Integridad Lógica)
La siguiente captura de pantalla demuestra que la ejecución de la consulta optimizada devuelve correctamente los datos esperados por el negocio, agrupando el total de transacciones y calculando el monto acumulado de los pasajes por cliente sin alterar la lógica de los datos.

<img width="1365" height="767" alt="image" src="https://github.com/user-attachments/assets/76720da2-fccb-45a2-b846-8befbe0689c3" />

## 3. Evidencia de Rendimiento (Estadísticas de E/S y CPU)
En la siguiente captura de la pestaña de mensajes del servidor, se registran las estadísticas de E/S generadas por `SET STATISTICS IO`. Se observa una reducción drástica en las **lecturas lógicas (*logical reads*)** en las tablas involucradas, confirmando que el motor utiliza eficazmente los índices creados en lugar de realizar escaneos completos.

<img width="1365" height="767" alt="image" src="https://github.com/user-attachments/assets/6a4a9362-c797-48da-83f5-146e7c3d10ff" />
