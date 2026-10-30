# INFORME TÉCNICO: PROCEDIMIENTOS Y FUNCIONES ALMACENADAS EN SQL SERVER EXPRESS

## 1. DEFINICIÓN Y OBJETIVO

Los procedimientos almacenados (Stored Procedures) y las funciones definidas por el usuario (User-Defined Functions) son bloques de código T-SQL precompilados que residen físicamente en el motor del Sistema de Gestión de Bases de Datos (SGBD). A diferencia de las sentencias SQL ad-hoc enviadas desde una aplicación cliente, estos objetos estructuran y encapsulan la lógica de negocio directamente en el servidor.

En arquitecturas cliente/servidor con múltiples terminales (como una red de boleterías), la delegación de operaciones complejas al motor de base de datos persigue un objetivo fundamental: **garantizar la consistencia transaccional y centralizar el procesamiento**.

- **Procedimiento Almacenado (`sp_`):** Diseñado para ejecutar acciones transaccionales (DML). Puede procesar múltiples operaciones secuenciales de escritura (`INSERT`, `UPDATE`, `DELETE`), manejar variables temporales y alterar el estado de la base de datos de forma atómica.
- **Función Escalar (`fn_`):** Diseñada para cálculos y transformaciones de datos (DQL). Recibe parámetros de entrada, procesa una lógica de lectura interna y retorna un único valor numérico o de texto. No puede alterar el estado de la base de datos (prohibido el uso de `INSERT`/`UPDATE`/`DELETE` en su interior), lo que permite integrarla dinámicamente dentro de sentencias `SELECT`.

## 2. VENTAJAS Y APLICACIONES

La adopción de rutinas almacenadas en el servidor aporta beneficios estructurales, de rendimiento y de seguridad frente a la lógica controlada por software externo:

- **Reducción drástica del tráfico de red:** En lugar de enviar múltiples paquetes con sentencias individuales a través de la red local o internet, la aplicación cliente envía una única llamada (`EXEC`), y el servidor procesa toda la cadena de operaciones internamente.
- **Seguridad por encapsulamiento:** Se otorgan permisos de ejecución (`EXECUTE`) a los usuarios o roles de ventanilla sobre los procedimientos, revocando los permisos directos de escritura sobre las tablas subyacentes. Esto previene manipulaciones manuales indebidas y blinda la estructura contra inyecciones SQL.
- **Centralización de reglas de negocio:** La lógica (por ejemplo, el cálculo de descuentos o el orden de inserción de una venta) se escribe y compila una sola vez. Si la política comercial cambia, se actualiza el objeto en el servidor y todas las terminales heredan la nueva regla instantáneamente sin necesidad de actualizar el software cliente.
- **Velocidad de ejecución:** Al estar precompilados, el motor SQL Server ya tiene almacenado el plan de ejecución óptimo en su memoria caché (Execution Plan), ahorrando el tiempo de análisis y compilación que requieren las consultas enviadas en texto plano.

## 3. IMPLEMENTACIÓN EN SQL SERVER EXPRESS

En SQL Server Express, la implementación de estos objetos aprovecha herramientas nativas avanzadas de Transact-SQL para interactuar con la memoria temporal del motor durante la ejecución:

1. **Gestión de Identidad (`SCOPE_IDENTITY()`):** Dentro de un procedimiento almacenado, esta función de sistema permite atrapar de manera segura el último ID autonumérico generado en el bloque de código actual (por ejemplo, el número de una factura recién insertada). Esto asegura que los registros hijos (detalles, pagos) se vinculen a la cabecera correcta, incluso en entornos con alta concurrencia donde múltiples vendedores insertan datos al mismo milisegundo.
2. **Manejo Estructurado de Errores (`TRY...CATCH`):** Los procedimientos permiten envolver las transacciones en bloques de control de errores. Si una restricción de integridad (como una sobreventa detectada por un `UNIQUE`) aborta una operación, el bloque `CATCH` intercepta el fallo y previene la inserción de registros huérfanos.
3. **Escalaridad de Funciones:** Las funciones se implementan utilizando la cláusula `RETURNS` seguida del tipo de dato, y su lógica se procesa devolviendo obligatoriamente un escalar mediante `RETURN`. Al ser puramente analíticas, SQL Server permite tratarlas como una columna dinámica más en cualquier consulta relacional.

## 4. CASO CONCRETO APLICADO A "CORRIENTES PORÁ BUS"

### 4.1. Problema de Negocio

Históricamente, la emisión de boletos en mostrador exigía que el operador ejecutara de forma secuencial múltiples acciones: registrar los datos de la venta, procesar el pago y emitir el boleto físico. Si ocurría un microcorte de red, una falla eléctrica o un error tipográfico a mitad del proceso, la base de datos quedaba expuesta a anomalías graves (ej. pasajes emitidos sin cobro registrado, o pagos asentados sin boleto asignado). Además, el cálculo de beneficios para clientes frecuentes dependía de la revisión manual del historial, un proceso lento y propenso a errores humanos.

### 4.2. Reglas Lógicas Aplicadas

Para resolver esta problemática, se implementó el procedimiento almacenado **`sp_EmitirPasaje`** y la función escalar **`fn_CalcularDescuentoCliente`**, blindando las siguientes reglas de negocio del sistema:

- **RN04 – Validación Integral de Pagos y RN05 – Nominatividad del Pasaje:** El procedimiento `sp_EmitirPasaje` consolida la inserción encadenada de la tabla `Venta`, atrapa su clave primaria mediante `SCOPE_IDENTITY()`, y la utiliza para insertar instantáneamente el `Pago` y el `Pasaje`. Esto garantiza que no existan boletos sin su respectiva cabecera de venta ni método de pago.
- **RN03 – Historial e Inmutabilidad del Precio Unitario:** El procedimiento exige el paso del precio como parámetro y lo inserta físicamente en el detalle del boleto, delegando al motor la congelación de la tarifa al segundo exacto de la emisión.
- **RN02 – Control Estricto de Capacidad y Stock:** Al centralizar la venta en el servidor, si dos operadores intentan vender el mismo asiento a la vez, el motor procesa el primer `EXEC` exitosamente y bloquea el segundo mediante la restricción física `UQ_Pasaje_Viaje_Butaca`, abortando el procedimiento del segundo vendedor sin afectar las tablas.
- **Automatización de Fidelidad (Descuentos):** La función `fn_CalcularDescuentoCliente` analiza en tiempo real el volumen histórico de compras del pasajero. Al integrarse directamente en las consultas de boletería, elimina el arqueo manual y asegura que los descuentos (10% o 15%) se apliquen con total precisión técnica según los montos acumulados exigidos por la gerencia comercial.
