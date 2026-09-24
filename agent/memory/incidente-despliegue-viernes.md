---
tipo: incidente
sistema: general
titulo: El despliegue que nadie pudo revertir
---

# El despliegue que nadie pudo revertir

Un cambio se aplico un viernes por la tarde. Funciono. El lunes el servicio
fallaba de forma intermitente y nadie recordaba que se habia cambiado.

El problema no fue el dia: fue que el cambio no dejo rastro. No hubo commit, no
hubo plan, no hubo forma de revertir en un paso.

**Leccion:** lo que importa no es cuando se despliega, es si se puede revertir en
un minuto. Un cambio reversible se puede aplicar un viernes. Uno irreversible no
se deberia aplicar nunca sin dos personas.
