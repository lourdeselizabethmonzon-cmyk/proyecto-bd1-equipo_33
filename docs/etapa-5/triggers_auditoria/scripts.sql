-- =========================================================================
-- ENTREGA: Triggers de Auditoría 
-- ARCHIVO: triggers_auditoria.sql
-- =========================================================================
USE CorrientesPoraBus;
GO
-- =========================================================================
-- 1. CREACIÓN DE TABLAS DE AUDITORÍA
-- =========================================================================
-- Tabla de Auditoría para Pasaje (Precio Unitario, Butaca y Borrados)
IF OBJECT_ID('Auditoria_Pasaje', 'U') IS NULL
BEGIN
    CREATE TABLE Auditoria_Pasaje (
        Id_Auditoria     INT IDENTITY(1,1) PRIMARY KEY,
        Id_Pasaje        INT NOT NULL,
        Campo_Modificado VARCHAR(50) NOT NULL,
        Valor_Anterior   VARCHAR(100) NULL,
        Valor_Nuevo      VARCHAR(100) NULL,
        Tipo_Operacion   VARCHAR(10) NOT NULL, -- 'UPDATE' o 'DELETE'
        Usuario          VARCHAR(128) NOT NULL,
        Terminal         VARCHAR(128) NOT NULL,
        Fecha            DATETIME NOT NULL DEFAULT GETDATE()
    );
END;
GO
-- Tabla de Auditoría para Venta (Cambios de estado, Cancelaciones y Borrados)
IF OBJECT_ID('Auditoria_Venta', 'U') IS NULL
BEGIN
    CREATE TABLE Auditoria_Venta (
        Id_Auditoria     INT IDENTITY(1,1) PRIMARY KEY,
        Id_Venta         INT NOT NULL,
        Estado_Anterior  VARCHAR(20) NULL,
        Estado_Nuevo     VARCHAR(20) NULL,
        Tipo_Operacion   VARCHAR(10) NOT NULL, -- 'UPDATE' o 'DELETE'
        Usuario          VARCHAR(128) NOT NULL,
        Terminal         VARCHAR(128) NOT NULL,
        Fecha            DATETIME NOT NULL DEFAULT GETDATE()
    );
END;
GO
-- Tabla de Auditoría para Viaje (Precio Base y Borrados)
IF OBJECT_ID('Auditoria_Viaje', 'U') IS NULL
BEGIN
    CREATE TABLE Auditoria_Viaje (
        Id_Auditoria     INT IDENTITY(1,1) PRIMARY KEY,
        Id_Viaje         INT NOT NULL,
        Precio_Anterior  DECIMAL(10,2) NULL,
        Precio_Nuevo     DECIMAL(10,2) NULL,
        Tipo_Operacion   VARCHAR(10) NOT NULL, -- 'UPDATE' o 'DELETE'
        Usuario          VARCHAR(128) NOT NULL,
        Terminal         VARCHAR(128) NOT NULL,
        Fecha            DATETIME NOT NULL DEFAULT GETDATE()
    );
END;
GO
-- =========================================================================
-- 2. DISPARADORES (TRIGGERS) DE AUDITORÍA
-- =========================================================================

-- Trigger 1: Auditoría sobre la tabla Pasaje
CREATE OR ALTER TRIGGER TRG_Auditoria_Pasaje
ON Pasaje
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Caso UPDATE: Modificación de Precio o Butaca
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        -- Auditoría de Precio_Unitario
        INSERT INTO Auditoria_Pasaje (Id_Pasaje, Campo_Modificado, Valor_Anterior, Valor_Nuevo, Tipo_Operacion, Usuario, Terminal, Fecha)
        SELECT 
            i.Id_Pasaje,
            'Precio_Unitario',
            CAST(d.Precio_Unitario AS VARCHAR(100)),
            CAST(i.Precio_Unitario AS VARCHAR(100)),
            'UPDATE',
            SYSTEM_USER,
            HOST_NAME(),
            GETDATE()
        FROM inserted i
        INNER JOIN deleted d ON i.Id_Pasaje = d.Id_Pasaje
        WHERE i.Precio_Unitario <> d.Precio_Unitario;

        -- Auditoría de Id_Butaca
        INSERT INTO Auditoria_Pasaje (Id_Pasaje, Campo_Modificado, Valor_Anterior, Valor_Nuevo, Tipo_Operacion, Usuario, Terminal, Fecha)
        SELECT 
            i.Id_Pasaje,
            'Id_Butaca',
            CAST(d.Id_Butaca AS VARCHAR(100)),
            CAST(i.Id_Butaca AS VARCHAR(100)),
            'UPDATE',
            SYSTEM_USER,
            HOST_NAME(),
            GETDATE()
        FROM inserted i
        INNER JOIN deleted d ON i.Id_Pasaje = d.Id_Pasaje
        WHERE i.Id_Butaca <> d.Id_Butaca;
    END;

    -- Caso DELETE: Borrado físico del pasaje
    IF NOT EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO Auditoria_Pasaje (Id_Pasaje, Campo_Modificado, Valor_Anterior, Valor_Nuevo, Tipo_Operacion, Usuario, Terminal, Fecha)
        SELECT 
            d.Id_Pasaje,
            'REGISTRO_COMPLETO',
            CONCAT('Venta:', d.Id_Venta, ' | Butaca:', d.Id_Butaca, ' | Precio:', d.Precio_Unitario),
            NULL,
            'DELETE',
            SYSTEM_USER,
            HOST_NAME(),
            GETDATE()
        FROM deleted d;
    END;
END;
GO

-- Trigger 2: Auditoría sobre la tabla Venta
CREATE OR ALTER TRIGGER TRG_Auditoria_Venta
ON Venta
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Caso UPDATE: Transición de estados (ej. Confirmada -> Cancelada)
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO Auditoria_Venta (Id_Venta, Estado_Anterior, Estado_Nuevo, Tipo_Operacion, Usuario, Terminal, Fecha)
        SELECT 
            i.Id_Venta,
            d.Estado,
            i.Estado,
            'UPDATE',
            SYSTEM_USER,
            HOST_NAME(),
            GETDATE()
        FROM inserted i
        INNER JOIN deleted d ON i.Id_Venta = d.Id_Venta
        WHERE i.Estado <> d.Estado;
    END;

    -- Caso DELETE: Eliminación física de venta
    IF NOT EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO Auditoria_Venta (Id_Venta, Estado_Anterior, Estado_Nuevo, Tipo_Operacion, Usuario, Terminal, Fecha)
        SELECT 
            d.Id_Venta,
            d.Estado,
            NULL,
            'DELETE',
            SYSTEM_USER,
            HOST_NAME(),
            GETDATE()
        FROM deleted d;
    END;
END;
GO

-- Trigger 3: Auditoría sobre la tabla Viaje
CREATE OR ALTER TRIGGER TRG_Auditoria_Viaje
ON Viaje
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Caso UPDATE: Modificación de Precio_Base
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO Auditoria_Viaje (Id_Viaje, Precio_Anterior, Precio_Nuevo, Tipo_Operacion, Usuario, Terminal, Fecha)
        SELECT 
            i.Id_Viaje,
            d.Precio_Base,
            i.Precio_Base,
            'UPDATE',
            SYSTEM_USER,
            HOST_NAME(),
            GETDATE()
        FROM inserted i
        INNER JOIN deleted d ON i.Id_Viaje = d.Id_Viaje
        WHERE i.Precio_Base <> d.Precio_Base;
    END;

    -- Caso DELETE: Eliminación física de Viaje
    IF NOT EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO Auditoria_Viaje (Id_Viaje, Precio_Anterior, Precio_Nuevo, Tipo_Operacion, Usuario, Terminal, Fecha)
        SELECT 
            d.Id_Viaje,
            d.Precio_Base,
            NULL,
            'DELETE',
            SYSTEM_USER,
            HOST_NAME(),
            GETDATE()
        FROM deleted d;
    END;
END;
GO

