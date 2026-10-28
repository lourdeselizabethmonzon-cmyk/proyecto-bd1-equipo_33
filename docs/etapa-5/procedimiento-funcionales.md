# ETAPA V: Implementación de Temas Técnicos Avanzados
## Tema 1: Procedimientos y Funciones Almacenadas

---

### 1. Definición y Objetivo

*   **Procedimiento Almacenado (`sp_EmitirPasaje`):** Es un subprograma precompilado almacenado directamente en el motor del Sistema de Gestión de Bases de Datos (SGBD). Su objetivo principal es encapsular y ejecutar un bloque de transacciones operativas complejas (como insertar simultáneamente la cabecera de una venta, registrar su método de pago y emitir el pasaje nominal correspondiente) en una sola unidad lógica de ejecución.
*   **Función Escalar (`fn_CalcularDescuentoCliente`):** Es una subrutina programada que acepta parámetros de entrada (en este caso, el identificador del cliente), procesa una consulta interna para evaluar su comportamiento histórico de compra y retorna un único valor escalar (el porcentaje de descuento aplicable) que puede integrarse directamente en cualquier consulta DQL (`SELECT`).

---

### 2. Ventajas y Aplicaciones en el Negocio

*   **Centralización de la Lógica Comercial:** Las reglas de negocio de la empresa ("Corrientes Porá Bus") residen de manera unificada en el servidor, evitando que distintas aplicaciones cliente deban replicar la lógica de cálculo o la secuencia de inserción de boletos.
*   **Optimización del Rendimiento y Tráfico de Red:** Al estar precompiladas en el motor, las consultas complejas y los múltiples comandos de escritura se ejecutan mediante una única llamada de red (`EXEC` o invocación en el `SELECT`), reduciendo drásticamente el intercambio de paquetes entre la boletería y el servidor central.
*   **Seguridad y Consistencia de Datos:** Permite otorgar permisos de ejecución sobre los procedimientos a los operadores de ventanilla sin necesidad de concederles privilegios de modificación directa (`INSERT` o `UPDATE`) sobre las tablas transaccionales críticas, garantizando la trazabilidad y previniendo la corrupción de registros.

---

### 3. Problema de Negocio Resuelto

Históricamente, la emisión de boletos requería que el operador ejecute de forma manual múltiples sentencias de inserción encadenadas (`INSERT` en `Venta`, `Pago` y `Pasaje`). Si se producía una interrupción en la red o un error tipográfico a mitad del proceso, la base de datos quedaba con registros huérfanos o inconsistentes (por ejemplo, pagos sin pasajes vinculados). 

Asimismo, el cálculo de beneficios por fidelidad requería arqueos manuales lentos. Mediante la implementación de **`sp_EmitirPasaje`**, el circuito comercial se unifica y blinda en un único paso, mientras que **`fn_CalcularDescuentoCliente`** automatiza en tiempo real el sistema de incentivos para pasajeros frecuentes.

---

### 4. Implementación en SQL Server (T-SQL)

A continuación se detallan los scripts de creación correspondientes a los objetos almacenados en la base de datos `CorrientesPoraBus`:

#### A. Creación del Procedimiento Almacenado
```sql
USE CorrientesPoraBus;
GO

CREATE PROCEDURE sp_EmitirPasaje
    @Id_Empleado INT,
    @Id_Cliente INT,
    @Metodo_Pago VARCHAR(30),
    @Monto_a_Pagar DECIMAL(10,2),
    @Id_Viaje INT,
    @Id_Butaca INT,
    @Id_Pasajero INT,
    @Precio_Unitario DECIMAL(10,2)
AS
BEGIN
    DECLARE @NuevaVentaId INT;

    -- 1. Insertamos la cabecera de la Venta (La fecha se registra automáticamente por defecto)
    INSERT INTO Venta (Estado, Id_Empleado, Id_Cliente)
    VALUES ('Confirmada', @Id_Empleado, @Id_Cliente);

    -- 2. Atrapamos el ID generado automáticamente por el IDENTITY de la tabla Venta
    SET @NuevaVentaId = SCOPE_IDENTITY();

    -- 3. Insertamos el registro de cobro asociado a la venta
    INSERT INTO Pago (Metodo_Pago, Monto_a_Pagar, Id_Venta)
    VALUES (@Metodo_Pago, @Monto_a_Pagar, @NuevaVentaId);

    -- 4. Insertamos el detalle del pasaje congelando el precio unitario histórico
    INSERT INTO Pasaje (Precio_Unitario, Id_Venta, Id_Viaje, Id_Butaca, Id_Pasajero)
    VALUES (@Precio_Unitario, @NuevaVentaId, @Id_Viaje, @Id_Butaca, @Id_Pasajero);
END;
GO
USE CorrientesPoraBus;
GO

#### B. Creación de la función escalar

CREATE FUNCTION fn_CalcularDescuentoCliente (
    @Id_Cliente INT
)
RETURNS INT
AS
BEGIN
    DECLARE @TotalGastado DECIMAL(10,2);
    DECLARE @PorcentajeDescuento INT;

    -- 1. Sumamos el historial total de compras confirmadas del cliente
    SELECT @TotalGastado = SUM(p.Precio_Unitario)
    FROM Venta v
    JOIN Pasaje p ON v.Id_Venta = p.Id_Venta
    WHERE v.Id_Cliente = @Id_Cliente
      AND v.Estado = 'Confirmada';

    -- Si el cliente no registra compras previas, inicializamos en cero
    IF @TotalGastado IS NULL
        SET @TotalGastado = 0;

    -- 2. Evaluación de escalones de negocio para la fidelización
    IF @TotalGastado > 1000000
        SET @PorcentajeDescuento = 15;
    ELSE IF @TotalGastado > 500000
        SET @PorcentajeDescuento = 10;
    ELSE
        SET @PorcentajeDescuento = 0;

    RETURN @PorcentajeDescuento;
END;
GO
### 5. Script de Demostración y Resultados Obtenidos

# Prueba de la función de descuento y emisión de pasajes

```sql
USE CorrientesPoraBus;
GO

PRINT '===============================================================';
PRINT '1. CONSULTA DE DESCUENTO INICIAL (Función)';
PRINT '===============================================================';

-- Consultamos el porcentaje de descuento del Cliente ID 4 antes de nuevas operaciones
SELECT 
    c.Id_Persona AS Id_Cliente,
    p.Nombre_1 + ' ' + p.Apellido_1 AS Cliente_Frecuente,
    dbo.fn_CalcularDescuentoCliente(c.Id_Persona) AS Porcentaje_Descuento_Actual
FROM Cliente_comprador c
JOIN Persona p ON c.Id_Persona = p.Id_Persona
WHERE c.Id_Persona = 4;
GO

PRINT '===============================================================';
PRINT '2. EMISIÓN DE PASAJES EN UN SOLO PASO (Procedimiento)';
PRINT '===============================================================';

-- Simulamos la emisión de boletos de alto valor para forzar el cambio de escalón
BEGIN TRY
    EXEC sp_EmitirPasaje 
        @Id_Empleado = 1, 
        @Id_Cliente = 4, 
        @Metodo_Pago = 'Transferencia', 
        @Monto_a_Pagar = 300000.00, 
        @Id_Viaje = 1, 
        @Id_Butaca = 2, 
        @Id_Pasajero = 7, 
        @Precio_Unitario = 300000.00;
        
    PRINT '¡ÉXITO! Operación de venta procesada de forma atómica.';
END TRY
BEGIN CATCH
    PRINT 'ERROR en la ejecución: ' + ERROR_MESSAGE();
END CATCH
GO

PRINT '===============================================================';
PRINT '3. EVALUACIÓN DE ACTUALIZACIÓN DINÁMICA (Función Post-Venta)';
PRINT '===============================================================';

-- Re-evaluamos el descuento del Cliente ID 4 tras superar el umbral comercial
SELECT 
    c.Id_Persona AS Id_Cliente,
    p.Nombre_1 + ' ' + p.Apellido_1 AS Cliente_Frecuente,
    dbo.fn_CalcularDescuentoCliente(c.Id_Persona) AS Porcentaje_Descuento_Actualizado
FROM Cliente_comprador c
JOIN Persona p ON c.Id_Persona = p.Id_Persona
WHERE c.Id_Persona = 4;
GO
```
