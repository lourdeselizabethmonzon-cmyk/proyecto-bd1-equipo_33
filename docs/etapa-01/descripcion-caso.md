# Descripción del Caso: Sistema de Gestión de Ventas - Corrientes Porá Bus

## 1. Organización
**Corrientes Porá Bus** es una empresa dedicada al transporte de pasajeros de larga distancia en la República Argentina, conectando terminales cabeceras e intermedias a nivel nacional. La compañía opera servicios regulares interurbanos mediante una flota de unidades de gran porte.

## 2. Problemática Actual
A lo largo de su trayectoria operativa, la empresa ha gestionado la venta y la asignación de viajes mediante planillas manuales y canales descentralizados de información entre agencias y boleterías. Esta modalidad tradicional generó episodios de sobreventa física de boletos y dificultades severas para sostener un control integral sobre las operaciones diarias.

Esta falta de centralización se manifiesta en los siguientes puntos críticos:

* **Sobreventa física y duplicación de butacas:** Carencia de sincronización inmediata entre terminales, boleterías y agencias intermedias, lo que provoca la emisión simultánea de dos o más boletos para un mismo asiento y horario, derivando en conflictos directos al momento del embarque.
* **Pérdida de reventa de butacas canceladas:** Cuando un pasajero cancela su boleto o se cae una reserva por falta de pago, el asiento no vuelve a quedar disponible de forma automática para el resto de las boleterías. Al demorarse el aviso, la butaca queda bloqueada y la unidad viaja con lugares vacíos recuperables.
* **Cierre de caja y arqueos manuales propensos a errores:** Al finalizar cada turno o jornada, el recuento del dinero en efectivo, cupones de tarjetas y transferencias se hace a mano en papel. Esto ralentiza los cierres, dificulta detectar faltantes o sobrantes al instante y complica la conciliación contable contra los pasajes emitidos.
* **Carga repetitiva y lenta de datos de clientes:** El vendedor debe reescribir manualmente los datos personales (nombre, DNI, teléfono) en cada transacción al carecer de un padrón histórico centralizado, enlenteciendo la atención en ventanilla y generando errores de tipeo.
* **Falta de informes y estadísticas para la toma de decisiones:** La gerencia no dispone de reportes centralizados ni actualizados sobre ocupación real de coches, rutas más rentables o franjas horarias de mayor demanda, imposibilitando la planificación estratégica de refuerzos.
* **Falta de control del personal y auditoría de ventas:** Ausencia de trazabilidad operativa sobre qué empleado realizó cada emisión, modificación o anulación de pasajes, en qué punto de venta y en qué marca temporal exacta.

## 3. Propósito del Sistema
Implementar una base de datos relacional transaccional que centralice la gestión comercial y operativa de la empresa, garantizando:
* Consistencia e integridad en la disponibilidad de butacas en tiempo real para todas las terminales y agencias.
* Registro histórico de pasajeros y agilización en la emisión de boletos.
* Control estricto de cobranzas, medios de pago y cierres de caja.
* Auditoría completa de las operaciones realizadas por los operadores del sistema.