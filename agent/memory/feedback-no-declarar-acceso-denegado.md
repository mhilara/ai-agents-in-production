# "No tengo acceso" casi nunca es cierto

**Corrección del operador.** El agente reportó falta de permisos sin haber probado con todas las
identidades disponibles. Al medir, el permiso existía: el 401 venía de un límite de tasa, no de IAM.

**Por qué importa.** Declarar falta de acceso corta la investigación y manda a una persona a pedir
permisos que ya tiene. Es un callejón sin salida caro.

**Regla.** Antes de decir "no tengo acceso": probar con cada perfil disponible, leer el mensaje de
error completo y distinguir `AccessDenied` de `Throttling` o `TooManyRequests`.
