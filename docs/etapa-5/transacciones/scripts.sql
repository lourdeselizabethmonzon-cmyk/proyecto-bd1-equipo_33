USE CorrientesPoraBus;
GO

PRINT '=============================================================================';
PRINT 'DEMOSTRACIÓN PRÁCTICA: MANEJO DE TRANSACCIONES (ETAPA V)';
PRINT '=============================================================================';
GO

-- =============================================================================
-- PRUEBA 1: ESCENARIO CORRECTO (Cupo suficiente -> COMMIT)
-- =============================================================================
DECLARE @IdViaje1 INT = 1;
DECLARE @CantidadSolicitada1 INT = 1;
DECLARE @AsientosDisponibles1 INT;
DECLARE @CupoMaximoColectivo1 INT = 10; -- Cupo holgado para asegurar éxito

-- 1. Consultamos el estado actual de ocupación
SELECT @AsientosDisponibles1 = COUNT(*) FROM Pasaje WHERE Id_Viaje = @IdViaje1;

PRINT '------------------------------------------------';
PRINT 'PRUEBA 1 (CORRECTA) -> Asientos ocupados: ' + CAST(@AsientosDisponibles1 AS VARCHAR);
PRINT '------------------------------------------------';

BEGIN TRANSACTION;

    BEGIN TRY
        -- Paso A: Registrar cabecera de la venta
        INSERT INTO Venta (Estado, Id_Empleado, Id_Cliente)
        VALUES ('Confirmada', 1, 4);

        DECLARE @IdVentaNueva INT = SCOPE_IDENTITY();

        -- Obtener cualquier butaca válida de la base de datos que no genere conflicto en este instante
        DECLARE @ButacaLibre INT;
        SELECT TOP 1 @ButacaLibre = Id_Butaca 
        FROM Butacas 
        WHERE Id_Butaca NOT IN (SELECT Id_Butaca FROM Pasaje WHERE Id_Viaje = @IdViaje1);

        -- Paso B: Registrar pasaje
        INSERT INTO Pasaje (Precio_Unitario, Id_Venta, Id_Viaje, Id_Butaca, Id_Pasajero)
        VALUES (1500.00, @IdVentaNueva, @IdViaje1, @ButacaLibre, 7);

        -- Paso C: Validar regla de negocio (Capacidad/Cupo)
        IF (@AsientosDisponibles1 + @CantidadSolicitada1) > @CupoMaximoColectivo1
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'RESULTADO: ¡Se ejecutó ROLLBACK por falta de cupo!';
        END
        ELSE
        BEGIN
            COMMIT TRANSACTION;
            PRINT 'RESULTADO: ¡Transacción exitosa (COMMIT)! Venta y pasaje registrados correctamente.';
        END;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT 'RESULTADO: Se produjo una excepción. Se aplicó ROLLBACK.';
        PRINT 'Mensaje: ' + ERROR_MESSAGE();
    END CATCH;
GO


-- =============================================================================
-- PRUEBA 2: ESCENARIO INCORRECTO (Cupo insuficiente -> ROLLBACK / Atomicidad)
-- =============================================================================
DECLARE @IdViaje2 INT = 1;
DECLARE @CantidadSolicitada2 INT = 10; -- Solicitud alta que supera la capacidad
DECLARE @CapacidadTotal2 INT = 2;      -- Límite bajo ajustado para forzar la regla
DECLARE @AsientosOcupados2 INT;

SELECT @AsientosOcupados2 = COUNT(*) FROM Pasaje WHERE Id_Viaje = @IdViaje2;

PRINT '';
PRINT '------------------------------------------------';
PRINT 'PRUEBA 2 (INCORRECTA) -> Asientos ocupados: ' + CAST(@AsientosOcupados2 AS VARCHAR);
PRINT 'Solicitud de pasajes: ' + CAST(@CantidadSolicitada2 AS VARCHAR) + ' (Excede el límite de ' + CAST(@CapacidadTotal2 AS VARCHAR) + ')';
PRINT '------------------------------------------------';

BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. Intentamos registrar la venta (cambio parcial previo a la validación)
        INSERT INTO Venta (Estado, Id_Empleado, Id_Cliente)
        VALUES ('Pendiente', 2, 5);

        -- 2. Evaluación de la Regla de Negocio
        IF (@AsientosOcupados2 + @CantidadSolicitada2) > @CapacidadTotal2
        BEGIN
            -- Se ejecuta ROLLBACK explícito: Cancela la Venta insertada arriba y no guarda nada
            ROLLBACK TRANSACTION;
            PRINT 'RESULTADO: ¡Se ejecutó ROLLBACK TRANSACTION! No hay cupo suficiente. No queda ningún registro parcial en la base de datos.';
        END
        ELSE
        BEGIN   
            COMMIT TRANSACTION;
            PRINT 'RESULTADO: Se ejecutó COMMIT TRANSACTION.';
        END;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT 'RESULTADO: Excepción capturada. Se ejecutó ROLLBACK.';
    END CATCH;
GO
