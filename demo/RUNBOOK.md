# Guion de la demo — 10 minutos, 3 actos

Terminal en 18-20 pt. Tres pestañas: **agente** · **AWS** · **pipeline**.
La IP del servicio la imprime `./preflight.sh`.

```bash
export AWS_PROFILE=dataplat-ro     # el agente vive acá
cd ~/Documents/EMI-talk
```

---

# ACTO 1 · Despliegue  — 3 min

> "Esto es un servicio de ingesta de una plataforma de datos. Está en producción, ahora."

```bash
curl http://<IP>:8080/
```
→ `ingest-api v1.4.0 | ok`

> "Le voy a pedir al agente que despliegue la versión nueva. En español, sin tocar la consola."

**Prompt al agente:**
```
Desplegá la versión 1.5.0 de ingest-api.
```

El agente edita `demo/terraform/terraform.tfvars`, commitea y hace push a `main`.

```bash
gh run watch
```

> "Nadie guardó una llave de AWS en GitHub. El pipeline se identifica con OIDC y AWS le da
> credenciales temporales para esta corrida y nada más."

```bash
curl http://<IP>:8080/
```
→ `ingest-api v1.5.0 | ok`   ⬅ **el despliegue terminó**

---

# ACTO 2 · Incidente  — 4 min

> "Ahora la parte que pasa en todas las empresas: alguien despliega a mano, apurado, fuera del pipeline."

```bash
AWS_PROFILE=dataplat-admin ./demo/break.sh
```

Mientras tarda ~60 s, se habla de memoria. Después:

**Prompt al agente:**
```
ingest-api se está reiniciando todo el tiempo. ¿Qué pasa?
```

**1 · El agente recuerda** (RAG, no búsqueda de texto):
```bash
.venv/bin/python demo/memory.py "el servicio se reinicia todo el tiempo en ECS"
```
→ primero el runbook **"Servicio ECS en crash loop"**, score ~0.60

> "Yo nunca escribí 'crash loop'. Lo encontró por significado."

**2 · Diagnóstico, en el orden del runbook:**
```bash
aws ecs describe-services --cluster dataplat-prod --services ingest-api \
  --query 'services[0].events[0:5].message' --output text

T=$(aws ecs list-tasks --cluster dataplat-prod --service-name ingest-api \
     --desired-status STOPPED --query 'taskArns[0]' --output text)
aws ecs describe-tasks --cluster dataplat-prod --tasks $T \
  --query 'tasks[0].{razon:stoppedReason,exit:containers[0].exitCode}'

aws logs tail /dataplat/prod/ingest-api --since 5m
```
→ `exit 1` · `FATAL: APP_MESSAGE no esta definida`

> "El evento de ECS dice QUÉ falló. El log dice POR QUÉ. No hay causa raíz hasta ver el log."

**3 · El guardarraíl** ⭐ *el momento de la charla*
```bash
aws ecs update-service --cluster dataplat-prod --service ingest-api --desired-count 2
```
→ `AccessDeniedException ... explicit deny in an identity-based policy`

> "El agente sabe el fix y no puede aplicarlo. El prompt es doctrina: un modelo lo puede ignorar.
> Los permisos no se ignoran."

---

# ACTO 3 · Fix y aprendizaje  — 3 min

> "El fix no se parcha a mano. Se repone el estado declarado, por el mismo pipeline."

```bash
git commit --allow-empty -m "restore ingest-api to declared state"
git push && gh run watch
curl http://<IP>:8080/
```

**Plan B si el runner tarda o no hay internet:**
```bash
AWS_PROFILE=dataplat-op terraform -chdir=demo/terraform apply -auto-approve
```

**El agente guarda lo aprendido:**
```bash
.venv/bin/python demo/memory.py remember demo/learned/incidente-de-hoy.md
.venv/bin/python demo/memory.py "qué pasó hoy con ingest-api"
```

> "El próximo incidente parecido no empieza de cero. Eso separa un agente de un chatbot:
> el chatbot olvida. Y el agente propone — la persona autoriza."

---

## Planes B

| Si falla | Hacer |
|---|---|
| No hay internet | Video de respaldo (`slides/respaldo.mov`) |
| El pipeline tarda | `terraform apply` local con `dataplat-op` |
| Qdrant no responde | Abrir el runbook en `demo/seed-memory/` y leerlo |
| El task no muere en 60 s | Seguir hablando de memoria, revisar a los 90 s |
| AWS no responde | Video de respaldo |
