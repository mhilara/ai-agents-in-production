# El agente: instrucciones, memoria, skills y comandos

Lo que hace a un agente operativo no es el modelo. Es esto.

| Archivo | Qué es |
|---|---|
| `CLAUDE.md` | Las reglas duras. Se cargan en cada sesión: qué herramienta va primero y qué está prohibido. |
| `MEMORY.md` | El índice de la memoria operativa. Corto a propósito. |
| `memory/` | Un archivo por tema: incidentes, lecciones y las correcciones del operador, cada una con su porqué. |
| `skills/` | Los runbooks que el agente carga según la situación. Un procedimiento, en orden, con sus comandos. |
| `commands/` | Los comandos de operación del día a día. |
| `.mcp.json.example` | Cómo se conectan las herramientas. El secreto se lee del entorno, **nunca está en el archivo**. |

Nada acá contiene credenciales, IDs de cuenta ni datos de ninguna empresa.
