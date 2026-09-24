---
name: ecs-memoria-insuficiente
titulo: Tarea ECS terminada por falta de memoria
sistema: ecs
description: El contenedor muere con codigo 137 o OOMKilled. Usar cuando el servicio se reinicia bajo carga y no al arrancar.
---

# Tarea ECS terminada por falta de memoria

## Confirmar
```bash
aws ecs describe-tasks --cluster <c> --tasks <t> \
  --query 'tasks[0].containers[0].{code:exitCode,reason:reason}'
```
`exitCode 137` es el proceso terminado por el sistema: se quedo sin memoria.

## Distinguir del crash loop de arranque
- OOM ocurre **bajo carga**, despues de minutos u horas.
- Un fallo de configuracion ocurre en segundos, siempre igual.

## Actuar
1. Mirar la metrica de memoria del servicio antes de subir el limite.
2. Subir memoria sin entender por que crecio solo corre el problema de lugar.
3. Si la memoria crece linealmente con el tiempo, es una fuga: es un bug, no
   un problema de capacidad.
