/* ============================================================
   PROYECTO: CORRIENTES PORÁ BUS
   ETAPA 5: PROCEDIMIENTOS Y FUNCIONES

   ARCHIVO: scripts.sql

   DESCRIPCIÓN GENERAL:
   Este archivo contiene la implementación de un procedimiento
   almacenado, una función y un script de prueba.

   OBJETIVO:
   Automatizar la emisión de pasajes, calcular descuentos
   según el historial de compras de los clientes y comprobar
   el correcto funcionamiento de ambas implementaciones.
   ============================================================ */


/* ============================================================
   CÓDIGO 1: PROCEDIMIENTO ALMACENADO
   NOMBRE: sp_EmitirPasaje

   OBJETIVO:
   Automatizar el proceso de emisión de un pasaje mediante
   el registro de una venta, su correspondiente pago y el
   detalle del pasaje emitido.

   FUNCIONAMIENTO:
   1. Recibe los datos del empleado, cliente, pago, viaje,
      butaca y pasajero.
   2. Registra la cabecera de la venta con estado Confirmada.
   3. Recupera el identificador generado automáticamente
      para la nueva venta mediante SCOPE_IDENTITY().
   4. Registra el pago asociado a dicha venta.
   5. Registra el pasaje vinculándolo con la venta, el viaje,
      la butaca y el pasajero.

   IMPORTANCIA:
   Permite centralizar las operaciones necesarias para emitir
   un pasaje, evitando realizar manualmente cada inserción.
   ============================================================ */

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

    -- 1. Insertamos la cabecera de la Venta
    INSERT INTO Venta (Estado, Id_Empleado, Id_Cliente)
    VALUES ('Confirmada', @Id_Empleado, @Id_Cliente);

    -- 2. Atrapamos el ID generado por el IDENTITY
    SET @NuevaVentaId = SCOPE_IDENTITY();

    -- 3. Insertamos el Pago usando el ID atrapado
    INSERT INTO Pago (Metodo_Pago, Monto_a_Pagar, Id_Venta)
    VALUES (@Metodo_Pago, @Monto_a_Pagar, @NuevaVentaId);

    -- 4. Insertamos el detalle del Pasaje
    INSERT INTO Pasaje (Precio_Unitario, Id_Venta, Id_Viaje, Id_Butaca, Id_Pasajero)
    VALUES (@Precio_Unitario, @NuevaVentaId, @Id_Viaje, @Id_Butaca, @Id_Pasajero);
END;
GO


/* ============================================================
   CÓDIGO 2: FUNCIÓN ESCALAR
   NOMBRE: fn_CalcularDescuentoCliente

   OBJETIVO:
   Determinar el porcentaje de descuento correspondiente
   a un cliente en función del total acumulado de sus compras
   confirmadas.

   FUNCIONAMIENTO:
   1. Recibe el identificador del cliente.
   2. Consulta las ventas confirmadas y suma los precios
      unitarios de los pasajes adquiridos.
   3. Si el cliente no registra compras, establece el
      acumulado en cero.
   4. Evalúa el importe acumulado y determina el descuento:
         - Más de $1.000.000: 15%.
         - Más de $500.000: 10%.
         - En los demás casos: 0%.
   5. Devuelve el porcentaje de descuento obtenido.

   IMPORTANCIA:
   Permite calcular automáticamente los beneficios
   comerciales de los clientes según su historial de compras.

   TIPO:
   Función escalar que devuelve un valor de tipo INT.
   ============================================================ */

USE CorrientesPoraBus;
GO

CREATE FUNCTION fn_CalcularDescuentoCliente (
    @Id_Cliente INT
)
RETURNS INT
AS
BEGIN
    DECLARE @TotalGastado DECIMAL(10,2);
    DECLARE @PorcentajeDescuento INT;

    -- 1. Sumamos el historial de compras del cliente
    SELECT @TotalGastado = SUM(p.Precio_Unitario)
    FROM Venta v
    JOIN Pasaje p ON v.Id_Venta = p.Id_Venta
    WHERE v.Id_Cliente = @Id_Cliente AND v.Estado = 'Confirmada';

    -- Prevención: Si es cliente nuevo y no gastó nada, arranca en 0
    IF @TotalGastado IS NULL 
        SET @TotalGastado = 0;

    -- 2. Lógica de escalones de descuento
    IF @TotalGastado > 1000000
        SET @PorcentajeDescuento = 15;
    ELSE IF @TotalGastado > 500000
        SET @PorcentajeDescuento = 10;
    ELSE
        SET @PorcentajeDescuento = 0;

    RETURN @PorcentajeDescuento;
END;
GO


/* ============================================================
   CÓDIGO 3: SCRIPT DE PRUEBA Y VALIDACIÓN
   OBJETIVO:
   Comprobar el funcionamiento de la función
   fn_CalcularDescuentoCliente y del procedimiento almacenado
   sp_EmitirPasaje mediante un caso de prueba.

   ESCENARIO:
   Se utiliza como ejemplo al cliente con ID 4 (Ana).

   SECUENCIA DE EJECUCIÓN:
   1. Consulta el descuento actual del cliente antes de emitir
      un nuevo pasaje.
   2. Ejecuta el procedimiento sp_EmitirPasaje para registrar
      una nueva venta, el pago y el pasaje correspondiente.
   3. Consulta nuevamente el descuento del cliente para
      comprobar el resultado luego de la nueva compra.

   RESULTADO ESPERADO SEGÚN LOS DATOS DE PRUEBA:
   - Antes de la compra: descuento del 0%.
   - Se emite un pasaje por $500.000.
   - Después de la compra: descuento del 10%.

   IMPORTANCIA:
   Permite demostrar la interacción entre el procedimiento
   almacenado y la función, verificando el comportamiento
   esperado mediante datos de prueba.
   ============================================================ */

USE CorrientesPoraBus;
GO

PRINT '1. DESCUENTO ACTUAL';
-- Consultamos a Ana (ID 4) antes de la nueva compra. 
-- Como solo gastó $36.000 en los datos de prueba, la función retorna 0.
SELECT 
    c.Id_Persona AS Id_Cliente,
    p.Nombre_1 + ' ' + p.Apellido_1 AS Cliente,
    dbo.fn_CalcularDescuentoCliente(c.Id_Persona) AS Descuento_Actual
FROM Cliente_comprador c
JOIN Persona p ON c.Id_Persona = p.Id_Persona
WHERE c.Id_Persona = 4;
GO

PRINT '2. EMISIÓN DEL PASAJE (SP)';
-- Emitimos el boleto usando los IDs exactos del script de tus compañeros.
-- Usamos la Butaca 2 (libre) del Viaje 1, por un valor de $500.000.
EXEC sp_EmitirPasaje 
    @Id_Empleado = 1, 
    @Id_Cliente = 4, 
    @Metodo_Pago = 'Transferencia', 
    @Monto_a_Pagar = 500000.00, 
    @Id_Viaje = 1, 
    @Id_Butaca = 2, 
    @Id_Pasajero = 9, 
    @Precio_Unitario = 500000.00;
PRINT 'Pasaje emitido con éxito.';
GO

PRINT '3. NUEVO DESCUENTO ALCANZADO';
-- Volvemos a consultar a Ana. 
-- Ahora su historial superó el medio millón de pesos y la función saltará al 10%.
SELECT 
    c.Id_Persona AS Id_Cliente,
    p.Nombre_1 + ' ' + p.Apellido_1 AS Cliente,
    dbo.fn_CalcularDescuentoCliente(c.Id_Persona) AS Nuevo_Descuento
FROM Cliente_comprador c
JOIN Persona p ON c.Id_Persona = p.Id_Persona
WHERE c.Id_Persona = 4;
GO
