-- ============================================================================
-- PROYECTO: CorrientesPoraBus
-- TEMA: Optimización de Consultas 
-- DESCRIPCIÓN: Creación de índices no clúster y ejecución del reporte 
--              optimizado de ventas y pasajes por cliente.
-- ============================================================================

USE CorrientesPoraBus;
GO

-- ----------------------------------------------------------------------------
-- 1. CREACIÓN DE ÍNDICES NO CLÚSTER ESTRATÉGICOS
-- Transformación de escaneos completos (Table Scans) en búsquedas directas (Index Seeks)
-- ----------------------------------------------------------------------------

-- Índice sobre el campo de filtrado por fecha en la tabla Venta
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Venta_Fecha' AND object_id = OBJECT_ID('Venta'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Venta_Fecha 
    ON Venta (Fecha);
END;
GO

-- Índice sobre la clave foránea del cliente en la tabla Venta
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Venta_Cliente' AND object_id = OBJECT_ID('Venta'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Venta_Cliente 
    ON Venta (Id_Cliente);
END;
GO

-- ----------------------------------------------------------------------------
-- 2. ACTIVACIÓN DE HERRAMIENTAS DE DIAGNÓSTICO DE RENDIMIENTO
-- ----------------------------------------------------------------------------
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- ----------------------------------------------------------------------------
-- 3. CONSULTA OPTIMIZADA: INFORME DE VENTAS Y PASAJES ACUMULADOS POR CLIENTE
-- Agrupación de transacciones y suma de montos a partir de un rango de fechas
-- ----------------------------------------------------------------------------
SELECT 
    v.Id_Cliente,
    p.Nombre_1 + ' ' + p.Apellido_1 AS Cliente,
    COUNT(v.Id_Venta) AS total_transacciones,
    ISNULL(SUM(ps.Precio_Unitario), 0.00) AS monto_acumulado
FROM 
    Cliente_comprador c
INNER JOIN 
    Persona p ON c.Id_Persona = p.Id_Persona
INNER JOIN 
    Venta v ON c.Id_Persona = v.Id_Cliente
LEFT JOIN 
    Pasaje ps ON v.Id_Venta = ps.Id_Venta
WHERE 
    v.Fecha >= '2026-01-01'
GROUP BY 
    v.Id_Cliente,
    p.Nombre_1,
    p.Apellido_1;
GO

-- Desactivación opcional de estadísticas
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
