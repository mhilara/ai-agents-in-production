# Guion de la demo — 10 minutos

Terminal en fuente grande. Tres pestañas abiertas: **agente**, **AWS**, **pipeline**.

---

## 0. Antes de empezar (no se muestra)

```bash
export AWS_PROFILE=dataplat-ro
cd ~/Documents/EMI-talk
```

---

## 1. Contexto — 1 min

> "Esto es un servicio de ingesta de una plataforma de datos. Corre en producción."

```bash
aws ecs describe-services --cluster dataplat-prod --services ingest-api \
  --query 'services[0].{running:runningCount,desired:desiredCount}'
curl http://<IP>:8080/
```
Esperado: `1/1` y `ingest-api ok`.

> "Y este es el agente. Está conectado a AWS con un rol de **solo lectura**. Recuerden eso."

```bash
aws sts get-caller-identity --query Arn --output text
```
Esperado: `.../dataplat-prod-agent-readonly/...`

---

## 2. La falla — 1 min

> "Alguien despliega a mano, fuera del pipeline. Pasa en todas las empresas."

```bash
AWS_PROFILE=dataplat-admin ./demo/break.sh
```

Esperar ~60 s. Mientras tanto se habla de la capa de memoria (paso 3).

---

## 3. El agente recuerda — 1 min

> "Antes de mirar AWS, el agente mira lo que ya sabe."

```bash
.venv/bin/python demo/memory.py "el servicio se reinicia todo el tiempo en ECS"
```
Esperado: primero el runbook **"Servicio ECS en crash loop"**, score ~0.60.

> "No es un buscador de texto. Yo nunca escribí 'crash loop'. Escribí 'se reinicia todo el tiempo'."

---

## 4. Diagnóstico, solo lectura — 3 min

Seguir el runbook **en orden**, no adivinar.

```bash
# 1. Qué dice ECS
aws ecs describe-services --cluster dataplat-prod --services ingest-api \
  --query 'services[0].events[0:5].message' --output text

# 2. Qué tasks murieron y con qué código
T=$(aws ecs list-tasks --cluster dataplat-prod --service-name ingest-api \
     --desired-status STOPPED --query 'taskArns[0]' --output text)
aws ecs describe-tasks --cluster dataplat-prod --tasks $T \
  --query 'tasks[0].{razon:stoppedReason,exit:containers[0].exitCode}'

# 3. Por qué  <- acá está la causa raíz
aws logs tail /dataplat/prod/ingest-api --since 5m
```
Esperado: `exit 1` y `FATAL: APP_MESSAGE no esta definida`.

> "El evento de ECS dice QUÉ falló. El log dice POR QUÉ. No se declara causa raíz hasta ver el log."

Confirmar el drift contra IaC:
```bash
aws ecs describe-task-definition --task-definition ingest-api:2 \
  --query 'taskDefinition.containerDefinitions[0].environment'
aws ecs describe-task-definition --task-definition ingest-api:1 \
  --query 'taskDefinition.containerDefinitions[0].environment'
```

---

## 5. El guardarraíl — 1 min  ⭐ el momento de la charla

> "El agente ya sabe el fix. Que lo intente."

```bash
aws ecs update-service --cluster dataplat-prod --service ingest-api --desired-count 2
```
Esperado, en vivo:
```
AccessDeniedException ... with an explicit deny in an identity-based policy
```

> "La IAM es el guardarraíl real. El prompt es doctrina; los permisos son el freno."

---

## 6. El fix, por pipeline — 2 min

> "No se parcha a mano. Se repone el estado declarado."

```bash
git commit --allow-empty -m "restore ingest-api to declared state"
git push          # push a main -> OIDC -> terraform apply
gh run watch
```

**Plan B si no hay internet o el runner tarda:**
```bash
AWS_PROFILE=dataplat-op terraform -chdir=demo/terraform apply -auto-approve
```

Verificar:
```bash
aws ecs describe-services --cluster dataplat-prod --services ingest-api \
  --query 'services[0].{running:runningCount,taskdef:taskDefinition}'
curl http://<IP>:8080/
```

---

## 7. El agente aprende — 1 min

```bash
.venv/bin/python demo/memory.py remember demo/learned/incidente-de-hoy.md
.venv/bin/python demo/memory.py "qué pasó hoy con ingest-api"
```

> "El próximo incidente parecido empieza acá, no desde cero. Eso es lo que separa un agente
> de un chatbot: el chatbot olvida."

---

## Planes B

| Si falla | Hacer |
|---|---|
| No hay internet | Pasar al video de respaldo (`slides/respaldo.mov`) |
| Qdrant no responde | `demo/memory.py` tiene los .md en disco: abrir el runbook y leerlo |
| El task no muere en 60 s | Seguir hablando de memoria; revisar a los 90 s |
| El pipeline tarda | Plan B con `terraform apply` local |
| AWS no responde | Video de respaldo |
