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
T=$(AWS_PROFILE=dataplat-ro aws ecs list-tasks --cluster dataplat-prod --service-name ingest-api \
  --region us-east-2 --query 'taskArns[0]' --output text)
ENI=$(AWS_PROFILE=dataplat-ro aws ecs describe-tasks --cluster dataplat-prod --tasks "$T" --region us-east-2 \
  --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value | [0]" --output text)
IP=$(AWS_PROFILE=dataplat-ro aws ec2 describe-network-interfaces --network-interface-ids "$ENI" \
  --region us-east-2 --query 'NetworkInterfaces[0].Association.PublicIp' --output text)
R=$(curl -s -m 8 "http://$IP:8080/")
case "$R" in ingest-api\ v*) ok "responde: $R";; *) bad "no responde bien ($IP): $R";; esac

echo "== Memoria vectorial"
H=$(.venv/bin/python demo/memory.py "ecs en crash loop" 2>/dev/null | grep -m1 '^\[')
case "$H" in *"crash loop"*) ok "recupera el runbook correcto";; *) bad "recuperacion rara: $H";; esac

echo
echo "IP para el curl de la demo:  http://$IP:8080/"
