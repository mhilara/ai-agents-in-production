---
name: ecs-crash-loop
titulo: Servicio ECS en crash loop
sistema: ecs
description: Diagnosticar un servicio ECS que reinicia sus tareas sin llegar a servir tráfico. Usar cuando el operador diga que un servicio "se reinicia", "se cae solo", "no levanta" o "está en crash loop".
---

# Servicio ECS en crash loop

Recorré los 5 patrones **en orden**. El 80% de los casos muere en los dos primeros.
No adivines: cada patrón se confirma o se descarta con una consulta.

## 1 · Variable de entorno faltante
```bash
aws ecs describe-task-definition --task-definition <servicio> \
  --query 'taskDefinition.containerDefinitions[0].environment'
aws ecs describe-task-definition --task-definition <servicio>:<rev-anterior> \
  --query 'taskDefinition.containerDefinitions[0].environment'
```
Señal: el contenedor sale con `exitCode 1` en menos de 5 segundos, sin tráfico.
Causa habitual: un despliegue manual fuera de IaC perdió una variable.

## 2 · Imagen inexistente o sin permiso de pull
El evento del servicio dice `CannotPullContainerError`. Revisar el tag y el rol de ejecución.

## 3 · Health check mal configurado
La tarea llega a RUNNING y algo la mata después.
Señal: reinicios cada 2-3 minutos, no cada 30 segundos.

## 4 · Memoria insuficiente
`exitCode 137` (OOMKilled). Revisar `memory` del task definition contra el uso real.

## 5 · Permisos del task role
El proceso arranca y falla en su primera llamada a AWS. El log lo dice explícitamente.

## Evidencia, siempre en este orden
```bash
aws ecs describe-services --cluster <c> --services <s> --query 'services[0].events[0:5].message'
T=$(aws ecs list-tasks --cluster <c> --service-name <s> --desired-status STOPPED --query 'taskArns[0]' --output text)
aws ecs describe-tasks --cluster <c> --tasks $T --query 'tasks[0].{razon:stoppedReason,exit:containers[0].exitCode}'
aws logs tail /<log-group> --since 15m
```

**Regla dura:** el evento de ECS dice QUÉ falló, el log dice POR QUÉ.
No se declara causa raíz sin el mensaje del log.

## Fix
Si la causa es drift respecto a IaC, **no se parchea a mano**: se corrige en Terraform y el
pipeline repone el estado declarado. Verificar después con `describe-services` y una consulta HTTP real.
