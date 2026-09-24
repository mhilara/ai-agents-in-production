---
name: kafka-consumer-lag
titulo: Consumidor de Kafka con retraso creciente
sistema: kafka
description: El lag de un grupo de consumidores sube sin parar y los mensajes se procesan tarde. Usar cuando los datos llegan con demora.
---

# Consumidor de Kafka con retraso creciente

## Medir
```bash
kafka-consumer-groups --describe --group <grupo>
```
Mirar `LAG` por particion. Si sube en **una sola** particion, el problema es la
distribucion de claves, no la capacidad.

## Causas, en orden
1. El consumidor procesa mas lento de lo que el productor escribe.
2. Rebalanceos constantes: el consumidor tarda mas que `max.poll.interval.ms`.
3. Particiones desbalanceadas por una clave dominante.

## Actuar
- Mas consumidores solo ayuda si hay particiones libres: nunca mas consumidores
  que particiones.
- Antes de escalar, medir cuanto tarda el procesamiento de un mensaje.
