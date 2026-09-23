---
id: inc-ingest-api-crash-loop
tipo: incidente
sistema: ecs
titulo: ingest-api en crash loop por deploy manual
---

Sintoma: ingest-api entro en crash loop. Tasks muriendo con exit code 1 a los pocos segundos,
sin llegar a atender trafico.

Causa raiz: un deploy manual fuera de IaC registro una revision del task definition sin la
variable de entorno APP_MESSAGE. El proceso valida esa variable al arrancar y sale con error.

Como se encontro: evento del servicio -> task detenida (exitCode 1) -> log de CloudWatch con el
mensaje "FATAL: APP_MESSAGE no esta definida". El evento dijo QUE fallo; el log dijo POR QUE.

Fix: no se parcheo a mano. Se repuso el estado declarado desde terraform por el pipeline.
El servicio volvio a la revision 1 y a 1/1 tareas sanas.

Leccion: todo cambio fuera de IaC es deuda que se paga en el proximo incidente. El fix correcto
de un drift es volver al estado declarado, no corregir el drift a mano.
