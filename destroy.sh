#!/usr/bin/env bash
# Borra todo lo que se levanto para la charla. Correr apenas termine.
set -euo pipefail
cd "$(dirname "$0")"

export AWS_PROFILE="${AWS_PROFILE:-dataplat-admin}"

echo "==> Destruyendo la infraestructura de la demo…"
terraform -chdir=demo/terraform destroy -auto-approve

echo "==> Borrando la coleccion vectorial de la demo…"
set -a; . ./.env; set +a
curl -s -X DELETE -H "api-key: $QDRANT_API_KEY" \
  "$QDRANT_URL/collections/$QDRANT_COLLECTION" >/dev/null
echo "    coleccion $QDRANT_COLLECTION borrada (dh-devops NO se toca)"

echo "==> Vaciando y borrando el bucket de state…"
BUCKET=$(grep -o '"[^"]*"' demo/terraform/backend.hcl | tr -d '"')
aws s3 rm "s3://$BUCKET" --recursive >/dev/null 2>&1 || true
aws s3api delete-objects --bucket "$BUCKET" --delete \
  "$(aws s3api list-object-versions --bucket "$BUCKET" \
    --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' --output json)" >/dev/null 2>&1 || true
aws s3api delete-bucket --bucket "$BUCKET" --region us-east-2 >/dev/null 2>&1 || true

echo
echo "==> Listo. Verificar que no quede nada:"
aws ecs list-clusters --region us-east-2 --query 'clusterArns' --output text
aws ec2 describe-vpcs --region us-east-2 --query 'Vpcs[?!IsDefault].VpcId' --output text
echo "(vacio = todo limpio)"
