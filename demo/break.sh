#!/usr/bin/env bash
# Simula lo que pasa de verdad: alguien despliega a mano, fuera de IaC,
# y en el camino se pierde una variable de entorno.
# Resultado: crash loop en ingest-api.
set -euo pipefail

PROFILE="${AWS_PROFILE:-dataplat-admin}"
REGION=us-east-2
CLUSTER=dataplat-prod
SERVICE=ingest-api

echo "==> Desplegando ingest-api (hotfix manual)…"

CURRENT=$(aws ecs describe-task-definition --task-definition "$SERVICE" \
  --region "$REGION" --profile "$PROFILE" --query 'taskDefinition' --output json)

# El "error humano": se cae APP_MESSAGE del task definition.
BROKEN=$(echo "$CURRENT" | python3 -c '
import json,sys
td = json.load(sys.stdin)
for c in td["containerDefinitions"]:
    c["environment"] = [e for e in c.get("environment", []) if e["name"] != "APP_MESSAGE"]
for k in ["taskDefinitionArn","revision","status","requiresAttributes","compatibilities",
          "registeredAt","registeredBy","deregisteredAt"]:
    td.pop(k, None)
print(json.dumps(td))
')

REV=$(aws ecs register-task-definition --cli-input-json "$BROKEN" \
  --region "$REGION" --profile "$PROFILE" \
  --query 'taskDefinition.taskDefinitionArn' --output text)

aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" \
  --task-definition "$REV" --force-new-deployment \
  --region "$REGION" --profile "$PROFILE" >/dev/null

echo "==> Desplegado: ${REV##*/}"
echo "==> Listo. El servicio va a empezar a reiniciarse en ~60s."
