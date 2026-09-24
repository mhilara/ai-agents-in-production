---
name: valkey-evicciones
titulo: Valkey expulsando claves por memoria
sistema: valkey
description: La cache pierde claves antes de tiempo y la tasa de aciertos cae. Usar cuando suben las latencias porque la cache dejo de servir.
---

# Valkey expulsando claves por memoria

## Medir
```
INFO memory     -> used_memory, maxmemory, maxmemory_policy
INFO stats      -> evicted_keys, keyspace_hits, keyspace_misses
```
Tasa de aciertos = hits / (hits + misses). Por debajo de 0.8 la cache dejo de
cumplir su funcion.

## Antes de agregar memoria
1. Buscar claves sin TTL: son las que nunca salen y desplazan al resto.
2. Revisar `maxmemory_policy`. Para cache, `allkeys-lru`. Para datos que no se
   pueden perder, la cache no es el lugar.
3. Buscar claves gigantes con `--bigkeys`.

**Nunca** usar `KEYS *` en produccion: bloquea el servidor.
