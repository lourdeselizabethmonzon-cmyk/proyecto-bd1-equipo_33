\# Evidencias y Pruebas de Ejecución (Seguridad)



\## Parte 1: Permisos a Nivel de Usuario y Procedimientos



\### Prueba 1: Inserción directa en tabla Venta con usuario Administrador

```sql

EXECUTE AS USER = 'usuario\_admin';

INSERT INTO Venta (Fecha, Estado, Id\_Empleado, Id\_Cliente) VALUES (GETDATE(), 'Aprobada', 1, 1);

REVERT;

