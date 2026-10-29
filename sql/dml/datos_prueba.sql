USE CorrientesPoraBus;
GO

-- =============================================================================
-- 1. LIMPIEZA PREVENTIVA Y REINICIO DE CONTADORES IDENTITY
-- =============================================================================
DELETE FROM Pasaje;
DELETE FROM Pago;
DELETE FROM Venta;
DELETE FROM Pasajero_Transportado;
DELETE FROM Cliente_comprador;
DELETE FROM Empleado;
DELETE FROM Telefono;
DELETE FROM Persona;
DELETE FROM Viaje;
DELETE FROM Butacas;
DELETE FROM Colectivo;
DELETE FROM Ruta;
DELETE FROM Terminal;
DELETE FROM Localidad;
DELETE FROM Provincia;

IF OBJECT_ID('Auditoria_Venta', 'U') IS NOT NULL DELETE FROM Auditoria_Venta;
IF OBJECT_ID('Auditoria_Viaje', 'U') IS NOT NULL DELETE FROM Auditoria_Viaje;
GO

DBCC CHECKIDENT ('Provincia', RESEED, 0);
DBCC CHECKIDENT ('Localidad', RESEED, 0);
DBCC CHECKIDENT ('Terminal', RESEED, 0);
DBCC CHECKIDENT ('Ruta', RESEED, 0);
DBCC CHECKIDENT ('Butacas', RESEED, 0);
DBCC CHECKIDENT ('Viaje', RESEED, 0);
DBCC CHECKIDENT ('Persona', RESEED, 0);
DBCC CHECKIDENT ('Telefono', RESEED, 0);
DBCC CHECKIDENT ('Venta', RESEED, 0);
DBCC CHECKIDENT ('Pago', RESEED, 0);
DBCC CHECKIDENT ('Pasaje', RESEED, 0);

IF OBJECT_ID('Auditoria_Venta', 'U') IS NOT NULL DBCC CHECKIDENT ('Auditoria_Venta', RESEED, 0);
IF OBJECT_ID('Auditoria_Viaje', 'U') IS NOT NULL DBCC CHECKIDENT ('Auditoria_Viaje', RESEED, 0);
GO

-- =============================================================================
-- 2. INSERCIÓN DE DATOS
-- =============================================================================

-- A. Provincia
INSERT INTO Provincia (Nombre) VALUES
('Corrientes'), ('Chaco'), ('Misiones'), ('Formosa'), ('Entre Ríos'),
('Santa Fe'), ('Córdoba'), ('Buenos Aires'), ('Salta'), ('Tucumán');

-- B. Localidad
INSERT INTO Localidad (Nombre, Id_Provincia) VALUES
('Corrientes Capital', 1), ('Bella Vista', 1), ('Goya', 1), ('Resistencia', 2),
('Formosa Capital', 4), ('Paraná', 5), ('Rosario', 6), ('Córdoba Capital', 7),
('La Plata', 8), ('Salta Capital', 9);

-- C. Terminal
INSERT INTO Terminal (Nombre, Direccion, Id_Localidad) VALUES
('Terminal Corrientes', 'Av. Maipú 2500', 1), 
('Terminal Bella Vista', 'San Martín 450', 2), 
('Terminal Goya', 'España 120', 3),
('Terminal Resistencia', 'Av. 9 de Julio 1500', 4), 
('Terminal Formosa', '25 de Mayo 800', 5), 
('Terminal Paraná', 'Ramírez 2300', 6),
('Terminal Rosario', 'Cafferata 702', 7), 
('Terminal Córdoba', 'Bv. Perón 380', 8), 
('Terminal La Plata', 'Calle 42 3', 9), 
('Terminal Salta', 'Av. Hipólito Yrigoyen 339', 10);

-- D. Ruta
INSERT INTO Ruta (Distancia, Tiempo_Estimado, Id_Terminal_Origen, Id_Terminal_Destino) VALUES
(120.50, '02:00:00', 2, 1),
(230.00, '03:30:00', 3, 1),
(15.00, '00:30:00', 1, 4),
(300.00, '04:30:00', 1, 5),
(450.00, '06:00:00', 1, 6),
(500.00, '07:00:00', 1, 7),
(700.00, '09:00:00', 1, 8),
(950.00, '11:00:00', 1, 9),
(1100.00, '13:00:00', 1, 10),
(80.00, '01:30:00', 2, 3);

-- E. Colectivo
INSERT INTO Colectivo (Patente, Marca, Modelo, Anio) VALUES
('AA123BB', 'Mercedes-Benz', 'Travego', 2021),
('AB456CC', 'Marcopolo', 'Paradiso', 2022),
('AC789DD', 'Scania', 'K440', 2020),
('AD012EE', 'Volkswagen', 'Comet', 2023),
('AE345FF', 'Mercedes-Benz', 'O500', 2021),
('AF678GG', 'Marcopolo', 'G7', 2022),
('AG901HH', 'Scania', 'Touring', 2023),
('AH234II', 'Mercedes-Benz', 'Sprinter', 2021),
('AI567JJ', 'Iveco', 'Daily', 2020),
('AJ890KK', 'Volkswagen', 'Volus', 2022);

-- F. Butacas
INSERT INTO Butacas (Nro_Butaca, Patente, Ubicacion) VALUES
(1, 'AA123BB', 'Ventanilla'), (2, 'AA123BB', 'Pasillo'),
(3, 'AB456CC', 'Ventanilla'), (4, 'AB456CC', 'Pasillo'),
(5, 'AC789DD', 'Pasillo'),    (6, 'AC789DD', 'Ventanilla'),
(7, 'AD012EE', 'Ventanilla'), (8, 'AD012EE', 'Pasillo'),
(9, 'AE345FF', 'Pasillo'),    (10, 'AE345FF', 'Ventanilla');

-- G. Viaje
INSERT INTO Viaje (Hora_Salida, Precio_Base, Patente, Id_Ruta) VALUES
('2026-10-01 08:00:00', 15000.00, 'AA123BB', 1),
('2026-10-01 10:30:00', 18500.00, 'AB456CC', 2),
('2026-10-01 14:00:00', 5000.00,  'AC789DD', 3),
('2026-10-01 16:15:00', 21000.00, 'AD012EE', 4),
('2026-10-01 19:00:00', 25000.00, 'AE345FF', 5),
('2026-10-01 21:30:00', 28000.00, 'AF678GG', 6),
('2026-10-02 06:00:00', 35000.00, 'AG901HH', 7),
('2026-10-02 09:00:00', 42000.00, 'AH234II', 8),
('2026-10-02 12:00:00', 12000.00, 'AI567JJ', 9),
('2026-10-02 15:00:00', 9500.00,  'AJ890KK', 10);

-- H. Persona
INSERT INTO Persona (Nombre_1, Nombre_2, Apellido_1, Apellido_2, Tipo_Documento, Nro_Documento, Fecha_Nacimiento, e_mail) VALUES
('Juan', 'Carlos', 'Pérez', 'Gómez', 'DNI', '40111222', '1995-03-12', 'juan.perez@email.com'),
('María', 'Elena', 'Gómez', 'Benítez', 'DNI', '38222333', '1992-07-25', 'maria.gomez@email.com'),
('Carlos', NULL, 'Rodríguez', 'Sosa', 'DNI', '35333444', '1988-11-05', 'carlos.rodriguez@email.com'),
('Ana', 'Sofía', 'López', 'Martínez', 'DNI', '42444555', '2000-01-19', 'ana.lopez@email.com'),
('Luis', 'Alberto', 'Martínez', 'Ríos', 'DNI', '31555666', '1985-09-30', 'luis.martinez@email.com'),
('Carla', NULL, 'Fernández', 'Acosta', 'DNI', '39666777', '1997-04-14', 'carla.fernandez@email.com'),
('Diego', 'Armando', 'Benítez', 'Ledesma', 'DNI', '33777888', '1990-12-03', 'diego.benitez@email.com'),
('Lucía', NULL, 'González', 'Vera', 'DNI', '44888999', '2002-06-21', 'lucia.gonzalez@email.com'),
('Mateo', 'Javier', 'Silva', 'Romero', 'DNI', '37999000', '1994-08-17', 'mateo.silva@email.com'),
('Valeria', NULL, 'Ríos', 'Ortíz', 'DNI', '41000111', '1998-02-08', 'valeria.rios@email.com');

-- I. Telefono
INSERT INTO Telefono (Tipo_de_Telefono, Nro_Telefono, Id_Persona) VALUES
('Celular', '3794123456', 1),
('Laboral', '3794654321', 1),
('Celular', '3794987654', 2),
('Fijo', '3794223344', 3),
('Celular', '3794556677', 4);

-- J. Empleado
INSERT INTO Empleado (Id_Persona, Legajo, Turno_Laboral) VALUES
(1, 'LEG-1001', 'Mañana'),
(2, 'LEG-1002', 'Tarde'),
(3, 'LEG-1003', 'Noche');

-- K. Cliente_comprador
INSERT INTO Cliente_comprador (Id_Persona) VALUES
(4), (5), (6);

-- L. Pasajero_Transportado
INSERT INTO Pasajero_Transportado (Id_Persona) VALUES
(7), (8), (9), (10);

-- M. Venta
INSERT INTO Venta (Fecha, Estado, Id_Empleado, Id_Cliente) VALUES
('2026-09-28 10:00:00', 'Confirmada', 1, 4),
('2026-09-28 11:30:00', 'Confirmada', 1, 5),
('2026-09-29 14:00:00', 'Confirmada', 2, 6),
('2026-09-29 15:20:00', 'Pendiente', 2, 4),
('2026-09-30 09:10:00', 'Confirmada', 3, 5);

-- N. Pago
INSERT INTO Pago (Metodo_Pago, Monto_a_Pagar, Id_Venta) VALUES
('Transferencia', 15000.00, 1),
('Tarjeta Debito', 18500.00, 2),
('Efectivo', 5000.00, 3),
('Tarjeta Credito', 21000.00, 4),
('Transferencia', 25000.00, 5);

-- O. Pasaje
INSERT INTO Pasaje (Precio_Unitario, Id_Venta, Id_Viaje, Id_Butaca, Id_Pasajero) VALUES
(15000.00, 1, 1, 1, 7),
(18500.00, 2, 2, 3, 8),
(5000.00, 3, 3, 5, 9),
(21000.00, 4, 4, 7, 10),
(25000.00, 5, 5, 9, 7);
GO
