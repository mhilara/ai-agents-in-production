---
name: postgres-replica-atrasada
titulo: Replica de PostgreSQL atrasada
sistema: postgresql
description: La replica de lectura devuelve datos viejos o el lag crece sin parar. Usar cuando los reportes muestran informacion desactualizada.
---

# Replica de PostgreSQL atrasada

## Medir el retraso real
```sql
-- en la replica
SELECT now() - pg_last_xact_replay_timestamp() AS retraso;
```

## Causas, en orden de frecuencia
1. Una consulta larga en la replica bloquea la aplicacion de cambios.
2. El primario genera WAL mas rapido de lo que la red transporta.
3. Disco de la replica mas lento que el del primario.

## Actuar
- Identificar y cortar la consulta larga antes de tocar configuracion.
- `hot_standby_feedback` evita cancelaciones pero infla el primario: es un canje,
  no una mejora gratis.

**Regla:** una replica atrasada que nadie mide es una replica que miente.
