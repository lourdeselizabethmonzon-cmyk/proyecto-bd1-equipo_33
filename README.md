# PROYECTO BASE DE DATOS 1 — EQUIPO 33

<p align="center">
  <img src="./assets/logo-corrientes-pora-bus.png" alt="Logo Corrientes Porá Bus" width="650"/>
</p>

<table>
<tr>
<th align="left"><h2> ORGANIZACIÓN</h2></th>
</tr>
<tr>
<td>

**"Corrientes Porá Bus"** es una empresa dedicada al transporte de pasajeros de larga distancia en la República Argentina, conectando terminales cabeceras e intermedias a nivel nacional. La compañía opera servicios regulares interurbanos mediante una flota de unidades de gran porte.

</td>
</tr>
</table>

<table>
<tr>
<th align="left"><h2> Presentación y Contexto</h2></th>
</tr>
<tr>
<td>

A lo largo de su trayectoria operativa, la empresa ha gestionado la venta y la asignación de viajes mediante planillas manuales y canales descentralizados de información entre agencias y boleterías. Esta modalidad tradicional generó episodios de sobreventa física de boletos y volvió sumamente complejo sostener un control integral sobre las operaciones diarias.

Esta falta de centralización se manifiesta en las siguientes dificultades cotidianas:

*  **Sobreventa física y duplicación de butacas.**
*  **Pérdida de reventa de butacas canceladas.**
*  **Cierre de caja y arqueos manuales propensos a errores.**
*  **Carga repetitiva y lenta de datos de clientes.**
*  **Falta de informes y estadísticas para la toma de decisiones.**
*  **Falta de control del personal y auditoría de ventas.**

</td>
</tr>
</table>

<table>
<tr>
<th align="left"><h2> Reglas de Negocio</h2></th>
</tr>
<tr>
<td>

* **RN.01 Registro Obligatorio y Unicidad de Personas:**  
  Registro previo con documento único, permitiendo que un cliente compre pasajes para varios pasajeros en una misma operación.

* **RN.02 Control Estricto de Capacidad y Stock (Butaca por Viaje):**  
  El stock depende del coche asignado; se bloquea la venta duplicada de una misma butaca por viaje.

* **RN.03 Historial e Inmutabilidad del Precio Unitario:**  
  El precio se congela en el pasaje al venderse, sin alterarse por cambios tarifarios posteriores.

* **RN.04 Validación Integral de Pagos:**  
  La venta y los pasajes se emiten únicamente tras cubrir el monto total con pagos válidos.

* **RN.05 Nominatividad Intransferible del Pasaje:**  
  Cada boleto debe estar asignado obligatoriamente a una venta, viaje, butaca física y pasajero específico.

* **RN.06 Asignación Consistente de Unidades de Larga Distancia:**  
  Todo viaje requiere una unidad asignada y no pueden venderse butacas fuera de su capacidad física.

* **RN.07 Política de Devolución y Reincorporación de Stock:**  
  La cancelación previa al viaje anula el boleto, genera comprobante y libera la butaca para la reventa.

* **RN.08 Trazabilidad y Responsabilidad de Emisión:**  
  Toda venta debe quedar vinculada al empleado emisor y a su turno de trabajo.

</td>
</tr>
</table>

<table>
<tr>
<th align="left"><h2> Alcance del Sistema</h2></th>
</tr>
<tr>
<td>

* **Gestión de Rutas y Terminales:**  
  Registro y administración del catálogo de terminales cabeceras e intermedias a nivel provincial y nacional, vinculados a rutas interurbanas con distancias en kilómetros y duraciones estimadas de recorrido.

* **Gestión de Flota y Capacidad (Stock):**  
  Control del inventario físico de las unidades vehiculares (patente, marca, modelo, cantidad de pisos y capacidad total), desagregando individualmente cada butaca con su número físico, nivel, ubicación (pasillo o ventanilla) y tipo de servicio (Semicama, Cama Ejecutivo, Suite Cama) para prevenir sobreventas.

* **Gestión de Viajes y Cronogramas:**  
  Programación, modificación y cancelación de servicios de largo recorrido, coordinando una ruta, fecha y hora de partida, tiempo proyectado de arribo, tarifa base y un ómnibus asignado, impidiendo colisiones operativas de una misma unidad física.

* **Gestión de Clientes y Pasajeros:**  
  Padrón unificado de personas físicas y jurídicas con validación unívoca del documento de identidad (DNI, CUIT, Pasaporte), diferenciando al comprador comercial de los pasajeros nominativos que abordan el servicio.

* **Gestión de Personal y Puntos de Emisión:**  
  Registro del personal comercial con legajo, DNI, datos de contacto y turnos laborales, asignando la autoría operativa y la auditoría a cada comprobante emitido.

* **Gestión de Venta y Emisión de Pasajes:**  
  Consulta de frecuencias disponibles, selección de butacas en tiempo real, emisión de boletos vinculados a una factura y congelamiento de tarifas pactadas al momento de la transacción.

* **Gestión de Facturación y Pagos:**  
  Registro de comprobantes comerciales respaldados por una o más modalidades de pago (efectivo, tarjeta de débito, crédito, transferencia bancaria), exigiendo la cancelación total del importe para confirmar la operación.

* **Gestión de Reservas y Devoluciones:**  
  Administración de estados de butacas y boletos, admitiendo reservas temporales y cancelaciones previas a la salida del viaje con restitución inmediata de los asientos al inventario disponible.

</td>
</tr>
</table>

---

## 📁 Estructura del Proyecto

<table>
<tr>
<th width="50%">Documentación (<code>docs/</code>)</th>
<th width="50%">Scripts de Base de Datos (<code>sql/</code>)</th>
</tr>
<tr>
<td valign="top">

<pre>
docs/
├── etapa-01/
│   ├── descripcion-caso.md
│   ├── alcance.md
│   ├── reglas-negocio.md
│   └── decisiones-diseno.md
├── etapa-2/
│   ├── der/
│   │   └── DERproyecto.png
│   ├── modelo-relacional.md
│   ├── normalizacion.md
│   ├── normalizacion-erd.png
│   ├── tablas_Proyecto.jpeg
│   └── decisiones-diseño.md
├── etapa-3/
│   ├── implementacion.md
│   ├── restricciones-integridad.md
│   └── pruebas-validacion.md
├── etapa-4/
│   ├── casos-uso.md
│   ├── comprobante-venta.md
│   └── informe-ventas.md
└── etapa-5/
    ├── procedimiento-funcionales.md
    ├── transacciones.md
    ├── triggers-auditoria.md
    ├── seguridad.md
    └── indice-optimizacion.md
</pre>

</td>
<td valign="top">

<pre>
sql/
├── ddl/
│   └── crear_bd.sql
│
├── dml/
│   └── datos_prueba.sql
│
├── consultas/
│   ├── comprobante_venta.sql
│   ├── informe_ventas.sql
│   └── consulta_avanzada.sql
│
└── tecnico/
    ├── procedimientos/
    ├── funciones/
    ├── transacciones/
    ├── triggers/
    ├── seguridad/
    └── indices/
</pre>

</td>
</tr>
</table>

---

##  Documentación del Proyecto por Etapas

<table>
<tr>
<th align="left"><h3>🔹 Etapa 01: Requerimientos y Dominio del Negocio</h3></th>
</tr>
<tr>
<td>

Relevamiento funcional del caso de estudio, análisis del contexto operativo, definición del alcance del sistema y redacción de las reglas de negocio indispensables para garantizar la integridad transaccional.

* [`descripcion-caso.md`](./docs/etapa-01/descripcion-caso.md) — Breve introducción al rubro elegido y alcance general del sistema.
* [`alcance.md`](./docs/etapa-01/alcance.md) — Especificación de procesos cubiertos y exclusiones explícitas para evitar ambigüedades en el alcance[cite: 4].
* [`reglas-negocio.md`](./docs/etapa-01/reglas-negocio.md) — Redacción explícita de las reglas que rigen las operaciones del negocio.
* [`decisiones-diseno.md`](./docs/etapa-01/decisiones-diseno.md) — Criterios técnicos y fundamentos adoptados en la definición del modelo.

</td>
</tr>
</table>

<table>
<tr>
<th align="left"><h3>🔹 Etapa 02: Modelado Conceptual y Lógico</h3></th>
</tr>
<tr>
<td>

Formalización del esquema conceptual de datos mediante el Diagrama Entidad-Relación y su posterior transformación al modelo relacional, aplicando el proceso riguroso de normalización hasta 3FN.

* [`DERproyecto.png`](./docs/etapa-2/der/DERproyecto.png) — Diagrama Entidad-Relación en notación Peter Chen realizado en ERDPlus.
* [`modelo-relacional.md`](./docs/etapa-2/modelo-relacional.md) — Especificación de tablas relacionales con definición de claves primarias (PK) y foráneas (FK).
* [`normalizacion.md`](./docs/etapa-2/normalizacion.md) — Evolución y justificación técnica paso a paso del modelo (1FN, 2FN y 3FN).
* [`decisiones-diseño.md`](./docs/etapa-2/decisiones-diseño.md) — Criterios de adopción de claves subrogadas, cardinalidades y restricciones.
* [`normalizacion-erd.png`](./docs/etapa-2/normalizacion-erd.png) — Esquema gráfico del proceso de normalización en ERDPlus.
* [`tablas_Proyecto.jpeg`](./docs/etapa-2/tablas_Proyecto.jpeg) — Diagrama relacional visual de tablas y vínculos físicos.

</td>
</tr>
</table>

<table>
<tr>
<th align="left"><h3>🔹 Etapa 03: Implementación Física (Scripts SQL)</h3></th>
</tr>
<tr>
<td>

Traducción del modelo lógico al motor relacional, implementando los scripts DDL de creación e integridad referencial junto a la carga controlada de registros iniciales de prueba (DML).

* [`implementacion.md`](./docs/etapa-3/implementacion.md) — Configuración del entorno del motor, parámetros y orden secuencial de despliegue.
* [`restricciones-integridad.md`](./docs/etapa-3/restricciones-integridad.md) — Detalle de reglas referenciales, tipos de datos y restricciones (`NOT NULL`, `UNIQUE`, `CHECK`).
* [`pruebas-validacion.md`](./docs/etapa-3/pruebas-validacion.md) — Validación de consistencia del modelo a través de datos de prueba cargados.
* [`crear_bd.sql`](./sql/ddl/crear_bd.sql) — Script DDL completo de creación de tablas, relaciones y restricciones de integridad.
* [`datos_prueba.sql`](./sql/dml/datos_prueba.sql) — Script DML con carga de 8 a 10 registros coherentes por entidad para pruebas.

</td>
</tr>
</table>

<table>
<tr>
<th align="left"><h3>🔹 Etapa 04: Consultas y Casos de Uso</h3></th>
</tr>
<tr>
<td>

Diseño, ejecución y análisis de consultas SQL para resolver necesidades críticas de información del negocio, detallando la necesidad operativa, la estrategia técnica y el resultado esperado.

* [`casos-uso.md`](./docs/etapa-4/casos-uso.md) — Documentación de escenarios operativos reales para validación integral del sistema.
* [`comprobante-venta.md`](./docs/etapa-4/comprobante-venta.md) — Factura consolidada con renglones, subtotales y total acumulado (`INNER JOIN` y `SUM OVER`).
* [`informe-ventas.md`](./docs/etapa-4/informe-ventas.md) — Reportes periódicos de recaudación y volumen comercial por vendedor o categoría (`GROUP BY`, `SUM`, `COUNT`).
* [`comprobante_venta.sql`](./sql/consultas/comprobante_venta.sql) — Script SQL ejecutable del comprobante de venta detallado.
* [`informe_ventas.sql`](./sql/consultas/informe_ventas.sql) — Script SQL ejecutable de métricas y totales agrupados.
* [`consulta_avanzada.sql`](./sql/consultas/consulta_avanzada.sql) — Script SQL ejecutable de consulta multicriterio multirrelacional.

</td>
</tr>
</table>

<table>
<tr>
<th align="left"><h3>🔹 Etapa 05: Implementación de Temas Técnicos</h3></th>
</tr>
<tr>
<td>

Investigación e implementación de componentes y mecanismos avanzados en el motor relacional para asegurar robustez, velocidad, consistencia transaccional y seguridad a largo plazo.

* [`procedimiento-funcionales.md`](./docs/etapa-5/procedimiento-funcionales.md) — Fundamentos y rutinas almacenadas para automatización y encapsulamiento.
* [`transacciones.md`](./docs/etapa-5/transacciones.md) — Control transaccional (`BEGIN`, `COMMIT`, `ROLLBACK`) para salvaguardar propiedades ACID.
* [`triggers-auditoria.md`](./docs/etapa-5/triggers-auditoria.md) — Disparadores para trazabilidad de estados y auditoría sobre entidades críticas.
* [`seguridad.md`](./docs/etapa-5/seguridad.md) — Definición de roles, permisos granulares y usuarios bajo principio de menor privilegio.
* [`indice-optimizacion.md`](./docs/etapa-5/indice-optimizacion.md) — Planes de indexación estratégica para optimizar tiempos de ejecución.
* [`sql/tecnico/`](./sql/tecnico/) — Directorio con scripts SQL de procedimientos, funciones, transacciones, triggers, seguridad e índices.

</td>
</tr>
</table>