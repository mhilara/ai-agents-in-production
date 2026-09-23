---
description: Diagnosticar un servicio ECS que falla. Sigue el runbook, no improvisa.
argument-hint: <cluster> <servicio>
---

Diagnosticá el servicio `$2` en el cluster `$1`.

1. Recuperá el runbook de la memoria antes de tocar AWS.
2. Seguilo **en su orden**. No saltees pasos aunque creas saber la respuesta.
3. Recolectá la evidencia en este orden: eventos del servicio → tareas detenidas con su código
   de salida → logs de CloudWatch.
4. Comparó el task definition en uso contra la revisión anterior, para detectar drift.

Devolvé: causa raíz **con la línea del log que la prueba**, y el fix propuesto.
No apliques nada. Esperá autorización.
