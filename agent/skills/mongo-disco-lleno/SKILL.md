---
name: mongo-disco-lleno
titulo: MongoDB con disco al límite
sistema: mongodb
description: MongoDB con disco por encima del 85%. Usar cuando haya alerta de disco, escrituras rechazadas o el operador diga que "Mongo está lleno" o "lento".
---

# MongoDB con disco al límite

Método de DBA: medir el cuello de botella real **antes** de tocar nada.

## 1 · Medir, por colección
```js
db.stats()
db.<coleccion>.stats()   // comparar storageSize contra size
```

## 2 · Buscar el origen del crecimiento
- Colecciones sin política de retención (sin índice TTL). Un caso real: 52 millones de documentos.
- Buffers huérfanos: archivos temporales de procesos que murieron a medias. Un caso real: 30 GB.
- Índices que ya nadie usa.

## 3 · Respaldar antes de tocar
```js
db.<coleccion>.getIndexes()   // guardar la salida ANTES de cualquier compactación
```

## 4 · Recién entonces, actuar
1. Purga por lotes, nunca de una sola vez.
2. `compact` **nodo por nodo**, empezando por un secundario.
3. El primario, al final, y solo después de verificar los secundarios.

## Prohibido
- `drop` de colecciones.
- Compactar el primario primero.
- Tocar sin haber respaldado la definición de los índices.
