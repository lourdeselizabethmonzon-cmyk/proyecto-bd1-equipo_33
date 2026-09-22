# NORMALIZACIÓN

## Justificación del Proceso de Normalización (1FN, 2FN y 3FN)

### 1. Primera Forma Normal (1FN)
**Regla teórica:** Exige que todos los atributos sean atómicos (indivisibles), que no existan grupos repetitivos y que cada tabla posea una clave primaria definida.

Para que la estructura de datos se encuentre en la 1FN:
* Todos los atributos, valores almacenados en las columnas, deben ser indivisibles. El valor de una columna debe ser una entidad atómica. (->Tabla con un atributo divisible en varias partes)
* No deben existir grupos de valores repetidos (->Aislamiento de los datos repetitivos de una tabla en otra independiente)
* Cada tabla debe tener un identificador único (PK)

**Modificación realizadas:**
* En la tabla Persona se identificó que el campo Teléfono correspondía a un atributo multivaluado (una persona puede tener múltiples números: fijo, celular, laboral).
* Se extrajo a una tabla independiente Teléfono vinculada mediante clave foránea (`fk_Persona`), eliminando la columna directa de Persona para asegurar atomicidad estricta.

### 2. Segunda Forma Normal (2FN)
**Regla teórica:** Debe estar en 1FN y ningún atributo no clave debe depender parcialmente de una clave primaria compuesta (dependencia funcional completa de la clave).

Para que la estructura de datos se encuentre en la 2FN:
* Todos los valores de las columnas de una fila deben depender de la clave primaria de dicha fila.
* Todas las columnas (no claves) son accesibles a través de la clave completa y nunca mediante una parte de esa clave

**Modificación aplicada:**
* En la tabla Butacas, que poseía clave primaria compuesta (`Nro_Butaca`, `Patente`), se sustituyó por una clave subrogada simple (`Id_Butaca`), convirtiendo Patente en una clave foránea común hacia Colectivo. Con esto, toda la entidad pasa a depender enteramente de una clave primaria simple sin dependencias parciales.

### 3. Tercera Forma Normal (3FN)
Para que la estructura de datos se encuentre en la 3FN:
**Regla teórica:** Debe estar en 2FN y no deben existir dependencias funcionales transitivas (ningún atributo no clave debe depender de otro atributo no clave; todo atributo no clave debe depender directa y únicamente de la clave primaria).

* Las columnas que no forman parte de la clave primaria deben depender sólo de la clave, nunca de otra columna no clave.
* Evitar la dependencia transitiva.

**Modificaciones aplicadas:**
* **Venta:** Se suprimió la columna `Monto_Total`. Al ser un valor calculado a partir de la suma de los pasajes (`SUM(Precio_Unitario)`), mantenerlo genera redundancia y riesgo de anomalías de actualización e inconsistencia.
* **Pasaje:** Se quitó la referencia compuesta a Patente en Pasaje. Como Viaje ya determina qué colectivo realiza el servicio, almacenar la patente en el pasaje creaba una dependencia transitiva e inconsistencias de asignación. El pasaje referencia directamente a `Id_Viaje` y a `Id_Butaca`.
* **Ruta:** Se removió la columna `fk_Viaje` de Ruta. La ruta es un trayecto independiente; la relación correcta es que el viaje referencia a la ruta y no a la inversa.
* **Origen y Destino:** Se eliminaron ambas tablas porque no contenían datos propios y actuaban como intermediarios redundantes hacia Terminal. En Ruta se definieron directamente dos claves foráneas de rol: `fk_Terminal_Origen` y `fk_Terminal_Destino`.
* **Terminal:** Se crearon las tablas independientes Localidad y Provincia, dejando en Terminal únicamente la clave foránea `fk_Localidad` y eliminando los campos de texto plano Ciudad y Localidad.