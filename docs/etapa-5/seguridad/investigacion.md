\# Tema Técnico: Seguridad y Control de Accesos (SQL Server)



\## 1. Definición y Objetivo

La seguridad en un Sistema de Gestión de Bases de Datos (SGBD) administra la \*\*Autenticación\*\* (quién accede al motor) y la \*\*Autorización\*\* (qué acciones puede realizar cada usuario sobre las tablas y objetos). Su objetivo principal es aplicar el \*Principio de Menor Privilegio\*, garantizando que cada usuario opere únicamente con los permisos estrictamente necesarios para su función.



\## 2. Ventajas y Aplicaciones

\* \*\*Protección de la Información:\*\* Impide accesos no autorizados a tablas críticas o sensibles del sistema.

\* \*\*Prevención de Operaciones Destructivas:\*\* Evita la ejecución de sentencias `DELETE` o `DROP` de forma accidental o maliciosa sobre transacciones comerciales.

\* \*\*Gestión Eficiente por Perfiles:\*\* Agrupa permisos en roles funcionales (ej. Vendedores, Administradores, Auditores), simplificando la administración masiva de usuarios.

\* \*\*Trazabilidad y Control:\*\* Obliga a los usuarios a identificarse de manera individual, asegurando auditoría sobre las acciones ejecutadas en la base de datos.



\## 3. Implementación en SQL Server Express

En SQL Server, el esquema de seguridad se divide en tres niveles jerárquicos:

1\. \*\*Logins (Inicios de Sesión):\*\* Se definen a nivel del servidor/motor (`CREATE LOGIN`).

2\. \*\*Users (Usuarios):\*\* Se asocian al login a nivel de la base de datos concreta (`CREATE USER`).

3\. \*\*Roles y Permisos:\*\* Se agrupan privilegios mediante roles (`CREATE ROLE`) y se gestionan explícitamente mediante sentencias `GRANT` (permitir), `DENY` (denegar) o `REVOKE` (revocar).



\## 4. Caso Concreto Aplicado a Corrientes Porá Bus

Para el sistema de venta de pasajes de larga distancia, demostramos dos escenarios de control de acceso:

1\. \*\*Seguridad a Nivel de Usuario y Procedimientos Almacenados:\*\* Se crea un `usuario\_lector` (boletero) al que se le deniega la inserción directa sobre la tabla `Venta`, pero se le otorga permiso de ejecución sobre el procedimiento almacenado `sp\_RegistrarVentaSimple` para canalizar las operaciones bajo la lógica de negocio.

2\. \*\*Seguridad a Nivel de Roles Funcionales:\*\* Se implementa el rol `rol\_consulta\_rutas` para otorgar permisos de consulta sobre la infraestructura de trayectos (`Ruta`), permitiendo el acceso a los usuarios pertenecientes al rol (`usuario\_con\_rol`) y bloqueando a los usuarios externos (`usuario\_sin\_rol`).

