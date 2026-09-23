---
description: Desplegar una versión por IaC y pipeline. Nunca a mano.
argument-hint: <servicio> <version>
---

Desplegá la versión `$2` de `$1`.

1. Editá **solo** `demo/terraform/terraform.tfvars`. Ningún otro archivo.
2. Mostrame el diff antes de commitear.
3. Con mi OK: commit y push a `main`. El pipeline aplica por OIDC.
4. Seguí la corrida hasta que termine.
5. Verificá en runtime: `describe-services` estable y una consulta HTTP real al servicio.

Prohibido: `aws ecs update-service` a mano, `register-task-definition` a mano, o cualquier
`terraform apply` local salvo que yo te lo pida explícitamente como plan B.

No digas "desplegado" hasta haber visto la respuesta del servicio con la versión nueva.
