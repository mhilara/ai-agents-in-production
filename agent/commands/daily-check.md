---
description: Revisión diaria de la plataforma. Solo lectura, sin excepciones.
---

Revisá el estado de la plataforma y devolvé un tablero corto. **Todo en modo lectura.**

1. Servicios ECS: para cada servicio, `runningCount` contra `desiredCount` y si hay un
   despliegue en curso.
2. Tareas detenidas en las últimas 12 horas, con su `stoppedReason` y `exitCode`.
3. Alarmas de CloudWatch en estado ALARM.
4. Discos y uso de los motores de datos que tengan métrica publicada.

Formato de salida: una tabla de máximo 10 filas, una línea por hallazgo, y nada más.

**Antes de marcar algo en rojo:** verificá que el problema no sea de alcanzabilidad desde donde
estás midiendo. "No responde desde acá" no es "está caído". Si no podés distinguirlo, decilo
como duda, no como incidente.

No propongas cambios en este comando. Solo reportá.
