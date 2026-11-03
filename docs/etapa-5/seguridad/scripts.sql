USE CorrientesPoraBus;
GO

-- =========================================================================
-- PARTE 1: PERMISOS A NIVEL DE USUARIOS Y PROCEDIMIENTOS ALMACENADOS
-- =========================================================================

-- 1. Creación de Inicios de Sesión (Logins)
CREATE LOGIN usuario_admin WITH PASSWORD = 'Admin123*';
CREATE LOGIN usuario_lector WITH PASSWORD = 'Lector123*';
GO

-- 2. Creación de Usuarios en la Base de Datos
CREATE USER usuario_admin FOR LOGIN usuario_admin;
CREATE USER usuario_lector FOR LOGIN usuario_lector;
GO

-- 3. Asignación del Administrador al rol propietario
ALTER ROLE db_owner ADD MEMBER usuario_admin;
GO

-- 4. Asignación de Permisos al Usuario Lector
GRANT SELECT ON dbo.Venta TO usuario_lector;
GRANT EXECUTE ON dbo.sp_RegistrarVentaSimple TO usuario_lector;
GO

-- =========================================================================
-- PARTE 2: PERMISOS A NIVEL DE ROLES FUNCIONALES
-- =========================================================================

-- 1. Creación de Logins y Usuarios para Pruebas de Rol
CREATE LOGIN usuario_con_rol WITH PASSWORD = 'Rol123*';
CREATE LOGIN usuario_sin_rol WITH PASSWORD = 'Rol456*';
GO

CREATE USER usuario_con_rol FOR LOGIN usuario_con_rol;
CREATE USER usuario_sin_rol FOR LOGIN usuario_sin_rol;
GO

-- 2. Creación del Rol Personalizado
CREATE ROLE rol_consulta_rutas;
GO

-- 3. Asignación de Permisos de Lectura al Rol
GRANT SELECT ON dbo.Ruta TO rol_consulta_rutas;
GO

-- 4. Asignación de Usuario al Rol
ALTER ROLE rol_consulta_rutas ADD MEMBER usuario_con_rol;
GO
