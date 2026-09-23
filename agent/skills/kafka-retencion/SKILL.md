---
name: kafka-retencion
description: Brokers de Kafka caídos o disco lleno cuando la retención parece estar configurada. Usar ante particiones sub-replicadas, escrituras rechazadas o discos llenos en el cluster.
---

# La retención configurada que nunca se aplica

**El detalle que casi nadie ve:** la retención solo actúa sobre **segmentos cerrados**.
Si `segment.bytes` es 256 MB y el tópico escribe despacio, el segmento activo nunca rota,
y una `retention.ms` de 60 segundos jamás llega a ejecutarse. La configuración está puesta
y no hace nada.

## Diagnóstico
```bash
df -h                                    # confirmar que es disco, no memoria
kafka-configs --describe --entity-type topics --entity-name <topico>
```
Mirar los tres juntos: `retention.ms`, `retention.bytes` y `segment.bytes`.

## Fix, en este orden
1. **Ampliar el almacenamiento** para recuperar el cluster. Es contención, no la solución.
2. **Corregir `segment.bytes` y `segment.ms`** para que la retención pueda aplicarse.
3. Verificar: 3/3 brokers arriba y **0 particiones sub-replicadas**.

## Lección
Una configuración puede estar "puesta" y no estar funcionando.
Verificar el efecto, no la presencia del parámetro.
