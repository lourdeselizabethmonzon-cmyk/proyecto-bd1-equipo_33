/* ============================================================
   OPTIMIZACIÓN Y RENDIMIENTO
   OBJETIVO:
   Mejorar los tiempos de ejecución de las consultas e informes 
   más pesados del sistema mediante la creación de índices no clúster 
   estratégicos y el análisis de planes de ejecución.

   ESCENARIO:
   Se identificaron consultas repetitivas de reportes de ventas y 
   filtrados por fechas que generaban alto costo de E/S (Table Scans).

   SECUENCIA DE EJECUCIÓN:
   1. Creación de índices no clúster en columnas clave de la tabla 
      venta para evitar escaneos completos.
   2. Activación de estadísticas de rendimiento (IO y Tiempo) para 
      la medición comparativa.
   3. Ejecución de la consulta optimizada de reporte de ventas por cliente.

   RESULTADO ESPERADO SEGÚN LOS DATOS DE PRUEBA:
   - Reducción drástica en las lecturas lógicas de E/S.
   - Mejora en el tiempo de respuesta del servidor ante consultas agrupadas.
   ============================================================ */

USE CorrientesPoraBus;
GO

PRINT '1. CREACIÓN DE ÍNDICES NO CLÚSTER';
-- Índice para acelerar los filtros y rangos por fecha en las ventas
CREATE NONCLUSTERED INDEX IX_venta_Fecha 
ON venta (fecha);
GO

-- Índice para optimizar las consultas y reportes agrupados por cliente
CREATE NONCLUSTERED INDEX IX_venta_Cliente 
ON venta (id_cliente);
GO


PRINT '2. ACTIVACIÓN DE ESTADÍSTICAS DE RENDIMIENTO';
-- Habilitamos las estadísticas para medir el impacto de la optimización
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO


PRINT '3. EJECUCIÓN DE CONSULTA OPTIMIZADA (Informe de Ventas)';
-- Consulta mejorada que aprovecha los índices creados para evitar Table Scans
SELECT 
    c.id_cliente,
    p.Nombre_1 + ' ' + p.Apellido_1 AS Cliente,
    COUNT(v.id_venta) AS total_transacciones,
    SUM(v.total) AS monto_acumulado
FROM 
    Cliente_comprador c
JOIN 
    Persona p ON c.Id_Persona = p.Id_Persona
INNER JOIN 
    venta v ON c.Id_Persona = v.id_cliente
WHERE 
    v.fecha >= '2026-01-01'
GROUP BY 
    c.id_cliente,
    p.Nombre_1,
    p.Apellido_1;
GO
