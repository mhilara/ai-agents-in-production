---
description: Auditoría de Security Groups. Reporta, no corrige.
---

Listá todas las reglas de entrada con origen `0.0.0.0/0` o `::/0`.

Para cada una: grupo, puerto, protocolo, a qué recursos está asociado y si el puerto es de
administración (22, 3389, 5432, 3306, 27017, 6379, 9200, 9092).

Ordená por riesgo: puertos de administración abiertos al mundo primero.

Devolvé una tabla. No modifiques ninguna regla: una regla que parece sobrante puede ser la que
mantiene viva una integración. El cierre lo decide una persona, caso por caso.
