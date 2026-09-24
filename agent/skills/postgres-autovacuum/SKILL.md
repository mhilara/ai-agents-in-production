---
name: postgres-autovacuum
titulo: PostgreSQL con tablas infladas por falta de vacuum
sistema: postgresql
description: Las consultas se degradan con el tiempo y la tabla ocupa mucho mas de lo que deberia. Usar ante lentitud progresiva sin cambio de trafico.
---

# PostgreSQL con tablas infladas por falta de vacuum

## Sintoma
Consultas que antes tardaban milisegundos ahora tardan segundos, sin que haya
subido el trafico. La tabla crecio en disco mucho mas que en filas.

## Medir
```sql
SELECT relname, n_dead_tup, n_live_tup,
       round(n_dead_tup::numeric / nullif(n_live_tup,0), 2) AS ratio,
       last_autovacuum
FROM pg_stat_user_tables ORDER BY n_dead_tup DESC LIMIT 10;
```
Un ratio mayor a 0.2 en una tabla caliente es una alerta.

## Actuar
1. `VACUUM (ANALYZE, VERBOSE) tabla;` en ventana de bajo trafico.
2. Si el autovacuum no llega, bajar `autovacuum_vacuum_scale_factor` **en esa tabla**,
   no globalmente.
3. `VACUUM FULL` bloquea la tabla entera: solo con ventana acordada.
