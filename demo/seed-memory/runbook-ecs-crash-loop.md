---
id: rb-ecs-crash-loop
tipo: runbook
sistema: ecs
titulo: Servicio ECS en crash loop
---

Recorrer estos 5 patrones EN ORDEN antes de adivinar. El 80% de los casos muere en los dos primeros.

1. **Variable de entorno faltante.** Comparar el task definition en uso contra la revision anterior
   (`aws ecs describe-task-definition`). Un deploy manual fuera de IaC suele perder una variable.
   Sintoma: el contenedor sale con exit code 1 en menos de 5 segundos, sin trafico.
2. **Imagen inexistente o sin permisos de pull.** El evento del servicio dice `CannotPullContainerError`.
3. **Health check mal configurado.** La task arranca, pasa a RUNNING y el balanceador la mata.
   Sintoma: reinicios cada ~2-3 minutos, no cada 30 segundos.
4. **Memoria insuficiente.** Exit code 137 (OOMKilled). Revisar `memory` del task definition.
5. **Permisos del task role.** El proceso arranca y falla al primer llamado a AWS.

Evidencia a recolectar siempre, en este orden:
- `aws ecs describe-services` -> campo `events` (los ultimos 10).
- `aws ecs list-tasks --desired-status STOPPED` -> `stoppedReason` y `exitCode` del contenedor.
- Logs de CloudWatch del log group del servicio, ultimos 15 minutos.

Regla: no se declara la causa raiz hasta ver el mensaje de error en el log. El evento de ECS dice
QUE fallo; el log dice POR QUE.

Fix: si la causa es drift respecto a IaC, no se parcha a mano. Se corrige en terraform y se deja
que el pipeline reponga el estado declarado.
