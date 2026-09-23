---
id: rb-kafka-retencion
tipo: runbook
sistema: kafka
titulo: Brokers Kafka caidos por disco lleno
---

Sintoma: 2 de 3 brokers abajo, particiones sub-replicadas, el cluster no acepta escrituras.

Causa que casi nadie ve: **la retencion configurada nunca se aplica si el segmento no rota.**
Con `segment.bytes` de 256 MB y `retention.ms` de 60 segundos, el segmento activo sigue abierto y
nada se borra. La retencion solo actua sobre segmentos cerrados.

Diagnostico:
1. `df -h` en cada broker: confirmar que es disco y no memoria.
2. `kafka-configs --describe` por topic: mirar `retention.ms`, `retention.bytes` y `segment.bytes` juntos.
3. Identificar los topics que mas ocupan.

Fix, en este orden:
1. Ampliar el almacenamiento para recuperar el cluster (medida de contencion, no la solucion).
2. Corregir `segment.bytes` y `segment.ms` para que la retencion pueda aplicarse.
3. Verificar 3/3 brokers arriba y 0 particiones sub-replicadas.

Leccion: una configuracion de retencion puede estar "puesta" y no estar funcionando.
