# Evidencias de Ejecución

### Caso 1: Consulta de Descuento Inicial (Función Escalar)

Supongamos que el área de ventas necesita verificar el nivel de beneficios de la clienta Ana López (ID 4) antes de realizar una nueva operación.

- **Objeto principal evaluado:** `fn_CalcularDescuentoCliente`
- **Tablas consultadas internamente:** `Venta`, `Pasaje`
- **Comportamiento esperado:** Al tener un historial de compras acumulado de $36.000 (por debajo del primer umbral comercial de $40.000), la función debe procesar el cálculo en tiempo real y retornar un porcentaje de descuento del **0%**.

#### Código de Demostración (Caso 1):

```sql
USE CorrientesPoraBus;
GO

PRINT '===============================================================';
PRINT '1. CONSULTA DE DESCUENTO INICIAL (Cliente Ana López)';
PRINT '===============================================================';

SELECT 
    c.Id_Persona AS Id_Cliente,
    p.Nombre_1 + ' ' + p.Apellido_1 AS Cliente_Frecuente,
    dbo.fn_CalcularDescuentoCliente(c.Id_Persona) AS Porcentaje_Descuento_Actual
FROM Cliente_comprador c
JOIN Persona p ON c.Id_Persona = p.Id_Persona
WHERE c.Id_Persona = 4;
GO
```

### Caso 2: Emisión Atómica de Pasaje VIP (Procedimiento Almacenado)

Supongamos que la misma clienta adquiere un pasaje de alto valor. El operador de ventanilla procesa la compra, lo que requiere registrar la cabecera de la venta, asentar el método de pago y emitir el boleto físico de manera simultánea.

- **Objeto principal evaluado:** `sp_EmitirPasaje`
- **Tablas afectadas:** `Venta` (INSERT), `Pago` (INSERT), `Pasaje` (INSERT)
- **Comportamiento esperado:** El procedimiento atrapa el ID autonumérico de la Venta mediante `SCOPE_IDENTITY()` y lo reutiliza para insertar el Pago y el Pasaje exitosamente en un solo paso, confirmando la operación sin dejar registros huérfanos.

#### Código de Demostración (Caso 2):

```sql
USE CorrientesPoraBus;
GO

PRINT '===============================================================';
PRINT '2. EMISIÓN DE PASAJES EN UN SOLO PASO (Procedimiento)';
PRINT '===============================================================';

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
        
    PRINT '¡ÉXITO! Operación de venta, pago y emisión procesada de forma atómica.';
END TRY
BEGIN CATCH
    PRINT 'ERROR en la ejecución transaccional: ' + ERROR_MESSAGE();
END CATCH
GO
```

### Caso 3: Actualización Dinámica del Beneficio (Función Post-Venta)

Supongamos que el sistema vuelve a evaluar automáticamente a la clienta Ana López inmediatamente después de haberse concretado la venta VIP anterior.

- **Objeto principal evaluado:** `fn_CalcularDescuentoCliente`
- **Tablas consultadas internamente:** `Venta`, `Pasaje`
- **Comportamiento esperado:** La función detecta el nuevo historial acumulado de la clienta (ahora de $336.000). Al superar ampliamente el umbral exigido por el negocio, el cálculo escalar se actualiza instantáneamente y retorna un nuevo nivel de beneficio del **10%**.

#### Código de Demostración (Caso 3):

```sql
USE CorrientesPoraBus;
GO

PRINT '===============================================================';
PRINT '3. EVALUACIÓN DE ACTUALIZACIÓN DINÁMICA (Función Post-Venta)';
PRINT '===============================================================';

SELECT 
    c.Id_Persona AS Id_Cliente,
    p.Nombre_1 + ' ' + p.Apellido_1 AS Cliente_Frecuente,
    dbo.fn_CalcularDescuentoCliente(c.Id_Persona) AS Porcentaje_Descuento_Actualizado
FROM Cliente_comprador c
JOIN Persona p ON c.Id_Persona = p.Id_Persona
WHERE c.Id_Persona = 4;
GO
```

### Caso 4: Prevención de Sobreventa (Fallo Controlado en SP)

Supongamos que, por un error de comunicación, otro operador intenta vender exactamente la misma butaca en el mismo viaje para otro pasajero.

- **Objeto principal evaluado:** `sp_EmitirPasaje` interceptado por restricción de integridad (`UQ_Pasaje_Viaje_Butaca`).
- **Comportamiento esperado:** El motor de la base de datos detecta la violación de unicidad lógica. El bloque `TRY...CATCH` del script atrapa el error, abortando la transacción por completo antes de que se genere un doble cobro o una venta inválida.

#### Código de Demostración (Caso 4):

```sql
USE CorrientesPoraBus;
GO

PRINT '===============================================================';
PRINT '4. INTENTO DE SOBREVENTA (Transacción Abortada)';
PRINT '===============================================================';

BEGIN TRY
    -- Intentamos emitir un pasaje para la MISMA butaca (2) del MISMO viaje (1)
    EXEC sp_EmitirPasaje 
        @Id_Empleado = 2, 
        @Id_Cliente = 5, 
        @Metodo_Pago = 'Efectivo', 
        @Monto_a_Pagar = 15000.00, 
        @Id_Viaje = 1, 
        @Id_Butaca = 2,  -- Butaca previamente vendida en el Caso 2
        @Id_Pasajero = 8, 
        @Precio_Unitario = 15000.00;
        
    PRINT 'FALLÓ LA PRUEBA: El sistema permitió la sobreventa.';
END TRY
BEGIN CATCH
    PRINT 'VALIDACIÓN EXITOSA: Operación bloqueada. Asiento ya ocupado.';
    PRINT 'Mensaje de SQL: ' + ERROR_MESSAGE();
END CATCH
GO
```
