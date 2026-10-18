USE CorrientesPoraBus;
GO

-- =============================================================================
-- CONSULTA 2: REPORTE AGREGADO (Por Vendedor)
-- Total de ventas realizadas por cada vendedor en un rango de fechas.
-- =============================================================================
SELECT 
    e.Legajo,
    p_emp.Nombre_1 + ' ' + p_emp.Apellido_1 AS Vendedor,
    COUNT(DISTINCT v.Id_Venta) AS CantidadVentasRealizadas,
    COUNT(pas.Id_Pasaje) AS TotalPasajesVendidos,
    SUM(pas.Precio_Unitario) AS RecaudacionTotal
FROM 
    Venta v
INNER JOIN 
    Empleado e ON v.Id_Empleado = e.Id_Persona
INNER JOIN 
    Persona p_emp ON e.Id_Persona = p_emp.Id_Persona
INNER JOIN 
    Pasaje pas ON v.Id_Venta = pas.Id_Venta
WHERE 
    v.Fecha BETWEEN '2026-09-01' AND '2026-10-31'
GROUP BY 
    e.Legajo,
    p_emp.Nombre_1,
    p_emp.Apellido_1
ORDER BY 
    RecaudacionTotal DESC;
GO