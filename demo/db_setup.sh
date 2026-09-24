#!/usr/bin/env bash
# Crea dos bases de prueba en el motor Postgres y las carga con datos.
# La credencial se saca de Secrets Manager en el momento de usarla: nunca se
# escribe en disco ni queda en el historial del shell.
set -euo pipefail
cd "$(dirname "$0")/.."

export AWS_PROFILE="${AWS_PROFILE:-dataplat-admin}"
REGION=us-east-2
SECRETO=dataplat-prod/postgres/master

HOST=$(terraform -chdir=demo/terraform output -raw postgres_host)
CRED=$(aws secretsmanager get-secret-value --secret-id "$SECRETO" --region "$REGION" \
        --query SecretString --output text)
export PGUSER=$(echo "$CRED" | python3 -c 'import json,sys;print(json.load(sys.stdin)["username"])')
export PGPASSWORD=$(echo "$CRED" | python3 -c 'import json,sys;print(json.load(sys.stdin)["password"])')
export PGHOST="$HOST" PGPORT=5432 PGCONNECT_TIMEOUT=10

echo "==> Motor: $HOST"

for BASE in ventas_analytics eventos_ingesta; do
  psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$BASE'" | grep -q 1 \
    || psql -d postgres -c "CREATE DATABASE $BASE" >/dev/null
  echo "    base $BASE lista"
done

psql -d ventas_analytics >/dev/null <<'SQL'
CREATE TABLE IF NOT EXISTS clientes (
  id serial PRIMARY KEY, nombre text NOT NULL, ciudad text, alta date DEFAULT current_date);
CREATE TABLE IF NOT EXISTS pedidos (
  id serial PRIMARY KEY, cliente_id int REFERENCES clientes(id),
  monto numeric(12,2) NOT NULL, creado timestamptz DEFAULT now());
TRUNCATE pedidos, clientes RESTART IDENTITY CASCADE;
INSERT INTO clientes (nombre, ciudad) VALUES
  ('Andina Retail','La Paz'), ('Cochabamba Foods','Cochabamba'),
  ('Santa Cruz Logistica','Santa Cruz'), ('Altiplano Energia','El Alto'),
  ('Tarija Vinos','Tarija');
INSERT INTO pedidos (cliente_id, monto)
SELECT (random()*4)::int + 1, round((random()*9000 + 500)::numeric, 2)
FROM generate_series(1, 2000);
SQL
echo "    ventas_analytics: 5 clientes, 2000 pedidos"

psql -d eventos_ingesta >/dev/null <<'SQL'
CREATE TABLE IF NOT EXISTS eventos (
  id bigserial PRIMARY KEY, servicio text NOT NULL, nivel text NOT NULL,
  mensaje text, ocurrido timestamptz DEFAULT now());
TRUNCATE eventos RESTART IDENTITY;
INSERT INTO eventos (servicio, nivel, mensaje, ocurrido)
SELECT (ARRAY['ingest-api','checkout','facturacion','notificaciones'])[(random()*3)::int + 1],
       (ARRAY['INFO','INFO','INFO','WARN','ERROR'])[(random()*4)::int + 1],
       'evento sintetico de la demo',
       now() - (random() * interval '72 hours')
FROM generate_series(1, 5000);
CREATE INDEX IF NOT EXISTS eventos_ocurrido_idx ON eventos (ocurrido DESC);
SQL
echo "    eventos_ingesta: 5000 eventos, indice por fecha"

echo
echo "==> Resumen"
psql -d postgres -c "SELECT datname AS base, pg_size_pretty(pg_database_size(datname)) AS tamano
  FROM pg_database WHERE datname IN ('ventas_analytics','eventos_ingesta','plataforma') ORDER BY 1;"
psql -d ventas_analytics -c "SELECT c.ciudad, count(*) AS pedidos, round(sum(p.monto),2) AS total
  FROM pedidos p JOIN clientes c ON c.id = p.cliente_id GROUP BY 1 ORDER BY 3 DESC;"
psql -d eventos_ingesta -c "SELECT servicio, nivel, count(*) FROM eventos GROUP BY 1,2 ORDER BY 1,2 LIMIT 8;"
