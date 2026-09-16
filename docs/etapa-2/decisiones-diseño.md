Decisiones de diseño 


Selección y acotación del dominio: Se eligió el rubro de transporte de pasajeros de larga distancia ("Corrientes Porá Bus"), delimitando el alcance estrictamente a la programación de viajes, control de flota, venta/emisión de boletos y registro de pagos.


Gestión de capacidad como stock físico: Se resolvió que el stock no sea un número entero genérico, sino que esté representado por la existencia física individual de cada asiento (Butaca) perteneciente a un Colectivo específico, garantizando que solo se vendan plazas reales y bloqueando la sobreventa por viaje.


Persistencia histórica del precio: Se estableció registrar el Precio_Unitario de manera obligatoria en cada línea de emisión (Pasaje), garantizando la inmutabilidad de la tarifa facturada frente a posteriores aumentos de listas de precios o cambios en la tarifa base del viaje.


Desacoplamiento de venta y cobranza: Se determinó separar la transacción comercial (Venta) del cobro (Pago), permitiendo registrar múltiples medios de pago (efectivo, tarjeta, transferencia) para una sola operación y validando que el boleto solo se confirme tras cubrir el importe total.


