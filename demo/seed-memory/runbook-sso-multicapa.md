---
id: rb-sso-multicapa
tipo: caso
sistema: auth
titulo: Login SSO roto por seis causas encadenadas
---

Un login de produccion caido rara vez tiene una sola causa. En este caso fueron seis capas,
destapadas de a una, y cada fix se aplico con OK explicito del operador:

1. Una variable de configuracion faltante en el servicio de autenticacion.
2. El store de autorizacion vacio: no habia politicas cargadas.
3. Un documento duplicado que bloqueaba el alta de usuarios nuevos.
4. Un cliente OAuth que nunca se registro en el proveedor.
5. Un punto unico de falla: el servicio corria con una sola replica.
6. Una libreria interna configurada sin credenciales.

Metodo: no se avanza a la capa siguiente sin verificar que la anterior quedo resuelta en runtime.
Nunca se dice "arreglado" antes de push, build verde y verificacion en el ambiente real.
