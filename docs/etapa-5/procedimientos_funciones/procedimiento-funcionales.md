# ETAPA V: Implementación de Temas Técnicos Avanzados
## Tema 1: Procedimientos y Funciones Almacenadas

---

### 1. Definición y Objetivo

*   **Procedimiento Almacenado (`sp_EmitirPasaje`):** Es un subprograma precompilado y almacenado directamente en el motor del Sistema de Gestión de Bases de Datos (SGBD). Su objetivo principal es encapsular y ejecutar un bloque de transacciones operativas complejas (como insertar simultáneamente la cabecera de una venta, registrar su método de pago y emitir el pasaje nominal correspondiente) en una sola unidad lógica de ejecución.
*   **Función Escalar (`fn_CalcularDescuentoCliente`):** Es una subrutina programada que acepta parámetros de entrada (en este caso, el identificador del cliente), procesa una consulta interna para evaluar su comportamiento histórico de compra y retorna un único valor numérico escalar (el porcentaje de descuento aplicable) que puede integrarse dinámicamente en cualquier consulta DQL (`SELECT`).

---

### 2. Ventajas y Aplicaciones en el Negocio

*   **Centralización de la Lógica Comercial:** Las reglas de negocio de la empresa ("Corrientes Porá Bus") residen de manera unificada en el servidor. Esto evita que distintas aplicaciones cliente o sucursales deban replicar la lógica de cálculo o la secuencia de inserción de boletos, reduciendo márgenes de error.
*   **Optimización del Rendimiento y Tráfico de Red:** Al estar precompiladas en el motor, las consultas complejas y los múltiples comandos de escritura se ejecutan mediante una única llamada de red (`EXEC` o invocación en el `SELECT`). Esto reduce drásticamente el intercambio de paquetes entre las terminales de boletería y el servidor central.
*   **Seguridad y Consistencia de Datos:** Permite otorgar permisos de ejecución sobre los procedimientos a los operadores de ventanilla sin necesidad de concederles privilegios de modificación directa (`INSERT` o `UPDATE`) sobre las tablas transaccionales críticas. Esto garantiza la trazabilidad y previene la alteración o corrupción de registros históricos.

---

### 3. Problema de Negocio Resuelto

Históricamente, la emisión de boletos requería que el operador ejecutara de forma manual múltiples sentencias de inserción encadenadas en diferentes tablas (`Venta`, `Pago` y `Pasaje`). Si se producía una interrupción en la red, un error de tipeo o un corte de energía a mitad del proceso, la base de datos quedaba con registros huérfanos o inconsistentes (por ejemplo, pagos cobrados sin pasajes vinculados, o pasajes emitidos sin cabecera de venta). 

Asimismo, el cálculo de beneficios por fidelidad para clientes frecuentes exigía arqueos y sumatorias manuales lentas y propensas a errores. Mediante la implementación de **`sp_EmitirPasaje`**, el circuito comercial se unifica y blinda en un único paso atómico. Por su parte, la función **`fn_CalcularDescuentoCliente`** automatiza en tiempo real el sistema de incentivos, evaluando el historial del pasajero de forma instantánea antes de cada nueva emisión.

---

### 4. Implementación en SQL Server (T-SQL)

A continuación se detallan los scripts de creación correspondientes a los objetos almacenados en la base de datos `CorrientesPoraBus`.

#### A. Creación del Procedimiento Almacenado

**Descripción técnica:** El procedimiento `sp_EmitirPasaje` recibe como parámetros todos los datos necesarios desde la ventanilla. Su lógica interna realiza tres inserciones encadenadas. Primero, crea la cabecera de la factura en la tabla `Venta`. Inmediatamente, utiliza la función de sistema `SCOPE_IDENTITY()` para atrapar el ID autonumérico que SQL Server acaba de generar para esa venta, y lo guarda en una variable. Finalmente, reutiliza ese mismo ID atrapado para registrar el comprobante en `Pago` y el boleto en `Pasaje`, asegurando que toda la información quede perfectamente enlazada sin riesgo de perder la referencia.

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
