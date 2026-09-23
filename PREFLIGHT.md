# Checklist — jueves 24/09, antes de las 14:00

Correr `./preflight.sh` y que todo diga OK.

- [ ] `AWS_PROFILE=dataplat-ro aws sts get-caller-identity` → rol readonly
- [ ] Servicio `ingest-api` en 1/1 y `curl` responde `ingest-api ok`
- [ ] Task definition en **revisión 1** (si quedó en 2, correr el fix)
- [ ] `memory.py "ecs en crash loop"` → primero el runbook de ECS
- [ ] `break.sh` probado hoy, al menos una vez
- [ ] Video de respaldo en la laptop, **no en la nube**
- [ ] Fuente de la terminal en 18-20 pt, tema claro si el proyector lava los colores
- [ ] Hotspot del celular listo y probado
- [ ] Notificaciones y Slack/WhatsApp cerrados
- [ ] Cargador enchufado
- [ ] Adaptador HDMI / USB-C probado en el auditorio

## Después de la charla — **no olvidar**

```bash
./destroy.sh
```
