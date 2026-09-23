---
id: rb-mongo-disco
tipo: runbook
sistema: mongodb
titulo: MongoDB con disco por encima del 85%
---

Metodo de DBA: medir el cuello de botella real antes de tocar nada.

1. Medir por coleccion: `db.stats()` y `db.<col>.stats()` -> `storageSize` vs `size`.
2. Buscar colecciones sin politica de retencion. En un caso real, una coleccion de 52 millones de
   documentos crecia sin TTL index.
3. Buscar buffers huerfanos: archivos temporales de procesos que murieron a medias.
4. Respaldar la definicion de los indices ANTES de cualquier compactacion.
5. Recien entonces: purga por lotes, luego `compact` nodo por nodo, empezando por un secundario.

Nunca `drop` de colecciones. Nunca compactar el primario primero.

Caso de referencia: replica set de 3 nodos al 89-95%. Un buffer huerfano de 30 GB mas la coleccion
sin TTL. Despues de purga y compact quedo en 55-62%.
