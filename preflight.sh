#!/usr/bin/env bash
# Chequeo de 20 segundos antes de subir al escenario.
cd "$(dirname "$0")"
ok() { printf '  \033[32mOK\033[0m   %s\n' "$1"; }
bad() { printf '  \033[31mMAL\033[0m  %s\n' "$1"; }

echo "== Identidad del agente"
ARN=$(AWS_PROFILE=dataplat-ro aws sts get-caller-identity --query Arn --output text 2>/dev/null)
case "$ARN" in *agent-readonly*) ok "rol de solo lectura";; *) bad "rol inesperado: $ARN";; esac

echo "== Servicio"
read -r RUN DEP TD <<<"$(AWS_PROFILE=dataplat-ro aws ecs describe-services --cluster dataplat-prod \
  --services ingest-api --region us-east-2 \
  --query 'services[0].[runningCount,length(deployments),taskDefinition]' --output text)"
[ "$RUN" -ge 1 ] 2>/dev/null && ok "ingest-api corriendo ($RUN)" || bad "ingest-api en $RUN tareas"
[ "$DEP" = "1" ] && ok "sin despliegue en curso" || bad "$DEP despliegues activos - esperar a que estabilice"

# El invariante real no es el numero de revision, es que la variable exista.
ENVV=$(AWS_PROFILE=dataplat-ro aws ecs describe-task-definition --task-definition "$TD" --region us-east-2 \
  --query "taskDefinition.containerDefinitions[0].environment[?name=='APP_MESSAGE'].value | [0]" --output text)
case "$ENVV" in None|"") bad "${TD##*/} SIN APP_MESSAGE - correr el fix";; *) ok "${TD##*/} con APP_MESSAGE";; esac

echo "== HTTP"
URL="http://dataplat-prod-alb-256338754.us-east-2.elb.amazonaws.com/"
R=$(curl -s -m 10 "$URL" | grep -o "ingest-api" | head -1)
[ -n "$R" ] && R="ingest-api v$(curl -s -m 10 "$URL" | grep -o 'v[0-9.]*' | head -1 | tr -d v)"
case "$R" in ingest-api*) ok "responde: $R";; *) bad "no responde: ${R:-vacio}";; esac

echo "== Memoria vectorial"
H=$(.venv/bin/python scripts/qdrant_search.py "el servicio se reinicia todo el tiempo" 2>/dev/null | grep -m1 "crash loop")
case "$H" in *"crash loop"*) ok "recupera el runbook correcto";; *) bad "recuperacion rara: $H";; esac

echo
echo "URL para el curl de la demo:  $URL"
