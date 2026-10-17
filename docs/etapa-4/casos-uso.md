# DOCUMENTO DE CASOS DE USO

- **Asignatura:** Bases de Datos I — Licenciatura en Sistemas de Información (FaCENA - UNNE)[cite: 11]
- **Proyecto:** Sistema de Gestión de Pasajes "Corrientes Porá Bus" — Equipo 33[cite: 11]
- **Motor DBMS:** Microsoft SQL Server (Transact-SQL)[cite: 11]

---

## 1. CASO DE USO 1: FACTURA / COMPROBANTE DE VENTA CON TOTAL ACUMULADO

### 1.1. Propósito y Necesidad de Negocio
En el esquema operativo de la empresa Corrientes Porá Bus, reemplazar la carga manual y descentralizada de pasajes exige un procedimiento transaccional automatizado[cite: 11]. Este caso de uso resuelve la emisión y consulta formal del comprobante de venta (factura/boleto), consolidando en una única vista los datos de la cabecera transaccional (número de venta, fecha y comprador) con el detalle específico de cada butaca (trayecto, terminales de origen y destino, hora de salida y tarifa individual)[cite: 11]. La automatización de este reporte elimina los errores de cálculo aritmético manual, previene discrepancias de caja y garantiza la trazabilidad e inmutabilidad del comprobante emitido[cite: 11].

### 1.2. Desarrollo y Justificación Técnica (T-SQL)
* **Vinculación Relacional Múltiple (`INNER JOIN`):** En la cláusula `FROM`, se encadenan las tablas `Venta`, `Cliente_comprador`, `Persona`, `Pasaje`, `Viaje`, `Ruta` y `Terminal` utilizando sus claves primarias y foráneas[cite: 11]. Esta técnica garantiza recuperar únicamente la información del comprobante consultado sin incurrir en productos cartesianos[cite: 11].
* **Filtrado Restringido (`WHERE`):** La condición `WHERE v.Id_Venta = 1` delimita la búsqueda a una transacción específica para la composición de su comprobante[cite: 11].
* **Limpieza y Formateo de Datos:** Se emplea la concatenación de cadenas (`+`) para unificar la identidad del cliente y la función escalar `CAST(vi.Hora_Salida AS TIME(0))` para eliminar la precisión excesiva de microsegundos en la representación horaria[cite: 11].
* **Función de Ventana Analítica (`SUM OVER`):** Se aplica la función de ventana `SUM(pas.Precio_Unitario) OVER(PARTITION BY v.Id_Venta)` para calcular el total acumulado de la venta sobre cada renglón del detalle[cite: 11]. Al utilizar `PARTITION BY`, se logra proyectar la suma acumulada junto a cada ítem individual sin requerir el colapso de filas provocado por un `GROUP BY`[cite: 11].

---

## 2. CASO DE USO 2: REPORTE AGREGADO DE RECAUDACIÓN POR VENDEDOR

### 2.1. Propósito y Necesidad de Negocio
La ausencia de auditorías automatizadas al finalizar los turnos comerciales generaba incerteza sobre el dinero recaudado y el rendimiento del personal en las boleterías[cite: 11]. Este caso de uso proporciona un reporte agrupado para el área de control financiero de la empresa, consolidando la cantidad de operaciones concretadas, la totalidad de pasajes comercializados y la recaudación económica generada por cada empleado en un período dado[cite: 11]. La consulta automatiza el proceso de arqueo de caja y ofrece indicadores clave de rendimiento (KPIs) para evaluar la productividad comercial[cite: 11].

### 2.2. Desarrollo y Justificación Técnica (T-SQL)
* **Vinculación Relacional Integrada:** Se conectan las entidades `Venta`, `Empleado`, `Persona` y `Pasaje` para asociar inequívocamente cada comprobante emitido con el legajo del agente de ventas responsable[cite: 11].
* **Filtrado Temporal (`WHERE BETWEEN`):** La cláusula `WHERE v.Fecha BETWEEN '2026-09-01' AND '2026-10-31'` restringe la evaluación al intervalo de tiempo objeto de auditoría[cite: 11].
* **Agregación Métrica Diferenciada:** Se aplica `COUNT(DISTINCT v.Id_Venta)` para contabilizar las transacciones o ventas únicas atendidas (evitando duplicaciones al incluir ventas de múltiples pasajes), `COUNT(pas.Id_Pasaje)` para determinar la cantidad de boletos físicos vendidos y `SUM(pas.Precio_Unitario)` para totalizar el monto recaudado[cite: 11].
* **Agrupamiento y Clasificación (`GROUP BY` / `ORDER BY`):** La cláusula `GROUP BY e.Legajo, p_emp.Nombre_1, p_emp.Apellido_1` colapsa los datos a nivel de empleado, mientras que `ORDER BY RecaudacionTotal DESC` prioriza en los primeros lugares a los vendedores de mayor desempeño económico[cite: 11].

---

## 3. CASO DE USO 3: CONSULTA DE NEGOCIO AVANZADA (CLIENTES VIP / CONSUMO SUPERIOR AL PROMEDIO)

### 3.1. Propósito y Necesidad de Negocio
El área de Marketing y Fidelización de Corrientes Porá Bus requiere categorizar a sus clientes de alto valor (Clientes VIP) para la asignación de beneficios corporativos y promociones[cite: 11]. Este caso de uso analiza el consumo histórico acumulado de cada usuario y lo contrasta automáticamente contra el promedio global de ventas de la compañía[cite: 11]. De esta forma, el sistema identifica de manera dinámica a los pasajeros cuyo nivel de compra supera la media de la empresa, sin recurrir a parámetros o umbrales estáticos prefijados[cite: 11].

### 3.2. Desarrollo y Justificación Técnica (T-SQL)
* **Unión de Entidades y Tratamiento de Nulos:** En la cláusula `FROM`, se enlazan mediante `INNER JOIN` las tablas `Cliente_comprador`, `Persona`, `Venta` y `Pasaje`[cite: 11]. En la proyección `SELECT`, la función `ISNULL(p.Nombre_2 + ' ', '')` previene la propagación de valores nulos al concatenar los nombres de los usuarios[cite: 11].
* **Subconsulta en Cláusula `FROM` (Tabla Derivada):** Para calcular el umbral de corte sin prefijar valores en el código, se anida la subconsulta `TablaDerivadaPromedio` que agrupa y suma los pasajes por venta (`GROUP BY v2.Id_Venta`)[cite: 11]. La subconsulta exterior calcula el promedio global mediante la función de agregación `AVG()`[cite: 11].
* **Filtrado sobre Agregados (`HAVING`):** Debido a las reglas del estándar SQL que impiden evaluar funciones agregadas dentro de la cláusula `WHERE`, la condición de filtrado se define en `HAVING SUM(pas.Precio_Unitario) > (subconsulta)`[cite: 11]. Esto filtra a los grupos (clientes) cuyo gasto total acumulado sea superior al promedio determinado por la tabla derivada[cite: 11].
* **Ordenamiento de Impacto Comercial:** La instrucción `ORDER BY GastoTotalAcumulado DESC` presenta los resultados ordenados en forma decreciente según el volumen económico gastado por el cliente[cite: 11].++S