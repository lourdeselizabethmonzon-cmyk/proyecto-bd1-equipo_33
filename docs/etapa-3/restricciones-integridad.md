# Etapa III: Implementación Física

## Parte 2: Restricciones de Integridad (restricciones-integridad.md)

### 2.1. Mapeo de Restricciones por Tabla Vinculadas a Reglas de Negocio (RN.01 a RN.08)

#### 1. Tabla `Persona`
* **`Id_Persona`**: `PK_Persona` (`PRIMARY KEY`, `NOT NULL`, `IDENTITY`). Identificador subrogado único de la entidad base.
* **`Nombre_1`, `Apellido_1`, `Fecha_Nacimiento`, `e_mail`**: `NOT NULL`. Cumple con **RN.01** (registro obligatorio de datos filiatorios y de contacto).
* **`Tipo_Documento`, `Nro_Documento`**: `NOT NULL`, `CHK_Persona_TipoDoc` (`CHECK (Tipo_Documento IN ('DNI', 'CUIT', 'Pasaporte'))`) y `UQ_Persona_Documento` (`UNIQUE (Tipo_Documento, Nro_Documento)`). Cumple con **RN.01** (unicidad estricta e intransferible de documento por individuo).

#### 2. Tabla `Telefono`
* **`Id_Telefono`**: `PK_Telefono` (`PRIMARY KEY`, `NOT NULL`, `IDENTITY`).
* **`Id_Persona`**: `FK_Telefono_Persona` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.01** (vinculación mandatoria del canal telefónico a una persona registrada).
* **`Tipo_de_Telefono`**: `NOT NULL`, `CHK_Telefono_Tipo` (`CHECK (Tipo_de_Telefono IN ('Celular', 'Fijo', 'Laboral'))`).
* **`Nro_Telefono`**: `NOT NULL`.

#### 3. Tabla `Empleado`
* **`Id_Persona`**: `PK_Empleado` (`PRIMARY KEY`) y `FK_Empleado_Persona` (`FOREIGN KEY`, `NOT NULL`). Subtipo de Persona derivado de **RN.01** y **RN.08**.
* **`Legajo`**: `NOT NULL`, `UQ_Empleado_Legajo` (`UNIQUE`). Cumple con **RN.08** (identificación unívoca del responsable de emitir ventas).
* **`Turno_Laboral`**: `NOT NULL`, `CHK_Empleado_Turno` (`CHECK (Turno_Laboral IN ('Mañana', 'Tarde', 'Noche'))`). Cumple con **RN.08** (registro del turno de la transacción).

#### 4. Tabla `Cliente_comprador`
* **`Id_Persona`**: `PK_Cliente_comprador` (`PRIMARY KEY`) y `FK_Cliente_Persona` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.01** (el comprador debe ser una persona registrada en el sistema).

#### 5. Tabla `Pasajero_Transportado`
* **`Id_Persona`**: `PK_Pasajero_Transportado` (`PRIMARY KEY`) y `FK_Pasajero_Persona` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.01** y **RN.05** (el pasajero que viaja debe estar registrado previamente).

#### 6. Tabla `Colectivo`
* **`Patente`**: `PK_Colectivo` (`PRIMARY KEY`, `NOT NULL`). Identificador natural vehicular para cumplir con **RN.06** (unidad operativa asignada).
* **`Marca`, `Modelo`**: `NOT NULL`.
* **`Anio`**: `NOT NULL`, `CHK_Colectivo_Anio` (`CHECK (Anio >= 2000)`). Restricción de flota activa mínima para servicios de larga distancia (**RN.06**).

#### 7. Tabla `Butacas`
* **`Id_Butaca`**: `PK_Butacas` (`PRIMARY KEY`, `NOT NULL`, `IDENTITY`).
* **`Patente`**: `FK_Butacas_Colectivo` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.06** (la butaca existe físicamente en el coche asignado).
* **`Nro_Butaca`**: `NOT NULL`, `CHK_Butaca_Numero` (`CHECK (Nro_Butaca > 0)`) y `UQ_Butaca_Por_Colectivo` (`UNIQUE (Patente, Nro_Butaca)`). Cumple con **RN.02** y **RN.06** (evita duplicar números de asiento en una misma unidad).
* **`Ubicacion`**: `NOT NULL`, `CHK_Butaca_Ubicacion` (`CHECK (Ubicacion IN ('Pasillo', 'Ventanilla'))`).
* **`Tipo_Servicio`**: `NOT NULL`, `CHK_Butaca_Servicio` (`CHECK (Tipo_Servicio IN ('Semicama', 'Cama Ejecutivo', 'Suite Cama'))`). Cumple con **RN.03** (categoría de confort asociada a la tarifa).

#### 8. Tabla `Viaje`
* **`Id_Viaje`**: `PK_Viaje` (`PRIMARY KEY`, `NOT NULL`, `IDENTITY`).
* **`Fecha`, `Hora_Salida`**: `NOT NULL`. Base de control cronológico para devoluciones y reventa (**RN.07**).
* **`Patente`**: `FK_Viaje_Colectivo` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.06** (asociación obligatoria de un colectivo operativo al servicio).
* **`Id_Ruta`**: `FK_Viaje_Ruta` (`FOREIGN KEY`, `NOT NULL`).

#### 9. Tabla `Venta`
* **`Id_Venta`**: `PK_Venta` (`PRIMARY KEY`, `NOT NULL`, `IDENTITY`).
* **`Fecha`**: `NOT NULL`, `DEFAULT GETDATE()`. Marca temporal de auditoría transaccional (**RN.08**).
* **`Estado`**: `NOT NULL`, `CHK_Venta_Estado` (`CHECK (Estado IN ('Confirmada', 'Pendiente', 'Cancelada'))`). Cumple con **RN.04** (transición de estado según validación de cobro) y **RN.07** (cancelación).
* **`Id_Empleado`**: `FK_Venta_Empleado` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.08** (responsabilidad y trazabilidad de emisión).
* **`Id_Cliente`**: `FK_Venta_Cliente` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.01** (comprador formalmente individualizado).

#### 10. Tabla `Pasaje`
* **`Id_Pasaje`**: `PK_Pasaje` (`PRIMARY KEY`, `NOT NULL`, `IDENTITY`).
* **`Precio_Unitario`**: `NOT NULL`, `CHK_Pasaje_Precio` (`CHECK (Precio_Unitario > 0)`). Cumple con **RN.03** (persistencia e inmutabilidad del importe cobrado).
* **`Id_Venta`**: `FK_Pasaje_Venta` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.05** (boleto vinculado indisolublemente a una venta).
* **`Id_Viaje`**: `FK_Pasaje_Viaje` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.02** y **RN.05** (servicio asignado).
* **`Id_Butaca`**: `FK_Pasaje_Butaca` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.02** y **RN.06** (asiento físico real de la unidad).
* **`Id_Pasajero`**: `FK_Pasaje_Pasajero` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN# Etapa III: Implementación Física

## Parte 2: Restricciones de Integridad (restricciones-integridad.md)

### 2.1. Mapeo de Restricciones por Tabla Vinculadas a Reglas de Negocio (RN.01 a RN.08)

#### 1. Tabla `Persona`

* **`Id_Persona`**: `PK_Persona` (`PRIMARY KEY`, `NOT NULL`, `IDENTITY`). Identificador subrogado único de la entidad base.
* **`Nombre_1`, `Apellido_1`, `Fecha_Nacimiento`, `e_mail`**: `NOT NULL`. Cumple con **RN.01** (registro obligatorio de datos filiatorios y de contacto).
* **`Tipo_Documento`, `Nro_Documento`**: `NOT NULL`, `CHK_Persona_TipoDoc` (`CHECK (Tipo_Documento IN ('DNI', 'CUIT', 'Pasaporte'))`) y `UQ_Persona_Documento` (`UNIQUE (Tipo_Documento, Nro_Documento)`). Cumple con **RN.01** (unicidad estricta e intransferible de documento por individuo).

#### 2. Tabla `Telefono`

* **`Id_Telefono`**: `PK_Telefono` (`PRIMARY KEY`, `NOT NULL`, `IDENTITY`).
* **`Id_Persona`**: `FK_Telefono_Persona` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.01** (vinculación mandatoria del canal telefónico a una persona registrada).
* **`Tipo_de_Telefono`**: `NOT NULL`, `CHK_Telefono_Tipo` (`CHECK (Tipo_de_Telefono IN ('Celular', 'Fijo', 'Laboral'))`).
* **`Nro_Telefono`**: `NOT NULL`.

#### 3. Tabla `Empleado`

* **`Id_Persona`**: `PK_Empleado` (`PRIMARY KEY`) y `FK_Empleado_Persona` (`FOREIGN KEY`, `NOT NULL`). Subtipo de Persona derivado de **RN.01** y **RN.08**.
* **`Legajo`**: `NOT NULL`, `UQ_Empleado_Legajo` (`UNIQUE`). Cumple con **RN.08** (identificación unívoca del responsable de emitir ventas).
* **`Turno_Laboral`**: `NOT NULL`, `CHK_Empleado_Turno` (`CHECK (Turno_Laboral IN ('Mañana', 'Tarde', 'Noche'))`). Cumple con **RN.08** (registro del turno de la transacción).

#### 4. Tabla `Cliente_comprador`

* **`Id_Persona`**: `PK_Cliente_comprador` (`PRIMARY KEY`) y `FK_Cliente_Persona` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.01** (el comprador debe ser una persona registrada en el sistema).

#### 5. Tabla `Pasajero_Transportado`

* **`Id_Persona`**: `PK_Pasajero_Transportado` (`PRIMARY KEY`) y `FK_Pasajero_Persona` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.01** y **RN.05** (el pasajero que viaja debe estar registrado previamente).

#### 6. Tabla `Colectivo`

* **`Patente`**: `PK_Colectivo` (`PRIMARY KEY`, `NOT NULL`). Identificador natural vehicular para cumplir con **RN.06** (unidad operativa asignada).
* **`Marca`, `Modelo`**: `NOT NULL`.
* **`Anio`**: `NOT NULL`, `CHK_Colectivo_Anio` (`CHECK (Anio >= 2000)`). Restricción de flota activa mínima para servicios de larga distancia (**RN.06**).

#### 7. Tabla `Butacas`

* **`Id_Butaca`**: `PK_Butacas` (`PRIMARY KEY`, `NOT NULL`, `IDENTITY`).
* **`Patente`**: `FK_Butacas_Colectivo` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.06** (la butaca existe físicamente en el coche asignado).
* **`Nro_Butaca`**: `NOT NULL`, `CHK_Butaca_Numero` (`CHECK (Nro_Butaca > 0)`) y `UQ_Butaca_Por_Colectivo` (`UNIQUE (Patente, Nro_Butaca)`). Cumple con **RN.02** y **RN.06** (evita duplicar números de asiento en una misma unidad).
* **`Ubicacion`**: `NOT NULL`, `CHK_Butaca_Ubicacion` (`CHECK (Ubicacion IN ('Pasillo', 'Ventanilla'))`).
* **`Tipo_Servicio`**: `NOT NULL`, `CHK_Butaca_Servicio` (`CHECK (Tipo_Servicio IN ('Semicama', 'Cama Ejecutivo', 'Suite Cama'))`). Cumple con **RN.03** (categoría de confort asociada a la tarifa).

#### 8. Tabla `Viaje`

* **`Id_Viaje`**: `PK_Viaje` (`PRIMARY KEY`, `NOT NULL`, `IDENTITY`).
* **`Fecha`, `Hora_Salida`**: `NOT NULL`. Base de control cronológico para devoluciones y reventa (**RN.07**).
* **`Patente`**: `FK_Viaje_Colectivo` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.06** (asociación obligatoria de un colectivo operativo al servicio).
* **`Id_Ruta`**: `FK_Viaje_Ruta` (`FOREIGN KEY`, `NOT NULL`).

#### 9. Tabla `Venta`

* **`Id_Venta`**: `PK_Venta` (`PRIMARY KEY`, `NOT NULL`, `IDENTITY`).
* **`Fecha`**: `NOT NULL`, `DEFAULT GETDATE()`. Marca temporal de auditoría transaccional (**RN.08**).
* **`Estado`**: `NOT NULL`, `CHK_Venta_Estado` (`CHECK (Estado IN ('Confirmada', 'Pendiente', 'Cancelada'))`). Cumple con **RN.04** (transición de estado según validación de cobro) y **RN.07** (cancelación).
* **`Id_Empleado`**: `FK_Venta_Empleado` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.08** (responsabilidad y trazabilidad de emisión).
* **`Id_Cliente`**: `FK_Venta_Cliente` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.01** (comprador formalmente individualizado).

#### 10. Tabla `Pasaje`

* **`Id_Pasaje`**: `PK_Pasaje` (`PRIMARY KEY`, `NOT NULL`, `IDENTITY`).
* **`Precio_Unitario`**: `NOT NULL`, `CHK_Pasaje_Precio` (`CHECK (Precio_Unitario > 0)`). Cumple con **RN.03** (persistencia e inmutabilidad del importe cobrado).
* **`Id_Venta`**: `FK_Pasaje_Venta` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.05** (boleto vinculado indisolublemente a una venta).
* **`Id_Viaje`**: `FK_Pasaje_Viaje` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.02** y **RN.05** (servicio asignado).
* **`Id_Butaca`**: `FK_Pasaje_Butaca` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.02** y **RN.06** (asiento físico real de la unidad).
* **`Id_Pasajero`**: `FK_Pasaje_Pasajero` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.01** y **RN.05** (nominatividad obligatoria del titular que viaja).
* **`Id_Viaje` + `Id_Butaca`**: `UQ_Pasaje_Viaje_Butaca` (`UNIQUE (Id_Viaje, Id_Butaca)`). Cumple estrictamente con **RN.02** (bloqueo relacional que impide sobreventa o asignar dos veces la misma butaca al mismo viaje).

#### 11. Tabla `Pago`

* **`Id_Pago`**: `PK_Pago` (`PRIMARY KEY`, `NOT NULL`, `IDENTITY`).
* **`Metodo_Pago`**: `NOT NULL`, `CHK_Pago_Metodo` (`CHECK (Metodo_Pago IN ('Efectivo', 'Tarjeta Debito', 'Tarjeta Credito', 'Transferencia'))`). Cumple con **RN.04** (medios de pago admitidos para respaldar la venta).
* **`Monto_a_Pagar`**: `NOT NULL`, `CHK_Pago_Monto` (`CHECK (Monto_a_Pagar > 0)`).
* **`Id_Venta`**: `FK_Pago_Venta` (`FOREIGN KEY`, `NOT NULL`). Cumple con **RN.04** (respaldo financiero atado a la operación comercial).

#### 12. Tablas Geográficas Auxiliares (`Provincia`, `Localidad`, `Terminal`, `Ruta`)

* **`Provincia`**: `PK_Provincia` (`Id_Provincia`), `UQ_Provincia_Nombre` (`Nombre`).
* **`Localidad`**: `PK_Localidad` (`Id_Localidad`), `FK_Localidad_Provincia` (`Id_Provincia`).
* **`Terminal`**: `PK_Terminal` (`Id_Terminal`), `FK_Terminal_Localidad` (`Id_Localidad`).
* **`Ruta`**: `PK_Ruta` (`Id_Ruta`), `FK_Ruta_TerminalOrigen` y `FK_Ruta_TerminalDestino` (hacia `Terminal`), `CHK_Ruta_Distancia` (`Distancia > 0`), y `CHK_TerminalesDiferentes` (`Id_Terminal_Origen <> Id_Terminal_Destino`). Dan soporte de red vial a los servicios (**RN.06**).

---

### 2.2. Justificación de Políticas Referenciales (ON DELETE / ON UPDATE)

En Microsoft SQL Server rige por defecto la política **`NO ACTION`** (equivalente funcional a `RESTRICT`), impidiendo borrar o actualizar registros padre que posean dependencias activas.

#### A. Aplicación de `ON DELETE CASCADE`

Se reservó exclusivamente para entidades débiles con dependencia ontológica total:

* **`FK_Butacas_Colectivo`:** Las butacas son partes físicas del ómnibus (**RN.06**). Si una unidad se retira del parque móvil, su esquema de asientos se extingue junto con ella.
* **`FK_Telefono_Persona`:** Los teléfonos son vías de contacto dependientes de la persona (**RN.01**). Suprimida la persona, sus números pierden razón de ser y se eliminan en cascada.

#### B. Justificación de `NO ACTION / RESTRICT`

Se mantuvo en todas las tablas transaccionales, operativas y de herencia para garantizar consistencia y auditoría fiscal:

* **Transacciones de Venta, Pasaje y Pago:** Se bloquea el borrado de clientes, empleados o ventas que tengan registros vinculados (`FK_Venta_Cliente`, `FK_Venta_Empleado`, `FK_Pasaje_Venta`, `FK_Pago_Venta`). Evita la desaparición accidental de boletos nominativos (**RN.05**) o comprobantes de cobro (**RN.04**), preservando la trazabilidad (**RN.08**).
* **Jerarquía de Persona:** No se permite borrar a una `Persona` mientras esté activa como `Empleado`, `Cliente_comprador` o `Pasajero_Transportado`, protegiendo la unicidad exigida por **RN.01**.
* **Operación de Viajes y Rutas:** Impide eliminar rutas o terminales asignadas a viajes vigentes, protegiendo la estabilidad del servicio programado (**RN.06**).

#### C. Descarte de `SET NULL`

Se descartó `SET NULL` en todas las claves foráneas porque los campos foráneos fueron definidos como `NOT NULL`. Aceptar nulos violaría reglas de negocio críticas, como emitir un pasaje sin viaje ni pasajero (**RN.05**) o registrar una venta sin empleado responsable (**RN.08**).
