---
id: rb-verificar-antes-de-alarmar
tipo: leccion
sistema: general
titulo: Verificar antes de declarar algo caido
---

En un checklist diario, el chequeo automatico marco en rojo la base vectorial: no respondia.

Antes de abrir un incidente, se entro al host: el motor estaba sano, respondia en localhost.
La causa era un Security Group que no permitia el trafico desde la VPN.

Leccion: "no responde desde donde yo estoy" no es "esta caido". Diferenciar siempre
disponibilidad del servicio de alcanzabilidad desde el cliente. El costo de verificar es un minuto;
el costo de un falso positivo es despertar a tres personas.

Relacionado: un 401 puede ser rate limit y no falta de permiso. "No tengo acceso" casi nunca es
cierto: medir con todas las identidades antes de decirlo.
