# El drift se corrige volviendo al estado declarado

**Qué pasó.** `ingest-api` entró en crash loop. Un despliegue manual, fuera del pipeline, registró
una revisión del task definition sin la variable `APP_MESSAGE`. El proceso la valida al arrancar
y sale con código 1 antes de atender tráfico.

**Cómo se encontró.** Evento del servicio → task detenida con `exitCode 1` → log de CloudWatch con
`FATAL: APP_MESSAGE no esta definida`. El evento dijo *qué*; el log dijo *por qué*.

**Por qué importa.** La tentación es registrar a mano una revisión corregida. Eso deja el sistema
sano y el código mintiendo: el próximo `apply` lo vuelve a romper.

**Regla.** Ante un drift, el fix es reponer el estado declarado desde IaC por el pipeline.
Nunca parchear a mano el síntoma.
