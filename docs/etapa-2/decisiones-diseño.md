# 3. Decisiones de Diseño — Etapa II

* **Manejo de herencia y roles de Persona:** Se implementó una generalización/especialización conectando `Persona` con tablas hijas (`Empleado`, `Cliente_Comprador`, `Pasajero_Transportado`) mediante claves foráneas y primarias compartidas (`Id_Persona`), evitando la dispersión de datos identificatorios y asegurando la integridad referencial.

* **Descomposición de atributos multivaluados (1FN):** Se extrajo el campo `Telefono` de la entidad `Persona` hacia una tabla independiente `Telefono` con clave foránea `Id_Persona` (FK), permitiendo registrar múltiples líneas de contacto por individuo sin violar la atomicidad ni introducir grupos repetitivos.

* **Implementación de clave subrogada en Butacas (2FN):** Se eliminó la clave primaria compuesta (`Nro_Butaca`, `Patente`), reemplazándola por el identificador simple `Id_Butaca`. Esto evitó dependencias funcionales parciales y simplificó la vinculación con las emisiones.

* **Eliminación de campos calculados (3FN):** Se retiró la columna `Monto_Total` de `Venta` para calcularse dinámicamente (`SUM(Precio_Unitario)`), previniendo anomalías de actualización e inconsistencias frente a modificaciones en los pasajes.

* **Supresión de transitividad en Pasaje (3FN):** Se eliminó la clave foránea `Patente` dentro de `Pasaje`, vinculándolo únicamente a `Id_Viaje` y `Id_Butaca`. Dado que el viaje ya determina el colectivo asignado, se erradicó la redundancia vehicular y el riesgo de colisión de datos.

* **Resolución de dependencia circular en trayectos (3FN):** Se suprimió `fk_Viaje` de la tabla `Ruta`, estableciendo una relación unidireccional donde el servicio operativo referencia al trayecto programado (`Viaje.fk_Ruta`) y no a la inversa.

* **Eliminación de entidades pasarela redundantes (3FN):** Se suprimieron las tablas vacías `Origen` y `Destino`, incorporando en su lugar dos claves foráneas de rol (`fk_Terminal_Origen` y `fk_Terminal_Destino`) en `Ruta` que apuntan de forma directa a `Terminal`.

* **Normalización geográfica jerárquica (3FN):** Se aislaron las entidades `Localidad` y `Provincia`, eliminando los atributos de texto plano `Ciudad` y `Localidad` en `Terminal`, erradicando la dependencia transitiva `Id_Terminal → Localidad → Provincia`.