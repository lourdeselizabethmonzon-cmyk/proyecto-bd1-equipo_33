# 3. Decisiones de Diseño — Etapa II

* **Manejo de herencia y roles de Persona:** Se implementó una generalización/especialización conectando Persona con las tablas hijas Empleado, Cliente_Comprador y Pasajero_Transportado mediante claves primarias y foráneas compartidas (`Id_Persona`), evitando la duplicación de datos identificatorios y asegurando la integridad referencial.

* **Descomposición de atributos multivaluados (1FN):** Se extrajo el campo `Telefono` de la entidad Persona hacia una tabla independiente `Telefono` con clave foránea `Id_Persona`, permitiendo registrar múltiples líneas de contacto por individuo sin violar la atomicidad ni introducir grupos repetitivos.

* **Implementación de clave subrogada en Butacas (2FN):** Se eliminó la clave primaria compuesta (`Nro_Butaca`, `Patente`) reemplazándola por el identificador simple `Id_Butaca`, simplificando la vinculación con otras entidades y evitando dependencias funcionales parciales.

* **Eliminación de campos calculados (3FN):** Se retiró la columna `Monto_Total` de Venta para calcularse dinámicamente mediante la suma de los `Precio_Unitario` de los pasajes asociados, previniendo anomalías de actualización e inconsistencias en los importes.

* **Supresión de transitividad en Pasaje (3FN):** Se eliminó la clave foránea `Patente` dentro de Pasaje, vinculándolo únicamente a `Id_Viaje` y `Id_Butaca`. Dado que el viaje ya determina el ómnibus asignado, se eliminó la redundancia vehicular y el riesgo de inconsistencias.

* **Resolución de dependencia circular en trayectos (3FN):** Se suprimió `fk_Viaje` de la tabla Ruta, estableciendo una relación unidireccional donde el servicio operativo referencia al trayecto programado mediante `Viaje.fk_Ruta` y no a la inversa.

* **Eliminación de entidades pasarela redundantes (3FN):** Se suprimieron las tablas Origen y Destino, incorporando en su lugar las claves foráneas de rol `fk_Terminal_Origen` y `fk_Terminal_Destino` en Ruta, ambas apuntando directamente a Terminal.

* **Normalización geográfica jerárquica (3FN):** Se aislaron las entidades Localidad y Provincia, eliminando los atributos de texto plano `Ciudad` y `Localidad` en Terminal y evitando la dependencia transitiva `Id_Terminal → Localidad → Provincia`.

* **Separación entre Ruta y Viaje:** Se decidió diferenciar la entidad Ruta, que representa un recorrido, de la entidad Viaje, que representa la ejecución concreta de dicho recorrido en una fecha y horario determinados, permitiendo que una misma ruta sea utilizada por múltiples viajes sin duplicar información.

* **Separación de Ómnibus y Butacas:** Se decidió modelar las unidades vehiculares y sus butacas como entidades independientes, permitiendo registrar individualmente cada asiento con su número, piso, ubicación y tipo de servicio, evitando la repetición de información dentro de la entidad Ómnibus.

* **Separación entre tarifa base y precio histórico del Pasaje:** Se decidió mantener la tarifa base asociada al viaje y registrar en Pasaje el `Precio_Unitario` aplicado al momento de la venta, conservando el valor histórico de la operación ante futuras modificaciones de tarifas.

* **Separación entre Venta, Pasaje y Pago:** Se modelaron de forma independiente la Venta, los Pasajes y los Pagos, permitiendo que una venta contenga múltiples pasajes y pueda ser abonada mediante uno o varios medios de pago.

* **Diferenciación entre comprador y pasajero:** Se decidió mantener separados los roles de Cliente_Comprador y Pasajero_Transportado, permitiendo que quien realiza y abona la operación comercial sea diferente de la persona que utiliza efectivamente el servicio.

* **Control de unicidad de Butaca por Viaje:** Se estableció una restricción de unicidad sobre la combinación `Id_Viaje` e `Id_Butaca`, impidiendo que una misma butaca sea asignada a más de un pasajero dentro del mismo viaje y evitando sobreventas.

* **Separación entre Reserva y Venta:** Se diferenciaron las reservas temporales de las ventas confirmadas, permitiendo bloquear una butaca durante un período determinado sin considerarla vendida. Una reserva cancelada o vencida libera nuevamente la butaca para su disponibilidad.

* **Control de superposición de Viajes por unidad:** Se estableció una regla de negocio que impide asignar una misma unidad vehicular a viajes cuyos horarios se superpongan, considerando la fecha y hora de salida y el tiempo estimado de recorrido.

* **Auditoría de las operaciones:** Se decidió asociar las operaciones comerciales y comprobantes emitidos con el empleado responsable, permitiendo identificar la autoría de cada operación y conservar la trazabilidad necesaria para las tareas de control y auditoría.

* **Validación del pago total para confirmar la Venta:** Se estableció que una venta solamente pueda confirmarse cuando la suma de los pagos asociados sea igual al importe total de la operación, evitando confirmar ventas con pagos parciales.