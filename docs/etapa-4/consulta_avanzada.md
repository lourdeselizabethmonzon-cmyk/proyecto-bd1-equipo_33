# CONSULTA 3: Consulta de Negocio Avanzada

Para consolidar el consumo histórico de cada cliente y compararlo contra el rendimiento general del negocio, la consulta articula combinaciones relacionales, tratamiento de valores nulos, funciones de agregación y el uso avanzado de subconsultas con tablas derivadas.

## Código SQL

```sql
SELECT 
    p.Nombre_1 + ' ' + ISNULL(p.Nombre_2 + ' ', '') + p.Apellido_1 AS Cliente,
    COUNT(DISTINCT v.Id_Venta) AS Cantidad_Compras,
    COUNT(pas.Id_Pasaje) AS Total_Pasajes,
    SUM(pas.Precio_Unitario) AS GastoTotalAcumulado
FROM Cliente_comprador c
INNER JOIN Persona p ON c.Id_Persona = p.Id_Persona
INNER JOIN Venta v ON c.Id_Persona = v.Id_Cliente
INNER JOIN Pasaje pas ON v.Id_Venta = pas.Id_Venta
GROUP BY 
    p.Nombre_1, p.Nombre_2, p.Apellido_1
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
```

## Justificación técnica
- **Vinculación relacional integral:** En la cláusula `FROM`, se encadenan mediante `INNER JOIN` las tablas `Cliente_comprador`, `Persona`, `Venta` y `Pasaje` para garantizar que únicamente se consideren aquellos comprobantes emitidos formalmente a nombre del cliente.
- **Tratamiento de nulos:** Se aplica la función `ISNULL(p.Nombre_2 + ' ', '')` junto con la concatenación para asegurar que, si un pasajero no posee segundo nombre, el valor NULL no propague un resultado nulo a toda la cadena.
- **Métricas de consumo:** Mediante `COUNT(DISTINCT v.Id_Venta)` se contabiliza la cantidad neta de compras evitando duplicar comprobantes, mientras que `COUNT(pas.Id_Pasaje)` expone el total de pasajes físicos y `SUM(pas.Precio_Unitario)` consolida el gasto.
- **Filtrado avanzado con HAVING y subconsulta:** Se anida una consulta en el `FROM` interno que totaliza cada venta, y la subconsulta externa aplica `AVG()` para obtener el promedio global. El sistema filtra únicamente a los clientes cuyo gasto total supera la media transaccional de la empresa, sin requerir un valor fijo.