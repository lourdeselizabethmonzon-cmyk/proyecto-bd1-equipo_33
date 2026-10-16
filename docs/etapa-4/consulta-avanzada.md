USE CorrientesPoraBus;
GO

-- =============================================================================
-- CONSULTA 3: CONSULTA DE NEGOCIO AVANZADA (Clientes que superan el promedio)
-- Combina tablas mediante JOIN y aplica filtros con subconsultas y HAVING.
-- =============================================================================
SELECT 
    c.Id_Persona AS Id_Cliente,
    p.Nombre_1 + ' ' + ISNULL(p.Nombre_2 + ' ', '') + p.Apellido_1 AS Cliente,
    p.Nro_Documento,
    COUNT(DISTINCT v.Id_Venta) AS CantidadCompras,
    COUNT(pas.Id_Pasaje) AS PasajesComprados,
    SUM(pas.Precio_Unitario) AS GastoTotalAcumulado
FROM 
    Cliente_comprador c
INNER JOIN 
    Persona p ON c.Id_Persona = p.Id_Persona
INNER JOIN 
    Venta v ON c.Id_Persona = v.Id_Cliente
INNER JOIN 
    Pasaje pas ON v.Id_Venta = pas.Id_Venta
GROUP BY 
    c.Id_Persona,
    p.Nombre_1,
    p.Nombre_2,
    p.Apellido_1,
    p.Nro_Documento
HAVING 
    SUM(pas.Precio_Unitario) > (
        -- Subconsulta: Calcula el promedio general por venta en todo el sistema
        SELECT AVG(MontoTotalVenta)
        FROM (
            SELECT SUM(pas2.Precio_Unitario) AS MontoTotalVenta
            FROM Venta v2
            INNER JOIN Pasaje pas2 ON v2.Id_Venta = pas2.Id_Venta
            GROUP BY v2.Id_Venta
        ) AS TablaDerivadaPromedio
    )
ORDER BY 
    GastoTotalAcumulado DESC;
GO