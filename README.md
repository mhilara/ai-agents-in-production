# Agentes de IA que operan producción

Demo del 1er Simposio Internacional de Inteligencia Artificial — EMI, La Paz, 24/09/2026.

Un servicio en ECS Fargate se rompe por un deploy manual fuera de IaC. Un agente con acceso de
**solo lectura** lo diagnostica usando runbooks recuperados de una base vectorial, y el fix vuelve
por el pipeline. El agente propone; la persona autoriza.

## Qué hay acá

| Carpeta | Qué es |
|---|---|
| `demo/terraform/` | VPC, ECS Fargate, CloudWatch, roles IAM y budget. Sin NAT ni ALB: la demo cuesta centavos. |
| `demo/memory.py` | Memoria vectorial (Qdrant + embeddings locales): `seed`, buscar, `remember`. |
| `demo/seed-memory/` | Runbooks y recaps de ejemplo que se indexan. |
| `demo/break.sh` | Inyecta la falla: un deploy manual que pierde una variable de entorno. |
| `.github/workflows/` | Push a `main` → OIDC → `terraform apply`. Cero llaves de larga duración. |

## Correr

```bash
cp demo/terraform/backend.hcl.example demo/terraform/backend.hcl   # tu bucket de state
terraform -chdir=demo/terraform init -backend-config=backend.hcl
terraform -chdir=demo/terraform apply

python3 -m venv .venv && .venv/bin/pip install "qdrant-client[fastembed]"
cp .env.example .env                                               # tu Qdrant
.venv/bin/python demo/memory.py seed
.venv/bin/python demo/memory.py "ecs en crash loop"
```

Nada de este repo contiene credenciales, IDs de cuenta ni datos de ninguna empresa.
