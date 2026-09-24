---
name: elasticsearch-shards-sin-asignar
titulo: Elasticsearch con shards sin asignar
sistema: elasticsearch
description: El cluster esta en rojo o amarillo y hay shards sin asignar. Usar ante perdida de disponibilidad de busqueda.
---

# Elasticsearch con shards sin asignar

## Diagnosticar
```
GET _cluster/health
GET _cluster/allocation/explain
```
El `allocation/explain` dice exactamente por que no se asigna. Leerlo antes de
tocar nada: casi siempre da la respuesta completa.

## Causas habituales
- Disco por encima del umbral de inundacion: el cluster se pone en solo lectura.
- Menos nodos que replicas configuradas.
- Un nodo que se fue y no volvio.

## Actuar
1. Si es disco: liberar espacio y **despues** quitar el bloqueo de solo lectura.
2. Rojo significa datos no disponibles: es incidente. Amarillo significa sin
   redundancia: es urgente pero no caida.
