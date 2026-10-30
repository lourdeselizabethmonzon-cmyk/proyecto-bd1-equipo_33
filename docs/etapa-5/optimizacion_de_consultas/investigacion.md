# Tema 5: Optimización de consultas a través de índices

## 1. Definición y Objetivo

### Definición

Los **índices** son estructuras que **SQL Server** utiliza para **localizar información de forma más eficiente**. Su funcionamiento es análogo al índice de un libro: en lugar de recorrer todas las páginas para encontrar un tema determinado, permiten **acceder directamente a la información buscada**. En tablas con gran cantidad de registros, la ausencia de índices obliga al motor a realizar un escaneo completo de la tabla (**`Table Scan`**), lo que genera tiempos de respuesta elevados.

### Objetivo

El objetivo principal de la optimización mediante índices es **reducir significativamente el volumen de datos analizados y la cantidad de lecturas lógicas** que realiza el motor de la base de datos durante la ejecución de una consulta. Esto permite transformar operaciones de escaneo masivo en búsquedas puntuales y directas (**`Index Seek`**).

## 2. Ventajas y Aplicaciones

### Ventajas

- **Mejora del rendimiento:** Incrementan sustancialmente la velocidad de las consultas de búsqueda.
- **Reducción de tiempos de respuesta:** Disminuyen el tiempo de ejecución en tablas con grandes volúmenes de datos.
- **Menor consumo de E/S (Lecturas Lógicas):** Disminuyen drásticamente la cantidad de páginas de datos que el motor debe leer en memoria/disco.
- **Escalabilidad del sistema:** Permiten que la base de datos mantenga un rendimiento óptimo a medida que la información crece.
- **Consideración de diseño:** Consumen espacio adicional en disco y pueden afectar levemente el rendimiento de las operaciones **`INSERT`**, **`UPDATE`** y **`DELETE`**, debido a que los índices deben mantenerse actualizados con cada modificación.

### Aplicaciones

- **Optimización de filtros frecuentes:** Se aplican sobre columnas habitualmente utilizadas en cláusulas **`WHERE`** (fechas, códigos, clientes, productos, etc.).
- **Consultas sobre tablas de alto volumen:** Optimización de búsquedas en tablas históricas o transaccionales con cientos de miles o millones de registros (por ejemplo, consultas de ventas por rangos de fechas).
- **Uso de Índices Agrupados (`Clustered Index`):** Para reordenar físicamente los datos según la clave de búsqueda principal o rangos.
- **Uso de Índices de Cobertura (`Nonclustered Index` con `INCLUDE`):** Para resolver una consulta **accediendo únicamente al índice**, evitando acceder a la tabla base.

## 3. Implementación en SQL Server Express

La implementación en **SQL Server Express** abarca la creación de diferentes tipos de índices, su eliminación y el uso de herramientas de medición de rendimiento.

### a) Sintaxis de Creación de Índices

#### 1. Índice Agrupado (`Clustered Index`)

Aplica un orden físico sobre la columna especificada (generalmente usada para filtros de rango o clave primaria).

```sql
CREATE CLUSTERED INDEX IX_VentaHistorica_Fecha
ON VentaHistorica(fecha_venta);
GO
```

#### 2. Índice No Agrupado de Cobertura (`Nonclustered Index` con `INCLUDE`)

Incluye columnas adicionales en el nivel de hoja del índice para que la consulta sea resuelta al 100% por el índice sin acceder a la tabla base.

```sql
CREATE NONCLUSTERED INDEX IX_VentaHistorica_Fecha_Cobertura
ON VentaHistorica(fecha_venta)
INCLUDE (importe);
GO
```

#### 3. Eliminación de un Índice

```sql
DROP INDEX IX_VentaHistorica_Fecha
ON VentaHistorica;
GO
```

### b) Herramientas de Análisis y Medición de Rendimiento

Para evaluar y verificar la efectividad de la implementación en **SQL Server Express**, se utilizan los siguientes comandos y métricas.

#### Activación de estadísticas de tiempo y lecturas de E/S

```sql
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO
```

#### Verificación del Plan de Ejecución

Permite observar el cambio del comportamiento del motor desde un **`Table Scan`** o **`Clustered Index Scan`** (escaneo de tabla completa) hacia un **`Index Seek`** o **`Clustered Index Seek`** (búsqueda orientada directa).

#### Registro de métricas comparativas

Se documentan valores como:

- **Tiempo de CPU (ms).**
- **Tiempo total transcurrido (ms).**
- **Lecturas lógicas.**
- **Operación principal realizada.**
