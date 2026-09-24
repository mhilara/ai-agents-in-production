---
tipo: leccion
sistema: general
titulo: Subir el limite no es arreglar la causa
---

# Subir el limite no es arreglar la causa

Cada vez que un recurso se agota, la tentacion es subir el limite: mas memoria,
mas conexiones, mas disco. Funciona, y por eso es peligroso: el incidente
desaparece y la causa queda.

Tres casos reales terminaron igual. Memoria de un servicio que subimos dos veces
hasta descubrir una fuga. Conexiones de Postgres que subimos hasta encontrar
transacciones abiertas. Disco que ampliamos hasta ver que la retencion nunca se
aplicaba.

**Regla:** ampliar es contencion, no solucion. Se puede hacer para recuperar el
servicio, pero el incidente no se cierra hasta explicar por que se agoto.
