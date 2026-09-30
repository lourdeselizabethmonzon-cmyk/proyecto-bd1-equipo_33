
## Parte Implementación

###  Mapeo Lógico a Físico: Del Diagrama Relacional a SQL

El pasaje del modelo lógico normalizado (diagrama relacional) al esquema físico en el SGBD se ejecutó a través de las siguientes etapas conceptuales y técnicas:

#### Creación de Tablas y Jerarquías de Entidades
- **Entidades Fuertes e Independientes:** Las entidades maestras base del diagrama (`Provincia`, `Colectivo`, `Persona`) no dependen de claves foráneas iniciales. Se crearon primero utilizando la instrucción DDL estándar `CREATE TABLE` para disponer de las tablas referenciadas antes de declarar relaciones dependientes.
- **Entidades Débiles y Jerarquía de Especialización:** 
  - La entidad `Telefono` se implementó como entidad débil vinculada directamente a `Persona` mediante clave foránea, asignando eliminación en cascada (`ON DELETE CASCADE`) para suprimir números vinculados si la persona asociada es dada de baja.
  - La especialización/generalización de la entidad `Persona` (`Empleado`, `Cliente_comprador` y `Pasajero_Transportado`) se implementó mediante la estrategia de tablas hijas con clave primaria compartida: el atributo `Id_Persona` actúa simultáneamente como `PRIMARY KEY` y como `FOREIGN KEY` hacia la tabla padre `Persona`. Esto garantiza que cada subtipo preserve su identidad sin duplicar atributos personales (como nombres, tipo y número de documento).
- **Tablas Transaccionales y de Relación:** Las transacciones operativas del diagrama se desagregaron en tablas con claves foráneas múltiples: `Viaje` (conecta colectivo con ruta), `Venta` (vincula al cliente comprador con el empleado vendedor) y `Pasaje` (actúa como el detalle transaccional de la venta conectando viaje, butaca, pasajero transportado y venta).

#### Definición de Columnas, Tipos de Datos y Dominios
Cada atributo del diagrama se tradujo a un tipo de dato nativo de T-SQL para restringir el dominio físico de almacenamiento:
- **Identificadores Subrogados:** Se utilizó `INT IDENTITY(1,1)` en identificadores autonuméricos (`Id_Provincia`, `Id_Localidad`, `Id_Ruta`, `Id_Viaje`, `Id_Venta`, etc.) para garantizar claves primarias artificiales estables y de bajo costo de almacenamiento (4 bytes).
- **Claves Naturales:** Para la tabla `Colectivo`, se asignó la `Patente` como identificador primario natural utilizando `VARCHAR(20)`.
- **Cadenas de Texto de Longitud Variable:** Se utilizó `VARCHAR(n)` ajustado a los requerimientos de almacenamiento del negocio (ej. `VARCHAR(50)` para nombres y apellidos, `VARCHAR(100)` para correos electrónicos y nombres de terminales) en lugar de cadenas de longitud fija para optimizar espacio.
- **Numéricos de Precisión Fija:** Las columnas monetarias (`Precio_Unitario` en pasajes y `Monto_a_Pagar` en pagos) y de distancia (`Distancia` en kilómetros dentro de `Ruta`) se definieron con el tipo exacto `DECIMAL(p,s)` (`DECIMAL(10,2)` y `DECIMAL(7,2)`) para prevenir pérdidas de precisión por redondeo flotante.
- **Atributos Temporales:** Se utilizaron tipos específicos según la necesidad funcional: `DATE` para fechas cronológicas puras (`Fecha_Nacimiento`, fecha del `Viaje`), `TIME` para registrar horas (`Hora_Salida`, `Tiempo_Estimado`) y `DATETIME` con función predeterminada `DEFAULT GETDATE()` para registrar con precisión de fecha y hora el momento exacto de emisión de cada transacción en `Venta`.

#### Formalización de Relaciones y Restricciones de Integridad
Para trasladar las reglas del modelo lógico a nivel de motor se formalizaron las siguientes restricciones relacionales:
- **Integridad de Entidad (PK):** Definición explícita de `CONSTRAINT PK_... PRIMARY KEY` sobre todas las tablas.
- **Integridad Referencial (FK):** Establecimiento de vínculos formales `FOREIGN KEY ... REFERENCES ...` controlando el orden de dependencias para evitar registros huérfanos. En relaciones subordinadas dependientes de existencia (como `Telefono` y `Butacas`), se especificó `ON DELETE CASCADE` para mantener la sincronización estructural con su entidad contenedora.
- **Unicidad Alternativa (UNIQUE):** Restricciones `CONSTRAINT UQ_... UNIQUE` para evitar duplicados en combinaciones críticas de negocio: nombres de provincia únicos, documento por persona (`Tipo_Documento`, `Nro_Documento`), legajo laboral de empleado único, y la regla que impide asignar dos veces la misma butaca en un mismo viaje (`UQ_Pasaje_Viaje_Butaca`).
- **Integridad de Dominio (CHECK):** Restricciones lógicas mediante `CONSTRAINT CHK_... CHECK` para validar condiciones booleanas: valores monetarios estrictamente mayores a cero (`Distancia > 0`, `Precio_Unitario > 0`, `Monto_a_Pagar > 0`), validación de listas cerradas de valores para estados y tipos (`Tipo_Documento IN ('DNI', 'CUIT', 'Pasaporte')`, `Metodo_Pago`, `Turno_Laboral`, `Ubicacion`), y verificación de consistencia topológica en rutas (`Id_Terminal_Origen <> Id_Terminal_Destino`).

#### Orden Lógico de Creación de Objetos
Para permitir la compilación limpia del script sin errores de dependencias referenciales cruzadas, se estableció la siguiente secuencia jerárquica de creación:
1. `Provincia`
2. `Localidad` (depende de `Provincia`)
3. `Terminal` (depende de `Localidad`)
4. `Ruta` (depende de dos instancias de `Terminal`)
5. `Colectivo`
6. `Butacas` (depende de `Colectivo`)
7. `Viaje` (depende de `Colectivo` y `Ruta`)
8. `Persona`
9. `Telefono` (depende de `Persona`)
10. `Empleado`, `Cliente_comprador`, `Pasajero_Transportado` (dependen de `Persona`)
11. `Venta` (depende de `Empleado` y `Cliente_comprador`)
12. `Pasaje` (depende de `Venta`, `Viaje`, `Butacas` y `Pasajero_Transportado`)
13. `Pago` (depende de `Venta`)

---

### Código DDL de Implementación

El script completo de creación de la base de datos y sus tablas se encuentra versionado en la ruta relativa `sql/ddl/crear_bd.sql`. A continuación se transcribe el bloque de sentencias ejecutadas:

```sql
-- 1. PROVINCIA
CREATE TABLE Provincia (
    Id_Provincia INT IDENTITY(1,1) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Provincia PRIMARY KEY (Id_Provincia),
    CONSTRAINT UQ_Provincia_Nombre UNIQUE (Nombre)
);
GO

-- 2. LOCALIDAD
CREATE TABLE Localidad (
    Id_Localidad INT IDENTITY(1,1) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Id_Provincia INT NOT NULL,
    CONSTRAINT PK_Localidad PRIMARY KEY (Id_Localidad),
    CONSTRAINT FK_Localidad_Provincia FOREIGN KEY (Id_Provincia) 
        REFERENCES Provincia(Id_Provincia)
);
GO

-- 3. TERMINAL
CREATE TABLE Terminal (
    Id_Terminal INT IDENTITY(1,1) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Id_Localidad INT NOT NULL,
    CONSTRAINT PK_Terminal PRIMARY KEY (Id_Terminal),
    CONSTRAINT FK_Terminal_Localidad FOREIGN KEY (Id_Localidad) 
        REFERENCES Localidad(Id_Localidad)
);
GO

-- 4. RUTA
CREATE TABLE Ruta (
    Id_Ruta INT IDENTITY(1,1) NOT NULL,
    Distancia DECIMAL(7,2) NOT NULL,
    Tiempo_Estimado TIME NOT NULL,
    Id_Terminal_Origen INT NOT NULL,
    Id_Terminal_Destino INT NOT NULL,
    CONSTRAINT PK_Ruta PRIMARY KEY (Id_Ruta),
    CONSTRAINT FK_Ruta_TerminalOrigen FOREIGN KEY (Id_Terminal_Origen) 
        REFERENCES Terminal(Id_Terminal),
    CONSTRAINT FK_Ruta_TerminalDestino FOREIGN KEY (Id_Terminal_Destino) 
        REFERENCES Terminal(Id_Terminal),
    CONSTRAINT CHK_Ruta_Distancia CHECK (Distancia > 0),
    CONSTRAINT CHK_TerminalesDiferentes CHECK (Id_Terminal_Origen <> Id_Terminal_Destino)
);
GO

-- 5. COLECTIVO
CREATE TABLE Colectivo (
    Patente VARCHAR(20) NOT NULL,
    Marca VARCHAR(50) NOT NULL,
    Modelo VARCHAR(50) NOT NULL,
    Anio INT NOT NULL,
    CONSTRAINT PK_Colectivo PRIMARY KEY (Patente),
    CONSTRAINT CHK_Colectivo_Anio CHECK (Anio >= 2000)
);
GO

-- 6. BUTACAS
CREATE TABLE Butacas (
    Id_Butaca INT IDENTITY(1,1) NOT NULL,
    Nro_Butaca INT NOT NULL,
    Patente VARCHAR(20) NOT NULL,
    Ubicacion VARCHAR(20) NOT NULL,
    Tipo_Servicio VARCHAR(30) NOT NULL,
    CONSTRAINT PK_Butacas PRIMARY KEY (Id_Butaca),
    CONSTRAINT FK_Butacas_Colectivo FOREIGN KEY (Patente) 
        REFERENCES Colectivo(Patente) ON DELETE CASCADE,
    CONSTRAINT UQ_Butaca_Por_Colectivo UNIQUE (Patente, Nro_Butaca),
    CONSTRAINT CHK_Butaca_Numero CHECK (Nro_Butaca > 0),
    CONSTRAINT CHK_Butaca_Ubicacion CHECK (Ubicacion IN ('Pasillo', 'Ventanilla')),
    CONSTRAINT CHK_Butaca_Servicio CHECK (Tipo_Servicio IN ('Semicama', 'Cama Ejecutivo', 'Suite Cama'))
);
GO

-- 7. VIAJE
CREATE TABLE Viaje (
    Id_Viaje INT IDENTITY(1,1) NOT NULL,
    Fecha DATE NOT NULL,
    Hora_Salida TIME NOT NULL,
    Patente VARCHAR(20) NOT NULL,
    Id_Ruta INT NOT NULL,
    CONSTRAINT PK_Viaje PRIMARY KEY (Id_Viaje),
    CONSTRAINT FK_Viaje_Colectivo FOREIGN KEY (Patente) 
        REFERENCES Colectivo(Patente),
    CONSTRAINT FK_Viaje_Ruta FOREIGN KEY (Id_Ruta) 
        REFERENCES Ruta(Id_Ruta)
);
GO

-- 8. PERSONA
CREATE TABLE Persona (
    Id_Persona INT IDENTITY(1,1) NOT NULL,
    Nombre_1 VARCHAR(50) NOT NULL,
    Nombre_2 VARCHAR(50) NULL,
    Apellido_1 VARCHAR(50) NOT NULL,
    Apellido_2 VARCHAR(50) NULL,
    Tipo_Documento VARCHAR(10) NOT NULL,
    Nro_Documento VARCHAR(20) NOT NULL,
    Fecha_Nacimiento DATE NOT NULL,
    e_mail VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Persona PRIMARY KEY (Id_Persona),
    CONSTRAINT UQ_Persona_Documento UNIQUE (Tipo_Documento, Nro_Documento),
    CONSTRAINT CHK_Persona_TipoDoc CHECK (Tipo_Documento IN ('DNI', 'CUIT', 'Pasaporte'))
);
GO

-- 9. TELEFONO
CREATE TABLE Telefono (
    Id_Telefono INT IDENTITY(1,1) NOT NULL,
    Tipo_de_Telefono VARCHAR(20) NOT NULL,
    Nro_Telefono VARCHAR(30) NOT NULL,
    Id_Persona INT NOT NULL,
    CONSTRAINT PK_Telefono PRIMARY KEY (Id_Telefono),
    CONSTRAINT FK_Telefono_Persona FOREIGN KEY (Id_Persona) 
        REFERENCES Persona(Id_Persona) ON DELETE CASCADE,
    CONSTRAINT CHK_Telefono_Tipo CHECK (Tipo_de_Telefono IN ('Celular', 'Fijo', 'Laboral'))
);
GO

-- 10. EMPLEADO
CREATE TABLE Empleado (
    Id_Persona INT NOT NULL,
    Legajo VARCHAR(20) NOT NULL,
    Turno_Laboral VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Empleado PRIMARY KEY (Id_Persona),
    CONSTRAINT FK_Empleado_Persona FOREIGN KEY (Id_Persona) 
        REFERENCES Persona(Id_Persona),
    CONSTRAINT UQ_Empleado_Legajo UNIQUE (Legajo),
    CONSTRAINT CHK_Empleado_Turno CHECK (Turno_Laboral IN ('Mañana', 'Tarde', 'Noche'))
);
GO

-- 11. CLIENTE_COMPRADOR
CREATE TABLE Cliente_comprador (
    Id_Persona INT NOT NULL,
    CONSTRAINT PK_Cliente_comprador PRIMARY KEY (Id_Persona),
    CONSTRAINT FK_Cliente_Persona FOREIGN KEY (Id_Persona) 
        REFERENCES Persona(Id_Persona)
);
GO

-- 12. PASAJERO_TRANSPORTADO
CREATE TABLE Pasajero_Transportado (
    Id_Persona INT NOT NULL,
    CONSTRAINT PK_Pasajero_Transportado PRIMARY KEY (Id_Persona),
    CONSTRAINT FK_Pasajero_Persona FOREIGN KEY (Id_Persona) 
        REFERENCES Persona(Id_Persona)
);
GO

-- 13. VENTA
CREATE TABLE Venta (
    Id_Venta INT IDENTITY(1,1) NOT NULL,
    Fecha DATETIME NOT NULL DEFAULT GETDATE(),
    Estado VARCHAR(20) NOT NULL,
    Id_Empleado INT NOT NULL,
    Id_Cliente INT NOT NULL,
    CONSTRAINT PK_Venta PRIMARY KEY (Id_Venta),
    CONSTRAINT FK_Venta_Empleado FOREIGN KEY (Id_Empleado) 
        REFERENCES Empleado(Id_Persona),
    CONSTRAINT FK_Venta_Cliente FOREIGN KEY (Id_Cliente) 
        REFERENCES Cliente_comprador(Id_Persona),
    CONSTRAINT CHK_Venta_Estado CHECK (Estado IN ('Confirmada', 'Pendiente', 'Cancelada'))
);
GO

-- 14. PASAJE
CREATE TABLE Pasaje (
    Id_Pasaje INT IDENTITY(1,1) NOT NULL,
    Precio_Unitario DECIMAL(10,2) NOT NULL,
    Id_Venta INT NOT NULL,
    Id_Viaje INT NOT NULL,
    Id_Butaca INT NOT NULL,
    Id_Pasajero INT NOT NULL,
    CONSTRAINT PK_Pasaje PRIMARY KEY (Id_Pasaje),
    CONSTRAINT FK_Pasaje_Venta FOREIGN KEY (Id_Venta) 
        REFERENCES Venta(Id_Venta),
    CONSTRAINT FK_Pasaje_Viaje FOREIGN KEY (Id_Viaje) 
        REFERENCES Viaje(Id_Viaje),
    CONSTRAINT FK_Pasaje_Butaca FOREIGN KEY (Id_Butaca) 
        REFERENCES Butacas(Id_Butaca),
    CONSTRAINT FK_Pasaje_Pasajero FOREIGN KEY (Id_Pasajero) 
        REFERENCES Pasajero_Transportado(Id_Persona),
    CONSTRAINT UQ_Pasaje_Viaje_Butaca UNIQUE (Id_Viaje, Id_Butaca),
    CONSTRAINT CHK_Pasaje_Precio CHECK (Precio_Unitario > 0)
);
GO

-- 15. PAGO
CREATE TABLE Pago (
    Id_Pago INT IDENTITY(1,1) NOT NULL,
    Metodo_Pago VARCHAR(30) NOT NULL,
    Monto_a_Pagar DECIMAL(10,2) NOT NULL,
    Id_Venta INT NOT NULL,
    CONSTRAINT PK_Pago PRIMARY KEY (Id_Pago),
    CONSTRAINT FK_Pago_Venta FOREIGN KEY (Id_Venta) 
        REFERENCES Venta(Id_Venta),
    CONSTRAINT CHK_Pago_Metodo CHECK (Metodo_Pago IN ('Efectivo', 'Tarjeta Debito', 'Tarjeta Credito', 'Transferencia')),
    CONSTRAINT CHK_Pago_Monto CHECK (Monto_a_Pagar > 0)
);
GO