---
name: postgres-conexiones-agotadas
titulo: PostgreSQL sin conexiones disponibles
sistema: postgresql
description: La base rechaza conexiones nuevas con FATAL: remaining connection slots are reserved. Usar cuando la aplicacion no puede conectar o el pool se llena.
---

# PostgreSQL sin conexiones disponibles

## Medir primero
```sql
SELECT count(*), state FROM pg_stat_activity GROUP BY state;
SELECT setting FROM pg_settings WHERE name = 'max_connections';
```
Si la mayoria esta en `idle in transaction`, el problema no es el limite: es una
transaccion que alguien dejo abierta.

## Encontrar al culpable
```sql
SELECT pid, now() - xact_start AS duracion, query
FROM pg_stat_activity WHERE state = 'idle in transaction' ORDER BY 2 DESC;
```

## Actuar
1. Terminar solo las sesiones ociosas de mas de 15 minutos, una por una.
2. Subir `max_connections` es el ultimo recurso: cada conexion cuesta memoria.
3. La solucion real es un pool del lado de la aplicacion.

**Nunca** reiniciar la instancia para liberar conexiones: se pierden transacciones en vuelo.
