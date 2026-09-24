---
tipo: incidente
sistema: aws
titulo: Puerto de administracion abierto al mundo
---

# Puerto de administracion abierto al mundo

Una auditoria de Security Groups encontro tres reglas con origen 0.0.0.0/0 sobre
puertos de administracion. Ninguna era intencional: quedaron de pruebas viejas.

El cierre no fue inmediato. Una de las tres sostenia una integracion activa que
nadie habia documentado, y cerrarla habria cortado un flujo de produccion.

**Como se resolvio:** se identifico el consumidor real de cada regla antes de
cerrarla, y se reemplazo por acceso por SSM, sin puertos abiertos.

**Leccion:** una regla que parece sobrante puede ser la que mantiene vivo algo.
Auditar es listar; cerrar es una decision con contexto.
