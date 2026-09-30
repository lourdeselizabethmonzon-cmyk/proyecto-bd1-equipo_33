-- Creación de la Base de Datos
CREATE DATABASE CorrientesPoraBus;
GO

USE CorrientesPoraBus;
GO

-- 1. Provincia
CREATE TABLE Provincia (
    Id_Provincia INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL UNIQUE
);

-- 2. Localidad
CREATE TABLE Localidad (
    Id_Localidad INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Id_Provincia INT NOT NULL,
    CONSTRAINT FK_Localidad_Provincia FOREIGN KEY (Id_Provincia) 
        REFERENCES Provincia(Id_Provincia)
);

-- 3. Terminal
CREATE TABLE Terminal (
    Id_Terminal INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Direccion VARCHAR(150) NOT NULL,
    Id_Localidad INT NOT NULL,
    CONSTRAINT FK_Terminal_Localidad FOREIGN KEY (Id_Localidad) 
        REFERENCES Localidad(Id_Localidad)
);

-- 4. Ruta
CREATE TABLE Ruta (
    Id_Ruta INT IDENTITY(1,1) PRIMARY KEY,
    Distancia DECIMAL(8,2) NOT NULL CHECK (Distancia > 0),
    Tiempo_Estimado TIME NOT NULL,
    Id_Terminal_Origen INT NOT NULL,
    Id_Terminal_Destino INT NOT NULL,
    CONSTRAINT FK_Ruta_TerminalOrigen FOREIGN KEY (Id_Terminal_Origen) 
        REFERENCES Terminal(Id_Terminal),
    CONSTRAINT FK_Ruta_TerminalDestino FOREIGN KEY (Id_Terminal_Destino) 
        REFERENCES Terminal(Id_Terminal),
    CONSTRAINT CHK_TerminalesDiferentes CHECK (Id_Terminal_Origen <> Id_Terminal_Destino)
);

-- 5. Colectivo
CREATE TABLE Colectivo (
    Patente VARCHAR(20) PRIMARY KEY,
    Marca VARCHAR(50) NOT NULL,
    Modelo VARCHAR(50) NOT NULL,
    Anio INT NOT NULL CHECK (Anio >= 2000)
);

-- 6. Butacas (Clave subrogada según informe 2FN)
CREATE TABLE Butacas (
    Id_Butaca INT IDENTITY(1,1) PRIMARY KEY,
    Nro_Butaca INT NOT NULL,
    Patente VARCHAR(20) NOT NULL,
    Ubicacion VARCHAR(20) NOT NULL CHECK (Ubicacion IN ('Pasillo', 'Ventanilla', 'Semi', 'Cama')),
    CONSTRAINT FK_Butacas_Colectivo FOREIGN KEY (Patente) 
        REFERENCES Colectivo(Patente) ON DELETE CASCADE
);

-- 7. Viaje
CREATE TABLE Viaje (
    Id_Viaje INT IDENTITY(1,1) PRIMARY KEY,
    Hora_Salida DATETIME NOT NULL,
    Precio_Base DECIMAL(10,2) NOT NULL CHECK (Precio_Base > 0),
    Patente VARCHAR(20) NOT NULL,
    Id_Ruta INT NOT NULL,
    CONSTRAINT FK_Viaje_Colectivo FOREIGN KEY (Patente) 
        REFERENCES Colectivo(Patente),
    CONSTRAINT FK_Viaje_Ruta FOREIGN KEY (Id_Ruta) 
        REFERENCES Ruta(Id_Ruta)
);

-- 8. Persona
CREATE TABLE Persona (
    Id_Persona INT IDENTITY(1,1) PRIMARY KEY,
    Nombre_1 VARCHAR(50) NOT NULL,
    Nombre_2 VARCHAR(50) NULL,
    Apellido_1 VARCHAR(50) NOT NULL,
    Apellido_2 VARCHAR(50) NULL,
    Tipo_Documento VARCHAR(10) NOT NULL CHECK (Tipo_Documento IN ('DNI', 'CUIT', 'Pasaporte')),
    Nro_Documento VARCHAR(20) NOT NULL UNIQUE,
    Fecha_Nacimiento DATE NOT NULL,
    e_mail VARCHAR(100) NOT NULL
);

-- 9. Telefono (Atributo multivaluado normalizado en 1FN)
CREATE TABLE Telefono (
    Id_Telefono INT IDENTITY(1,1) PRIMARY KEY,
    Tipo_de_Telefono VARCHAR(20) NOT NULL CHECK (Tipo_de_Telefono IN ('Celular', 'Fijo', 'Laboral')),
    Nro_Telefono VARCHAR(30) NOT NULL,
    Id_Persona INT NOT NULL,
    CONSTRAINT FK_Telefono_Persona FOREIGN KEY (Id_Persona) 
        REFERENCES Persona(Id_Persona) ON DELETE CASCADE
);

-- 10. Empleado (Especialización de Persona)
CREATE TABLE Empleado (
    Id_Persona INT PRIMARY KEY,
    Legajo VARCHAR(20) NOT NULL UNIQUE,
    Turno_Laboral VARCHAR(20) NOT NULL CHECK (Turno_Laboral IN ('Mañana', 'Tarde', 'Noche')),
    CONSTRAINT FK_Empleado_Persona FOREIGN KEY (Id_Persona) 
        REFERENCES Persona(Id_Persona)
);

-- 11. Cliente_comprador (Especialización de Persona)
CREATE TABLE Cliente_comprador (
    Id_Persona INT PRIMARY KEY,
    CONSTRAINT FK_Cliente_Persona FOREIGN KEY (Id_Persona) 
        REFERENCES Persona(Id_Persona)
);

-- 12. Pasajero_Transportado (Especialización de Persona)
CREATE TABLE Pasajero_Transportado (
    Id_Persona INT PRIMARY KEY,
    CONSTRAINT FK_Pasajero_Persona FOREIGN KEY (Id_Persona) 
        REFERENCES Persona(Id_Persona)
);

-- 13. Venta (Sin Monto_Total calculado según regla 3FN)
CREATE TABLE Venta (
    Id_Venta INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATETIME NOT NULL DEFAULT GETDATE(),
    Estado VARCHAR(20) NOT NULL CHECK (Estado IN ('Confirmada', 'Pendiente', 'Cancelada')),
    Id_Empleado INT NOT NULL,
    Id_Cliente INT NOT NULL,
    CONSTRAINT FK_Venta_Empleado FOREIGN KEY (Id_Empleado) 
        REFERENCES Empleado(Id_Persona),
    CONSTRAINT FK_Venta_Cliente FOREIGN KEY (Id_Cliente) 
        REFERENCES Cliente_comprador(Id_Persona)
);

-- 14. Pasaje (Sin duplicar Patente según regla 3FN)
CREATE TABLE Pasaje (
    Id_Pasaje INT IDENTITY(1,1) PRIMARY KEY,
    Precio_Unitario DECIMAL(10,2) NOT NULL CHECK (Precio_Unitario > 0),
    Id_Venta INT NOT NULL,
    Id_Viaje INT NOT NULL,
    Id_Butaca INT NOT NULL,
    Id_Pasajero INT NOT NULL,
    CONSTRAINT FK_Pasaje_Venta FOREIGN KEY (Id_Venta) 
        REFERENCES Venta(Id_Venta),
    CONSTRAINT FK_Pasaje_Viaje FOREIGN KEY (Id_Viaje) 
        REFERENCES Viaje(Id_Viaje),
    CONSTRAINT FK_Pasaje_Butaca FOREIGN KEY (Id_Butaca) 
        REFERENCES Butacas(Id_Butaca),
    CONSTRAINT FK_Pasaje_Pasajero FOREIGN KEY (Id_Pasajero) 
        REFERENCES Pasajero_Transportado(Id_Persona)
);

-- 15. Pago
CREATE TABLE Pago (
    Id_Pago INT IDENTITY(1,1) PRIMARY KEY,
    Metodo_Pago VARCHAR(30) NOT NULL CHECK (Metodo_Pago IN ('Efectivo', 'Tarjeta Debito', 'Tarjeta Credito', 'Transferencia')),
    Monto_a_Pagar DECIMAL(10,2) NOT NULL CHECK (Monto_a_Pagar > 0),
    Id_Venta INT NOT NULL,
    CONSTRAINT FK_Pago_Venta FOREIGN KEY (Id_Venta) 
        REFERENCES Venta(Id_Venta)
);
GO