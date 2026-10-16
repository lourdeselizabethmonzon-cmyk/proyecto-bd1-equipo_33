## 1. CASO DE USO 1: FACTURA / COMPROBANTE DE VENTA CON TOTAL ACUMULADO

### 1.1. Propósito y Necesidad de Negocio
En el esquema operativo de la empresa Corrientes Porá Bus, reemplazar la carga manual y descentralizada de pasajes exige un procedimiento transaccional automatizado[cite: 8]. Este caso de uso resuelve la emisión y consulta formal del comprobante de venta (factura/boleto), consolidando en una única vista los datos de la cabecera transaccional (número de venta, fecha y comprador) con el detalle específico de cada butaca (trayecto, terminales de origen y destino, hora de salida y tarifa individual)[cite: 8]. La automatización de este reporte elimina los errores de cálculo aritmético manual, previene discrepancias de caja y garantiza la trazabilidad e inmutabilidad del comprobante emitido[cite: 8].

### 1.2. Desarrollo y Justificación Técnica (T-SQL)
* **Vinculación Relacional Múltiple (`INNER JOIN`):** En la cláusula `FROM`, se encadenan las tablas `Venta`, `Cliente_comprador`, `Persona`, `Pasaje`, `Viaje`, `Ruta` y `Terminal` utilizando sus claves primarias y foráneas[cite: 8]. Esta técnica garantiza recuperar únicamente la información del comprobante consultado sin incurrir en productos cartesianos[cite: 8].
* **Filtrado Restringido (`WHERE`):** La condición `WHERE v.Id_Venta = 1` delimita la búsqueda a una transacción específica para la composición de su comprobante[cite: 8].
* **Limpieza y Formateo de Datos:** Se emplea la concatenación de cadenas (`+`) para unificar la identidad del cliente y la función escalar `CAST(vi.Hora_Salida AS TIME(0))` para eliminar la precisión excesiva de microsegundos en la representación horaria[cite: 8].
* **Función de Ventana Analítica (`SUM OVER`):** Se aplica la función de ventana `SUM(pas.Precio_Unitario) OVER(PARTITION BY v.Id_Venta)` para calcular el total acumulado de la venta sobre cada renglón del detalle[cite: 8]. Al utilizar `PARTITION BY`, se logra proyectar la suma acumulada junto a cada ítem individual sin requerir el colapso de filas provocado por un `GROUP BY`[cite: 8].

### 1.3. Código SQL Ejecutable
```sql
-- ============================================================================
-- CONSULTA 1: FACTURA / COMPROBANTE DE VENTA
-- Encabezado y detalle de una venta, calculando subtotales y total acumulado.
-- ============================================================================
SELECT
    v.Id_Venta AS NroComprobante,
    v.Fecha AS FechaVenta,
    p_cli.Nombre_1 + ' ' + p_cli.Apellido_1 AS ClienteComprador,
    pas.Id_Pasaje AS NroPasaje,
    t_orig.Nombre AS TerminalOrigen,
    t_dest.Nombre AS TerminalDestino,
    CAST(vi.Hora_Salida AS TIME(0)) AS Hora_Salida,
    pas.Precio_Unitario AS PrecioPasaje,
    -- Función de ventana para el total acumulado del comprobante
    SUM(pas.Precio_Unitario) OVER(PARTITION BY v.Id_Venta) AS TotalAcumuladoComprobante
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
    v.Id_Venta = 1;

    ## 2. CASO DE USO 2: REPORTE AGREGADO DE RECAUDACIÓN POR VENDEDOR

### 2.1. Propósito y Necesidad de Negocio
La ausencia de auditorías automatizadas al finalizar los turnos comerciales generaba incerteza sobre el dinero recaudado y el rendimiento del personal en las boleterías[cite: 8]. Este caso de uso proporciona un reporte agrupado para el área de control financiero de la empresa, consolidando la cantidad de operaciones concretadas, la totalidad de pasajes comercializados y la recaudación económica generada por cada empleado en un período dado[cite: 8]. La consulta automatiza el proceso de arqueo de caja y ofrece indicadores clave de rendimiento (KPIs) para evaluar la productividad comercial[cite: 8].

### 2.2. Desarrollo y Justificación Técnica (T-SQL)
* **Vinculación Relacional Integrada:** Se conectan las entidades `Venta`, `Empleado`, `Persona` y `Pasaje` para asociar inequívocamente cada comprobante emitido con el legajo del agente de ventas responsable[cite: 8].
* **Filtrado Temporal (`WHERE BETWEEN`):** La cláusula `WHERE v.Fecha BETWEEN '2026-09-01' AND '2026-10-31'` restringe la evaluación al intervalo de tiempo objeto de auditoría[cite: 8].
* **Agregación Métrica Diferenciada:** Se aplica `COUNT(DISTINCT v.Id_Venta)` para contabilizar las transacciones o ventas únicas atendidas (evitando duplicaciones al incluir ventas de múltiples pasajes), `COUNT(pas.Id_Pasaje)` para determinar la cantidad de boletos físicos vendidos y `SUM(pas.Precio_Unitario)` para totalizar el monto recaudado[cite: 8].
* **Agrupamiento y Clasificación (`GROUP BY` / `ORDER BY`):** La cláusula `GROUP BY e.Legajo, p_emp.Nombre_1, p_emp.Apellido_1` colapsa los datos a nivel de empleado, mientras que `ORDER BY RecaudacionTotal DESC` prioriza en los primeros lugares a los vendedores de mayor desempeño económico[cite: 8].

### 2.3. Código SQL Ejecutable
```sql
USE CorrientesPoraBus;
GO

-- ============================================================================
-- CONSULTA 2: REPORTE AGREGADO (Por Vendedor)
-- Total de ventas realizadas por cada vendedor en un rango de fechas.
-- ============================================================================
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

## 3. CASO DE USO 3: CONSULTA DE NEGOCIO AVANZADA (CLIENTES VIP / CONSUMO SUPERIOR AL PROMEDIO)

### 3.1. Propósito y Necesidad de Negocio
El área de Marketing y Fidelización de Corrientes Porá Bus requiere categorizar a sus clientes de alto valor (Clientes VIP) para la asignación de beneficios corporativos y promociones[cite: 8]. Este caso de uso analiza el consumo histórico acumulado de cada usuario y lo contrasta automáticamente contra el promedio global de ventas de la compañía[cite: 8]. De esta forma, el sistema identifica de manera dinámica a los pasajeros cuyo nivel de compra supera la media de la empresa, sin recurrir a parámetros o umbrales estáticos prefijados[cite: 8].

### 3.2. Desarrollo y Justificación Técnica (T-SQL)
* **Unión de Entidades y Tratamiento de Nulos:** En la cláusula `FROM`, se enlazan mediante `INNER JOIN` las tablas `Cliente_comprador`, `Persona`, `Venta` y `Pasaje`[cite: 8]. En la proyección `SELECT`, la función `ISNULL(p.Nombre_2 + ' ', '')` previene la propagación de valores nulos al concatenar los nombres de los usuarios[cite: 8].
* **Subconsulta en Cláusula `FROM` (Tabla Derivada):** Para calcular el umbral de corte sin prefijar valores en el código, se anida la subconsulta `TablaDerivadaPromedio` que agrupa y suma los pasajes por venta (`GROUP BY v2.Id_Venta`)[cite: 8]. La subconsulta exterior calcula el promedio global mediante la función de agregación `AVG()`[cite: 8].
* **Filtrado sobre Agregados (`HAVING`):** Debido a las reglas del estándar SQL que impiden evaluar funciones agregadas dentro de la cláusula `WHERE`, la condición de filtrado se define en `HAVING SUM(pas.Precio_Unitario) > (subconsulta)`[cite: 8]. Esto filtra a los grupos (clientes) cuyo gasto total acumulado sea superior al promedio determinado por la tabla derivada[cite: 8].
* **Ordenamiento de Impacto Comercial:** La instrucción `ORDER BY GastoTotalAcumulado DESC` presenta los resultados ordenados en forma decreciente según el volumen económico gastado por el cliente[cite: 8].

### 3.3. Código SQL Ejecutable
```sql
USE CorrientesPoraBus;
GO

-- ============================================================================
-- CONSULTA 3: CONSULTA DE NEGOCIO AVANZADA (Clientes que superan el promedio)
-- Combina tablas mediante JOIN y aplica filtros con subconsultas y HAVING.
-- ============================================================================
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