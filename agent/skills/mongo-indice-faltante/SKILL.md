---
name: mongo-indice-faltante
titulo: MongoDB haciendo escaneos completos
sistema: mongodb
description: Consultas lentas en MongoDB por falta de indice. Usar cuando una coleccion responde lento sin haber crecido de golpe.
---

# MongoDB haciendo escaneos completos

## Encontrar la consulta
```js
db.setProfilingLevel(1, { slowms: 100 })
db.system.profile.find().sort({ millis: -1 }).limit(5)
```

## Confirmar el escaneo
```js
db.coleccion.find({ ... }).explain("executionStats")
```
Si `totalDocsExamined` es mucho mayor que `nReturned`, esta escaneando.

## Crear el indice sin bloquear
```js
db.coleccion.createIndex({ campo: 1 }, { background: true })
```

**Antes de crear:** revisar si ya existe uno que sirva. Cada indice cuesta en
escritura y en disco. Un indice de mas es deuda silenciosa.
