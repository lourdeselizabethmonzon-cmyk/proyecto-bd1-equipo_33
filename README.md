> ### PROYECTO BASE DE DATOS 1 — EQUIPO 33
> <p align="center">
  <img src="./assets/logo-corrientes-pora-bus.png" alt="Logo Corrientes Porá Bus" width="450"/>
</p>

<div style="border-left: 5px solid #44c8da; background-color: rgba(0, 122, 204, 0.05); padding: 12px 18px; border-radius: 4px; margin-bottom: 14px;">
<span style="font-weight: bold; border-bottom: 3px solid #44c8da; padding-bottom: 3px;">ORGANIZACIÓN</span><br><br>
"Corrientes Porá Bus" es una empresa dedicada al transporte de pasajeros de larga distancia en la República Argentina, conectando terminales cabeceras e intermedias a nivel nacional. La compañía opera servicios regulares interurbanos mediante una flota de unidades de gran porte.
</div>


<div style="border: 1px solid #30363d; border-radius: 8px; padding: 16px; margin-bottom: 16px;">
<span style="font-weight: bold; border-bottom: 3px solid #44c8da; padding-bottom: 3px;">Presentación y Contexto: </span><br><br>

A lo largo de su trayectoria operativa, la empresa ha gestionado la venta y la asignación de viajes mediante planillas manuales y canales descentralizados de información entre agencias y boleterías. Esta modalidad tradicional generó episodios de sobreventa física de boletos y volvió sumamente complejo sostener un control integral sobre las operaciones diarias.
Esta falta de centralización se manifiesta en las siguientes dificultades cotidianas:

*  **Sobreventa física y duplicación de butacas.**
*  **Pérdida de reventa de butacas canceladas.**
*  **Cierre de caja y arqueos manuales propensos a errores.**
*  **Carga repetitiva y lenta de datos de clientes.**
*  **Falta de informes y estadísticas para la toma de decisiones.**
*  **Falta de control del personal y auditoría de ventas.**

</div>



<div style="border: 1px solid #30363d; border-radius: 8px; padding: 16px; margin-bottom: 16px;">
<span style="font-weight: bold; border-bottom: 3px solid #44c8da; padding-bottom: 3px;">Reglas de Negocio </span><br><br>


* **RN.01 Registro Obligatorio y Unicidad de Personas:** Registro previo con documento único, permitiendo que un cliente compre pasajes para varios pasajeros en una misma operación.
* **RN.02 Control Estricto de Capacidad y Stock (Butaca por Viaje):** El stock depende del coche asignado; se bloquea la venta duplicada de una misma butaca por viaje.
* **RN.03 Historial e Inmutabilidad del Precio Unitario:** El precio se congela en el pasaje al venderse, sin alterarse por cambios tarifarios posteriores.
* **RN.04 Validación Integral de Pagos:** La venta y los pasajes se emiten únicamente tras cubrir el monto total con pagos válidos.
* **RN.05 Nominatividad Intransferible del Pasaje:** Cada boleto debe estar asignado obligatoriamente a una venta, viaje, butaca física y pasajero específico.
* **RN.06 Asignación Consistente de Unidades de Larga Distancia:** Todo viaje requiere una unidad asignada y no pueden venderse butacas fuera de su capacidad física.
* **RN.07 Política de Devolución y Reincorporación de Stock:** La cancelación previa al viaje anula el boleto, genera comprobante y libera la butaca para la reventa.
* **RN.08 Trazabilidad y Responsabilidad de Emisión:** Toda venta debe quedar vinculada al empleado emisor y a su turno de trabajo.


</div>

---

<div style="border: 1px solid #30363d; border-radius: 8px; padding: 16px; margin-bottom: 16px;"> 
<span style="font-weight: bold; border-bottom: 3px solid #44c8da; padding-bottom: 3px;">Alcance del Sistema: </span><br><br>


* **Gestión de Rutas y Terminales:** Registro y administración del catálogo de terminales cabeceras e intermedias a nivel provincial y nacional, vinculados a rutas interurbanas con distancias en kilómetros y duraciones estimadas de recorrido.
* **Gestión de Flota y Capacidad (Stock):** Control del inventario físico de las unidades vehiculares (patente, marca, modelo, cantidad de pisos y capacidad total), desagregando individualmente cada butaca con su número físico, nivel, ubicación (pasillo o ventanilla) y tipo de servicio (Semicama, Cama Ejecutivo, Suite Cama) para prevenir sobreventas.
* **Gestión de Viajes y Cronogramas:** Programación, modificación y cancelación de servicios de largo recorrido, coordinando una ruta, fecha y hora de partida, tiempo proyectado de arribo, tarifa base y un ómnibus asignado, impidiendo colisiones operativas de una misma unidad física.
* **Gestión de Clientes y Pasajeros:** Padrón unificado de personas físicas y jurídicas con validación unívoca del documento de identidad (DNI, CUIT, Pasaporte), diferenciando al comprador comercial de los pasajeros nominativos que abordan el servicio.
* **Gestión de Personal y Puntos de Emisión:** Registro del personal comercial con legajo, DNI, datos de contacto y turnos laborales, asignando la autoría operativa y la auditoría a cada comprobante emitido.
* **Gestión de Venta y Emisión de Pasajes:** Consulta de frecuencias disponibles, selección de butacas en tiempo real, emisión de boletos vinculados a una factura y congelamiento de tarifas pactadas al momento de la transacción.
* **Gestión de Facturación y Pagos:** Registro de comprobantes comerciales respaldados por una o más modalidades de pago (efectivo, tarjeta de débito, crédito, transferencia bancaria), exigiendo la cancelación total del importe para confirmar la operación.
* **Gestión de Reservas y Devoluciones:** Administración de estados de butacas y boletos, admitiendo reservas temporales y cancelaciones previas a la salida del viaje con restitución inmediata de los asientos al inventario disponible.

</div>




<h3 style="color: #ffffff; font-weight: bold; border-left: 4px solid #44c8da; padding-left: 10px;">Estructura del proyecto</h3>

<table style="width: 100%; border: none; background: transparent; border-collapse: separate; border-spacing: 12px 0;">
<tr>
<td valign="top" width="55%" style="border: 1px solid #262841; border-radius: 6px; padding: 12px; background: transparent;">
<pre style="margin: 0; padding: 0; background: transparent; border: none; color: #ffffff; font-family: 'Consolas', 'Courier New', monospace; font-size: 13px; line-height: 1.45;">
docs/
├── etapa-01/
│   ├── descripcion-caso.md
│   ├── alcance.md
│   ├── reglas-negocio.md
│   └── decisiones-diseno.md
│
├── etapa-02/
│   ├── der/
│   │   └── der.png
│   ├── modelo-relacional.md
│   ├── normalizacion.md
│   └── decisiones-diseno.md
│
├── etapa-03/
│   ├── implementacion.md
│   ├── restricciones-integridad.md
│   └── pruebas-validacion.md
│
├── etapa-04/
│   ├── casos-uso.md
│   ├── comprobante-venta.md
│   ├── informe-ventas.md
│   └── consulta-avanzada.md
│
└── etapa-05/
    ├── procedimientos-funciones.md
    ├── transacciones.md
    ├── triggers-auditoria.md
    ├── seguridad.md
    └── indices-optimizacion.md
</pre>
</td>
<td valign="top" width="45%" style="border: 1px solid #262841; border-radius: 6px; padding: 12px; background: transparent;">
<pre style="margin: 0; padding: 0; background: transparent; border: none; color: #ffffff; font-family: 'Consolas', 'Courier New', monospace; font-size: 13px; line-height: 1.45;">
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


## Documentación del Proyecto por Etapas

<div style="border: 1px solid rgba(68, 200, 218, 0.25); border-radius: 6px; padding: 18px 22px; background: transparent; margin-bottom: 18px;">

<h3 style="margin-top: 0; color: #ffffff; font-size: 16px; border-bottom: 1px solid rgba(68, 200, 218, 0.2); padding-bottom: 8px;">
  Etapa 01: Requerimientos y Dominio del Negocio
</h3>

<p style="color: #c9d1d9; font-size: 13.5px; line-height: 1.5; margin-bottom: 16px;">
  Relevamiento funcional del caso de estudio, análisis del contexto operativo, definición del alcance del sistema y redacción de las reglas de negocio indispensables para garantizar la integridad transaccional.
</p>

<p style="margin: 8px 0; font-size: 13px; line-height: 1.5;">
  <a href="./docs/etapa-01/descripcion-caso.md" style="color: #44c8da; text-decoration: none; font-weight: 600;">descripcion-caso.md</a>
  <span style="color: #8b949e;"> — Breve introducción al rubro elegido y alcance general del sistema.</span>
</p>

<p style="margin: 8px 0; font-size: 13px; line-height: 1.5;">
  <a href="./docs/etapa-01/alcance.md" style="color: #44c8da; text-decoration: none; font-weight: 600;">alcance.md</a>
  <span style="color: #8b949e;"> — Especificación de procesos cubiertos y exclusiones explícitas para evitar ambigüedades en el alcance[cite: 4].</span>
</p>

<p style="margin: 8px 0; font-size: 13px; line-height: 1.5;">
  <a href="./docs/etapa-01/reglas-negocio.md" style="color: #44c8da; text-decoration: none; font-weight: 600;">reglas-negocio.md</a>
  <span style="color: #8b949e;"> — Redacción explícita de las reglas que rigen las operaciones del negocio.</span>
</p>

<p style="margin: 8px 0 0 0; font-size: 13px; line-height: 1.5;">
  <a href="./docs/etapa-01/decisiones-diseno.md" style="color: #44c8da; text-decoration: none; font-weight: 600;">decisiones-diseno.md</a>
  <span style="color: #8b949e;"> — Criterios técnicos y fundamentos adoptados en la definición del modelo.</span>
</p>

</div>

<div style="border: 1px solid rgba(68, 200, 218, 0.25); border-radius: 6px; padding: 18px 22px; background: transparent; margin-bottom: 18px;">

<h3 style="margin-top: 0; color: #ffffff; font-size: 16px; border-bottom: 1px solid rgba(68, 200, 218, 0.2); padding-bottom: 8px;">
  Etapa 02: Modelado Conceptual y Lógico
</h3>

<p style="color: #c9d1d9; font-size: 13.5px; line-height: 1.5; margin-bottom: 16px;">
  Formalización del esquema conceptual de datos mediante el Diagrama Entidad-Relación y su posterior transformación al modelo relacional, aplicando el proceso riguroso de normalización hasta 3FN.
</p>

<p style="margin: 8px 0; font-size: 13px; line-height: 1.5;">
  <a href="./docs/etapa-2/der/DERproyecto.png" style="color: #44c8da; text-decoration: none; font-weight: 600;">DERproyecto.png</a>
  <span style="color: #8b949e;"> — Diagrama Entidad-Relación en notación Peter Chen realizado en ERDPlus.</span>
</p>

<p style="margin: 8px 0; font-size: 13px; line-height: 1.5;">
  <a href="./docs/etapa-2/modelo-relacional.md" style="color: #44c8da; text-decoration: none; font-weight: 600;">modelo-relacional.md</a>
  <span style="color: #8b949e;"> — Especificación de tablas relacionales con definición de claves primarias (PK) y foráneas (FK).</span>
</p>

<p style="margin: 8px 0; font-size: 13px; line-height: 1.5;">
  <a href="./docs/etapa-2/normalizacion.md" style="color: #44c8da; text-decoration: none; font-weight: 600;">normalizacion.md</a>
  <span style="color: #8b949e;"> — Evolución y justificación técnica paso a paso del modelo (1FN, 2FN y 3FN).</span>
</p>

<p style="margin: 8px 0; font-size: 13px; line-height: 1.5;">
  <a href="./docs/etapa-2/decisiones-diseño.md" style="color: #44c8da; text-decoration: none; font-weight: 600;">decisiones-diseño.md</a>
  <span style="color: #8b949e;"> — Criterios de adopción de claves subrogadas, cardinalidades y restricciones.</span>
</p>

<p style="margin: 8px 0; font-size: 13px; line-height: 1.5;">
  <a href="./docs/etapa-2/normalizacion-erd.png" style="color: #44c8da; text-decoration: none; font-weight: 600;">normalizacion-erd.png</a>
  <span style="color: #8b949e;"> — Esquema gráfico del proceso de normalización en ERDPlus.</span>
</p>

<p style="margin: 8px 0 0 0; font-size: 13px; line-height: 1.5;">
  <a href="./docs/etapa-2/tablas_Proyecto.jpeg" style="color: #44c8da; text-decoration: none; font-weight: 600;">tablas_Proyecto.jpeg</a>
  <span style="color: #8b949e;"> — Diagrama relacional visual de tablas y vínculos físicos.</span>
</p>

</div>

<div style="border: 1px solid rgba(68, 200,
