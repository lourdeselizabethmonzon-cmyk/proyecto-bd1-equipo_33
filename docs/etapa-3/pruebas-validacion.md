USE CorrientesPoraBus;
GO

PRINT '=============================================================================';
PRINT 'INICIANDO PRUEBAS DE VALIDACIÓN DE RESTRICCIONES (CONSTRAINTS)';
PRINT '=============================================================================';
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 1: Validar CHK_Ruta_Distancia (La distancia debe ser mayor a 0)
-- RESULTADO ESPERADO: Debe fallar por el CHECK de distancia negativa o cero.
-- -----------------------------------------------------------------------------
PRINT '--- Prueba 1: Insertar Ruta con Distancia Inválida (<= 0) ---';
BEGIN TRY
    INSERT INTO Ruta (Distancia, Tiempo_Estimado, Id_Terminal_Origen, Id_Terminal_Destino) 
    VALUES (-50.00, '01:00:00', 1, 2);
END TRY
BEGIN CATCH
    PRINT '¡ÉXITO EN LA VALIDACIÓN! SQL rechazó la distancia inválida.';
    PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
END CATCH
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 2: Validar CHK_TerminalesDiferentes (Origen y destino no pueden ser iguales)
-- RESULTADO ESPERADO: Debe fallar porque la terminal de origen y destino son la misma.
-- -----------------------------------------------------------------------------
PRINT '--- Prueba 2: Insertar Ruta con Origen y Destino Iguales ---';
BEGIN TRY
    INSERT INTO Ruta (Distancia, Tiempo_Estimado, Id_Terminal_Origen, Id_Terminal_Destino) 
    VALUES (100.00, '02:00:00', 1, 1);
END TRY
BEGIN CATCH
    PRINT '¡ÉXITO EN LA VALIDACIÓN! SQL rechazó la ruta con misma terminal.';
    PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
END CATCH
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 3: Validar CHK_Colectivo_Anio (El año debe ser >= 2000)
-- RESULTADO ESPERADO: Debe fallar por intentar meter un colectivo del año 1995.
-- -----------------------------------------------------------------------------
PRINT '--- Prueba 3: Insertar Colectivo con Año Anterior al 2000 ---';
BEGIN TRY
    INSERT INTO Colectivo (Patente, Marca, Modelo, Anio) 
    VALUES ('ZZ999ZZ', 'Fiat', 'Corcel', 1995);
END TRY
BEGIN CATCH
    PRINT '¡ÉXITO EN LA VALIDACIÓN! SQL rechazó el colectivo viejo.';
    PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
END CATCH
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 4: Validar CHK_Butaca_Ubicacion (Solo 'Pasillo' o 'Ventanilla')
-- RESULTADO ESPERADO: Debe fallar por poner una ubicación no permitida ('Medio').
-- -----------------------------------------------------------------------------
PRINT '--- Prueba 4: Insertar Butaca con Ubicación Inválida ---';
BEGIN TRY
    INSERT INTO Butacas (Nro_Butaca, Patente, Ubicacion, Tipo_Servicio) 
    VALUES (50, 'AA123BB', 'Medio', 'Semicama');
END TRY
BEGIN CATCH
    PRINT '¡ÉXITO EN LA VALIDACIÓN! SQL rechazó la ubicación de butaca inválida.';
    PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
END CATCH
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 5: Validar UQ_Pasaje_Viaje_Butaca (Una butaca no se puede vender dos veces)
-- RESULTADO ESPERADO: Debe fallar por clave duplicada en la venta del pasaje.
-- -----------------------------------------------------------------------------
PRINT '--- Prueba 5: Vender la misma butaca dos veces para el mismo viaje ---';
BEGIN TRY
    -- Intentamos insertar un pasaje usando el Viaje 1 y Butaca 1 (que ya se insertaron en el DML)
    INSERT INTO Pasaje (Precio_Unitario, Id_Venta, Id_Viaje, Id_Butaca, Id_Pasajero) 
    VALUES (1500.00, 1, 1, 1, 7);
END TRY
BEGIN CATCH
    PRINT '¡ÉXITO EN LA VALIDACIÓN! SQL rechazó la butaca repetida en el mismo viaje.';
    PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
END CATCH
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 6: Validar CHK_Persona_TipoDoc (Solo 'DNI', 'CUIT', 'Pasaporte')
-- RESULTADO ESPERADO: Debe fallar por poner un tipo de documento inventado.
-- -----------------------------------------------------------------------------
PRINT '--- Prueba 6: Insertar Persona con Tipo de Documento Inválido ---';
BEGIN TRY
    INSERT INTO Persona (Nombre_1, Apellido_1, Tipo_Documento, Nro_Documento, Fecha_Nacimiento, e_mail) 
    VALUES ('Test', 'Test', 'LIBRETA', '12345678', '2000-01-01', 'test@test.com');
END TRY
BEGIN CATCH
    PRINT '¡ÉXITO EN LA VALIDACIÓN! SQL rechazó el tipo de documento inválido.';
    PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
END CATCH
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 7: Validar CHK_Empleado_Turno (Solo 'Mañana', 'Tarde', 'Noche')
-- RESULTADO ESPERADO: Debe fallar por asignar un turno inexistente.
-- -----------------------------------------------------------------------------
PRINT '--- Prueba 7: Insertar Empleado con Turno Inválido ---';
BEGIN TRY
    INSERT INTO Empleado (Id_Persona, Legajo, Turno_Laboral) 
    VALUES (1, 'LEG-ERROR', 'Madrugada');
END TRY
BEGIN CATCH
    PRINT '¡ÉXITO EN LA VALIDACIÓN! SQL rechazó el turno laboral inválido.';
    PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
END CATCH
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 8: Validar CHK_Pago_Monto (Monto > 0)
-- RESULTADO ESPERADO: Debe fallar al intentar registrar un pago negativo.
-- -----------------------------------------------------------------------------
PRINT '--- Prueba 8: Insertar Pago con Monto Negativo ---';
BEGIN TRY
    INSERT INTO Pago (Metodo_Pago, Monto_a_Pagar, Id_Venta) 
    VALUES ('Efectivo', -1500.00, 1);
END TRY
BEGIN CATCH
    PRINT '¡ÉXITO EN LA VALIDACIÓN! SQL rechazó el monto de pago negativo.';
    PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
END CATCH
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 9: Validar CHK_Venta_Estado (Solo 'Confirmada', 'Pendiente', 'Cancelada')
-- RESULTADO ESPERADO: Debe fallar al inventar un estado como 'Fiado'.
-- -----------------------------------------------------------------------------
PRINT '--- Prueba 9: Insertar Venta con Estado Inválido ---';
BEGIN TRY
    INSERT INTO Venta (Fecha, Estado, Id_Empleado, Id_Cliente) 
    VALUES (GETDATE(), 'Fiado', 1, 1);
END TRY
BEGIN CATCH
    PRINT '¡ÉXITO EN LA VALIDACIÓN! SQL rechazó el estado de venta no permitido.';
    PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
END CATCH
GO

-- -----------------------------------------------------------------------------
-- PRUEBA 10: Validar Integridad Referencial (Foreign Key)
-- RESULTADO ESPERADO: Debe fallar al crear localidad en provincia que no existe.
-- -----------------------------------------------------------------------------
PRINT '--- Prueba 10: Violar la Clave Foránea (Provincia Inexistente) ---';
BEGIN TRY
    INSERT INTO Localidad (Nombre, Id_Provincia) 
    VALUES ('Ciudad Fantasma', 9999);
END TRY
BEGIN CATCH
    PRINT '¡ÉXITO EN LA VALIDACIÓN! SQL impidió el registro huérfano (FK).';
    PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
END CATCH
GO

PRINT '=============================================================================';
PRINT 'PRUEBAS DE VALIDACIÓN FINALIZADAS CON ÉXITO';
PRINT '=============================================================================';
GO