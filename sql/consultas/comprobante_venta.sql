USE CorrientesPoraBus;
GO

-- =============================================================================
-- CONSULTA 1: FACTURA / COMPROBANTE DE VENTA
-- Encabezado y detalle de una venta, calculando subtotales y total acumulado.
-- =============================================================================
SELECT 
    v.Id_Venta AS NroComprobante,
    v.Fecha AS FechaVenta,
    p_cli.Nombre_1 + ' ' + p_cli.Apellido_1 AS ClienteComprador,
    pas.Id_Pasaje AS NroPasaje,
    t_orig.Nombre AS TerminalOrigen,
    t_dest.Nombre AS TerminalDestino,
    CAST(vi.Hora_Salida AS TIME(0)) AS Hora_Salida,
    pas.Precio_Unitario AS SubtotalRenglon,
   
    SUM(pas.Precio_Unitario) OVER(
        PARTITION BY v.Id_Venta 
        ORDER BY pas.Id_Pasaje
    ) AS TotalAcumuladoComprobante
FROM 
    Venta v
INNER JOIN 
    Cliente_comprador c ON v.Id_Cliente = c.Id_Persona
INNER JOIN 
    Persona p_cli ON c.Id_Persona = p_cli.Id_Persona
INNER JOIN 
    Pasaje pas ON v.Id_Venta = pas.Id_Venta
INNER JOIN 
    Viaje vi ON pas.Id_Viaje = vi.Id_Viaje
INNER JOIN 
    Ruta r ON vi.Id_Ruta = r.Id_Ruta
INNER JOIN 
    Terminal t_orig ON r.Id_Terminal_Origen = t_orig.Id_Terminal
INNER JOIN 
    Terminal t_dest ON r.Id_Terminal_Destino = t_dest.Id_Terminal
WHERE 
    v.Id_Venta = 4;
GO