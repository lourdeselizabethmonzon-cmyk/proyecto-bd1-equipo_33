# EVIDENCIAS DE EJECUCIÓN

---

### Caso 1: Auditoría de Viajes
Supongamos que un usuario o administrador modifica el precio base de un viaje programado.
* **Tabla principal:** `Viaje`
* **Tabla de auditoría:** `Auditoria_Viaje`
* **Información a registrar:**
  * **Viaje modificado:** Identificador del viaje afectado (`Id_Viaje`).
  * **Precio anterior:** Tarifa base previa registrada antes del cambio (`Precio_Anterior`, obtenido de `deleted`).
  * **Precio nuevo:** Nuevo valor asignado al viaje (`Precio_Nuevo`, obtenido de `inserted`).
  * **Fecha y hora:** Momento exacto de la modificación (`Fecha`, vía `GETDATE()`).
  * **Usuario:** Cuenta del sistema que ejecutó la instrucción (`Usuario`, vía `SYSTEM_USER`).
  * **Terminal:** Estación de trabajo desde donde se ejecutó (`Terminal`, vía `HOST_NAME()`).
  * **Tipo de operación:** Acción realizada en la tabla (`Tipo_Operacion: 'UPDATE'`).

#### Código de Demostración (Caso 1):
```sql
USE CorrientesPoraBus;
GO

-- 1. Estado original del Viaje 1
SELECT 
    '1. VALOR ORIGINAL' AS Momento,
    Id_Viaje, 
    Precio_Base, 
    Hora_Salida, 
    Patente
FROM Viaje 
WHERE Id_Viaje = 1;

-- 2. Modificaciones 
UPDATE Viaje 
SET Precio_Base = 5000.00 
WHERE Id_Viaje = 1;

-- 3. Estado actual modificado
SELECT 
    'Primer valor modificado' AS Momento,
    Id_Viaje, 
    Precio_Base, 
    Hora_Salida, 
    Patente
FROM Viaje 
WHERE Id_Viaje = 1;

UPDATE Viaje 
SET Precio_Base = 12000.00 
WHERE Id_Viaje = 1;

-- Estado actual modificado por segunda vez
SELECT 
    'Segunda vez modificado' AS Momento,
    Id_Viaje, 
    Precio_Base, 
    Hora_Salida, 
    Patente
FROM Viaje 
WHERE Id_Viaje = 1;

-- 4. Registro generado en la tabla de auditoría
SELECT 
    '3. AUDITORIA REGISTRADA' AS Momento,
    Id_Auditoria, 
    Id_Viaje, 
    Precio_Anterior, 
    Precio_Nuevo, 
    Tipo_Operacion, 
    Usuario, 
    Terminal, 
    CONVERT(VARCHAR(19), Fecha, 120) AS Fecha
FROM Auditoria_Viaje 
WHERE Id_Viaje = 1;
GO
```
<img width="1157" height="447" alt="caso_prueba1" src="https://github.com/user-attachments/assets/da1b6132-9a6f-42bc-8fd1-03607fbabb29" />

---

### Caso 2: Auditoría de Ventas
Supongamos que un empleado modifica el estado de una venta (por ejemplo, pasa de 'Confirmada' a 'Cancelada') o se ejecuta una eliminación física del registro.
* **Tabla principal:** `Venta`
* **Tabla de auditoría:** `Auditoria_Venta`
* **Información a registrar:**
  * **Venta afectada:** Identificador de la venta (`Id_Venta`).
  * **Estado anterior:** Estado que tenía la venta antes de operar (`Estado_Anterior`, obtenido de `deleted`).
  * **Estado nuevo:** Nuevo estado asignado tras la modificación (`Estado_Nuevo`, obtenido de `inserted`; queda en `NULL` si fue una eliminación).
  * **Fecha y hora:** Momento en que ocurrió el cambio o borrado (`Fecha`, vía `GETDATE()`).
  * **Usuario:** Cuenta responsable de la operación (`Usuario`, vía `SYSTEM_USER`).
  * **Terminal:** Puesto o boletería desde donde se operó (`Terminal`, vía `HOST_NAME()`).
  * **Tipo de operación:** Clasificación de la acción ejecutada (`Tipo_Operacion: 'UPDATE'` o `'DELETE'`).

#### Código de Demostración (Caso 2):
```sql
USE CorrientesPoraBus;
GO

-- Paso 1: Valor original ('Confirmada')
SELECT 
    '1. VALOR ORIGINAL' AS Momento,
    Id_Venta, 
    Estado, 
    Fecha, 
    Id_Cliente
FROM Venta 
WHERE Id_Venta = 2;

-- Paso 2: Cancelación de la venta
UPDATE Venta 
SET Estado = 'Cancelada' 
WHERE Id_Venta = 2;

-- Paso 3: Valor modificado ('Cancelada')
SELECT 
    '2. VALOR MODIFICADO' AS Momento,
    Id_Venta, 
    Estado, 
    Fecha, 
    Id_Cliente
FROM Venta 
WHERE Id_Venta = 2;

-- Paso 4: Registro capturado en auditoría
SELECT 
    '3. AUDITORIA REGISTRADA' AS Momento,
    Id_Auditoria, 
    Id_Venta, 
    Estado_Anterior, 
    Estado_Nuevo, 
    Tipo_Operacion, 
    Usuario, 
    Terminal, 
    CONVERT(VARCHAR(19), Fecha, 120) AS Fecha
FROM Auditoria_Venta 
WHERE Id_Venta = 2;
GO
```
<img width="1462" height="357" alt="caso_prueba2" src="https://github.com/user-attachments/assets/6b498bbc-adc2-48fa-99c1-89d8fa14ad03" />

---

### Caso 3: Auditoría de Pasajes (Modificación de Tarifa y Butaca)
Supongamos que un usuario altera manualmente el precio unitario cobrado por un boleto ya emitido o reasigna el asiento asignado dentro de la unidad.
* **Tabla principal:** `Pasaje`
* **Tabla de auditoría:** `Auditoria_Pasaje`
* **Información a registrar:**
  * **Pasaje afectado:** Identificador unívoco del boleto (`Id_Pasaje`).
  * **Campo modificado:** Atributo granular que cambió (`Campo_Modificado: 'Precio_Unitario'` o `'Id_Butaca'`).
  * **Valor anterior:** Dato previo que tenía el campo (`Valor_Anterior`, obtenido de `deleted`).
  * **Valor nuevo:** Nuevo dato asignado (`Valor_Nuevo`, obtenido de `inserted`).
  * **Fecha y hora:** Momento exacto de la transacción (`Fecha`, vía `GETDATE()`).
  * **Usuario:** Cuenta del sistema que ejecutó el comando (`Usuario`, vía `SYSTEM_USER`).
  * **Terminal:** Terminal desde donde se ejecutó (`Terminal`, vía `HOST_NAME()`).
  * **Tipo de operación:** Clasificación de la acción (`Tipo_Operacion: 'UPDATE'`).

#### Código de Demostración (Caso 3):
```sql
USE CorrientesPoraBus;
GO

-- 1. Estado original del Pasaje 1
SELECT 
    '1. VALOR ORIGINAL' AS Momento,
    Id_Pasaje, 
    Precio_Unitario, 
    Id_Butaca, 
    Id_Venta, 
    Id_Pasajero
FROM Pasaje 
WHERE Id_Pasaje = 1;

-- 2. Modificación: Se cambia el precio a 33000.00 y se reasigna a Butaca 3
UPDATE Pasaje 
SET Precio_Unitario = 33000.00,
    Id_Butaca = 3 
WHERE Id_Pasaje = 1;

-- 3. Estado actual modificado
SELECT 
    '2. VALOR MODIFICADO' AS Momento,
    Id_Pasaje, 
    Precio_Unitario, 
    Id_Butaca, 
    Id_Venta, 
    Id_Pasajero
FROM Pasaje 
WHERE Id_Pasaje = 1;

-- 4. Registros generados en la tabla de auditoría (uno por precio y otro por butaca)
SELECT 
    '3. AUDITORIA REGISTRADA' AS Momento,
    Id_Auditoria, 
    Id_Pasaje, 
    Campo_Modificado, 
    Valor_Anterior, 
    Valor_Nuevo, 
    Tipo_Operacion, 
    Usuario, 
    Terminal, 
    CONVERT(VARCHAR(19), Fecha, 120) AS Fecha
FROM Auditoria_Pasaje 
WHERE Id_Pasaje = 1;
GO
```
<img width="1467" height="416" alt="caso_prueba3" src="https://github.com/user-attachments/assets/defd3ca6-11e6-4a61-a884-ee48fe438f33" />

---

### Caso 4: Eliminación Física de un Pasaje (DELETE)
Supongamos que un operador elimina físicamente un boleto emitido en el sistema para desmantelar una venta.
* **Tabla principal:** `Pasaje`
* **Tabla de auditoría:** `Auditoria_Pasaje`
* **Información a registrar:**
  * **Pasaje afectado:** Identificador unívoco del boleto borrado (`Id_Pasaje`).
  * **Campo modificado:** Indicador de baja física (`Campo_Modificado: 'REGISTRO_COMPLETO'`).
  * **Valor anterior:** Cadena consolidada con los datos clave del boleto antes de eliminarse (`Valor_Anterior: 'Venta:X | Butaca:Y | Precio:Z'`).
  * **Valor nuevo:** Queda en nulo dado que el registro ya no existe (`Valor_Nuevo: NULL`).
  * **Fecha y hora:** Momento exacto de la baja (`Fecha`, vía `GETDATE()`).
  * **Usuario:** Cuenta del sistema que ejecutó la eliminación (`Usuario`, vía `SYSTEM_USER`).
  * **Terminal:** Estación de trabajo responsable (`Terminal`, vía `HOST_NAME()`).
  * **Tipo de operación:** Clasificación de la acción (`Tipo_Operacion: 'DELETE'`).

#### Código de Demostración (Caso 4):
```sql
USE CorrientesPoraBus;
GO

-- 1. Vaciar auditoría previa de pasajes y asegurar existencia del Pasaje 5
TRUNCATE TABLE Auditoria_Pasaje;

IF NOT EXISTS (SELECT 1 FROM Pasaje WHERE Id_Pasaje = 5)
BEGIN
    SET IDENTITY_INSERT Pasaje ON;
    INSERT INTO Pasaje (Id_Pasaje, Precio_Unitario, Id_Venta, Id_Viaje, Id_Butaca, Id_Pasajero)
    VALUES (5, 25000.00, 5, 5, 9, 7);
    SET IDENTITY_INSERT Pasaje OFF;
END;
GO

-- Paso 1: Estado original del Pasaje 5
SELECT 
    '1. VALOR ORIGINAL (ACTIVO)' AS Momento,
    Id_Pasaje, 
    Precio_Unitario, 
    Id_Venta, 
    Id_Viaje, 
    Id_Butaca, 
    Id_Pasajero
FROM Pasaje 
WHERE Id_Pasaje = 5;

-- Paso 2: Eliminación física
DELETE FROM Pasaje 
WHERE Id_Pasaje = 5;

-- Paso 3: Verificación de eliminación en la tabla activa (retorna 0 filas)
SELECT 
    '2. REGISTRO EN TABLA ACTIVA' AS Momento,
    Id_Pasaje, 
    Precio_Unitario, 
    Id_Venta, 
    Id_Viaje, 
    Id_Butaca, 
    Id_Pasajero
FROM Pasaje 
WHERE Id_Pasaje = 5;

-- Paso 4: Registro resguardado en la tabla de auditoría
SELECT 
    '3. AUDITORIA REGISTRADA' AS Momento,
    Id_Auditoria, 
    Id_Pasaje, 
    Campo_Modificado, 
    Valor_Anterior, 
    Valor_Nuevo, 
    Tipo_Operacion, 
    Usuario, 
    Terminal, 
    CONVERT(VARCHAR(19), Fecha, 120) AS Fecha
FROM Auditoria_Pasaje 
WHERE Id_Pasaje = 5 AND Tipo_Operacion = 'DELETE';
GO
```
<img width="1457" height="392" alt="caso_prueba4" src="https://github.com/user-attachments/assets/5607c09a-2946-401c-888f-7ae652856c49" />

---

### Caso 5: Casos Fallidos (Restricciones Declarativas vs. Triggers)
Supongamos que un usuario intenta vulnerar las reglas del negocio ingresando estados inexistentes, precios negativos o intentando borrar ventas que contienen dependencias relacionales activas.
* **Comportamiento esperado:** Las restricciones del motor (`CHECK` y `FOREIGN KEY`) abortan la transacción antes de completarse, impidiendo que el trigger se dispare y evitando el ingreso de registros erróneos a las tablas de auditoría.

#### Código de Demostración (Caso 5):
```sql
USE CorrientesPoraBus;
GO

PRINT '========================================================================';
PRINT '         REPORTE DE CASOS FALLIDOS: RESTRICCIONES DE INTEGRIDAD         ';
PRINT '========================================================================';
PRINT '';

-- =========================================================================
-- CASO FALLIDO 1: Violación CHECK en Estado de Venta
-- =========================================================================
PRINT '>>> [CASO FALLIDO 1]: Intentar asignar Estado = ''Anulada'' en Venta 1';
BEGIN TRY
    UPDATE Venta 
    SET Estado = 'Anulada' 
    WHERE Id_Venta = 1;

    PRINT 'FALLÓ LA PRUEBA: La base de datos permitió un estado no admitido.';
END TRY
BEGIN CATCH
    PRINT 'VALIDACIÓN EXITOSA (Bloqueado por restricción CHECK):';
    PRINT '   Error: ' + ERROR_MESSAGE();
END CATCH;
PRINT '------------------------------------------------------------------------';

-- =========================================================================
-- CASO FALLIDO 2: Violación Clave Foránea (FOREIGN KEY) al Borrar Venta
-- =========================================================================
PRINT '>>> [CASO FALLIDO 2]: Intentar eliminar Venta 1 con Pasajes asociados';
BEGIN TRY
    DELETE FROM Venta 
    WHERE Id_Venta = 1;

    PRINT 'FALLÓ LA PRUEBA: Se permitió borrar un registro con claves foráneas dependientes.';
END TRY
BEGIN CATCH
    PRINT 'VALIDACIÓN EXITOSA (Bloqueado por Integridad Referencial FK):';
    PRINT '   Error: ' + ERROR_MESSAGE();
END CATCH;
PRINT '------------------------------------------------------------------------';

-- =========================================================================
-- CASO FALLIDO 3: Violación CHECK en Tarifa de Pasaje (Importe Negativo)
-- =========================================================================
PRINT '>>> [CASO FALLIDO 3]: Intentar asignar Precio_Unitario = -1500.00 en Pasaje 2';
BEGIN TRY
    UPDATE Pasaje 
    SET Precio_Unitario = -1500.00 
    WHERE Id_Pasaje = 2;

    PRINT 'FALLÓ LA PRUEBA: Se permitió cargar un precio menor o igual a cero.';
END TRY
BEGIN CATCH
    PRINT 'VALIDACIÓN EXITOSA (Bloqueado por restricción CHECK de Precio):';
    PRINT '   Error: ' + ERROR_MESSAGE();
END CATCH;
PRINT '========================================================================';
GO
```
<img width="1422" height="427" alt="casos-fallos" src="https://github.com/user-attachments/assets/5cde3b4d-56de-4b47-ab8e-3054ca87dc92" />
