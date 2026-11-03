\# Tema Técnico: Seguridad (Manejo de permisos a nivel de usuarios y roles)



\## 1. Definición y objetivo

La seguridad en una base de datos permite controlar qué usuarios pueden acceder a la información y qué operaciones pueden realizar. SQL Server permite administrar permisos de manera individual (usuarios) o agrupándolos mediante roles, facilitando la protección de la información y aplicando el principio de mínimo privilegio.



\## 2. Ventajas y aplicaciones

\* Protegen la información sensible del sistema.

\* Evitan modificaciones accidentales o no autorizadas.

\* Permiten asignar responsabilidades según el perfil del usuario.

\* Simplifican la administración de accesos mediante roles reutilizables.

\* Mejoran la seguridad y mantenibilidad de la base de datos.



\## 3 y 4. Implementación y Caso Concreto (Corrientes Porá Bus)

Para adaptar la seguridad a nuestro dominio de venta de pasajes de larga distancia, demostraremos dos escenarios:

1\. \*\*Permisos a nivel de usuarios:\*\* Se creará un `usuario\_lector` (simulando un boletero) que no podrá insertar datos directamente en la tabla `Venta`, pero sí estará autorizado a registrarla indirectamente mediante el procedimiento almacenado `sp\_RegistrarVentaSimple`.

2\. \*\*Permisos a nivel de roles:\*\* Se creará un rol `rol\_consulta\_rutas` para agrupar permisos de lectura sobre la tabla `Ruta`. Demostraremos cómo un `usuario\_con\_rol` accede a los datos sin problemas, mientras que un `usuario\_sin\_rol` es bloqueado por el motor.



\## 5. Script de demostración y resultados obtenidos



```sql

USE CorrientesPoraBus;

GO



\-- =========================================================================

\-- PARTE 1: PERMISOS A NIVEL DE USUARIOS

\-- =========================================================================



\-- 1. Creación de inicios de sesión y usuarios

CREATE LOGIN usuario\_admin WITH PASSWORD = 'Admin123\*';

CREATE LOGIN usuario\_lector WITH PASSWORD = 'Lector123\*';

GO



CREATE USER usuario\_admin FOR LOGIN usuario\_admin;

CREATE USER usuario\_lector FOR LOGIN usuario\_lector;

GO



\-- 2. Asignación de permisos

\-- Usuario administrador: Se agrega al rol db\_owner

ALTER ROLE db\_owner ADD MEMBER usuario\_admin;

GO



\-- Usuario lector: Permiso de lectura en tabla y ejecución de SP

GRANT SELECT ON dbo.Venta TO usuario\_lector;

GRANT EXECUTE ON dbo.sp\_RegistrarVentaSimple TO usuario\_lector;

GO



\-- 3. Pruebas de comportamiento



\-- Prueba A: INSERT directo sobre Venta con admin

EXECUTE AS USER = 'usuario\_admin';

INSERT INTO Venta (Fecha, Estado, Id\_Empleado, Id\_Cliente) VALUES (GETDATE(), 'Aprobada', 1, 1);

\-- Resultado esperado: Operación exitosa.

REVERT;



\-- Prueba B: INSERT directo sobre Venta con lector

EXECUTE AS USER = 'usuario\_lector';

INSERT INTO Venta (Fecha, Estado, Id\_Empleado, Id\_Cliente) VALUES (GETDATE(), 'Aprobada', 1, 1);

\-- Resultado esperado: SQL Server rechaza la operación por falta de permisos de inserción.

REVERT;



\-- Prueba C: INSERT mediante procedimiento almacenado con lector

EXECUTE AS USER = 'usuario\_lector';

EXEC dbo.sp\_RegistrarVentaSimple @Id\_Empleado = 1, @Id\_Cliente = 1;

\-- Resultado esperado: La venta se registra correctamente porque el usuario posee permiso de ejecución sobre el procedimiento, conservando el control de la lógica de negocio.

REVERT;





\-- =========================================================================

\-- PARTE 2: PERMISOS A NIVEL DE ROLES

\-- =========================================================================



\-- 1. Creación de usuarios

CREATE LOGIN usuario\_con\_rol WITH PASSWORD = 'Rol123\*';

CREATE LOGIN usuario\_sin\_rol WITH PASSWORD = 'Rol456\*';

GO



CREATE USER usuario\_con\_rol FOR LOGIN usuario\_con\_rol;

CREATE USER usuario\_sin\_rol FOR LOGIN usuario\_sin\_rol;

GO



\-- 2. Creación de un rol personalizado para consultar infraestructura

CREATE ROLE rol\_consulta\_rutas;

GO



\-- 3. Asignación de permisos al rol

GRANT SELECT ON dbo.Ruta TO rol\_consulta\_rutas;

GO



\-- 4. Incorporación de usuario al rol

ALTER ROLE rol\_consulta\_rutas ADD MEMBER usuario\_con\_rol;

GO



\-- 5. Verificación de comportamiento



\-- Prueba D: SELECT sobre Ruta con usuario que posee el rol

EXECUTE AS USER = 'usuario\_con\_rol';

SELECT \* FROM Ruta;

\-- Resultado esperado: Consulta exitosa.

REVERT;



\-- Prueba E: SELECT sobre Ruta con usuario sin el rol

EXECUTE AS USER = 'usuario\_sin\_rol';

SELECT \* FROM Ruta;

\-- Resultado esperado: SQL Server deniega el acceso por falta de permisos.

REVERT;

