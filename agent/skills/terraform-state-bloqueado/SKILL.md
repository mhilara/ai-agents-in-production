---
name: terraform-state-bloqueado
titulo: Terraform con el estado bloqueado
sistema: terraform
description: Terraform no puede adquirir el lock del estado y ninguna operacion avanza. Usar cuando apply o plan quedan esperando.
---

# Terraform con el estado bloqueado

## Entender antes de forzar
Un lock existe porque **alguien o algo** esta aplicando. Forzarlo mientras otra
operacion corre corrompe el estado.

## Verificar que este huerfano
1. Confirmar que ninguna corrida del pipeline esta activa.
2. Confirmar que ningun companero esta aplicando.
3. Recien entonces leer el id del lock y liberarlo.

```bash
terraform force-unlock -force <ID>
```

**Regla:** liberar un lock sin verificar es la forma mas rapida de perder el
estado de la infraestructura.
