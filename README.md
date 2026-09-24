<div align="center">

# Agentes de IA que operan producción

**RAG, memoria y automatización empresarial**

Charla y demo del 1er Simposio Internacional de Inteligencia Artificial<br>
Escuela Militar de Ingeniería · La Paz, Bolivia · 24 de septiembre de 2026

[![Ver la presentación](https://img.shields.io/badge/Ver_la_presentación-FF9900?style=for-the-badge&logo=googleslides&logoColor=black)](https://mhilara.github.io/ai-agents-in-production/)
[![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)](demo/terraform)
[![Qdrant](https://img.shields.io/badge/Qdrant-DC244C?style=for-the-badge&logo=qdrant&logoColor=white)](scripts)

</div>

---

Un servicio en **ECS Fargate** se rompe por un despliegue manual fuera de IaC. Un agente con acceso de
**solo lectura** lo diagnostica usando runbooks recuperados de una base vectorial, la **IAM lo frena**
cuando intenta escribir, y el arreglo vuelve por el pipeline. El agente propone; la persona autoriza.

Todo lo que ves acá corre de verdad. Podés levantarlo en tu propia cuenta de AWS por menos de un dólar.

## Estructura

```
agent/                    el agente: lo que lo convierte en operador
├── CLAUDE.md             las reglas duras · se cargan en cada sesión
├── MEMORY.md             índice corto de lo aprendido
├── memory/               un archivo por tema: incidentes, lecciones, correcciones
├── recaps/               resúmenes de sesión
├── skills/               un runbook por situación, con sus comandos en orden
├── commands/             los comandos de operación del día a día
└── .mcp.json.example     cómo se conectan las herramientas

scripts/                  la memoria vectorial
├── qdrant_index.py       parte en fragmentos, calcula embeddings e indexa
└── qdrant_search.py      busca por significado, no por palabra exacta

demo/                     la demo en vivo
├── terraform/            VPC, ECS Fargate, CloudWatch, roles IAM y budget
├── break.sh              inyecta la falla: un despliegue que pierde una variable
├── learned/              lo que el agente aprende durante la demo
└── RUNBOOK.md            el guion, comando por comando, con planes B

slides/ · docs/           la presentación (docs/ es lo que publica GitHub Pages)
```

## Qué mirar primero

| Si te interesa | Abrí |
|---|---|
| Cómo se le escriben las reglas a un agente | [`agent/CLAUDE.md`](agent/CLAUDE.md) |
| Cómo se escribe un runbook que un agente pueda seguir | [`agent/skills/ecs-crash-loop/SKILL.md`](agent/skills/ecs-crash-loop/SKILL.md) |
| Cómo se guarda una lección para que no se pierda | [`agent/memory/`](agent/memory) |
| Cómo se indexa y se recupera por significado | [`scripts/qdrant_index.py`](scripts/qdrant_index.py) |
| Cómo se frena a un agente con permisos, no con prompts | [`demo/terraform/iam.tf`](demo/terraform/iam.tf) |
| Cómo se despliega sin guardar una sola llave | [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) |

## Levantarlo

**1 · La infraestructura** (menos de US$ 1 si la destruís el mismo día)

```bash
cp demo/terraform/backend.hcl.example demo/terraform/backend.hcl   # tu bucket de state
terraform -chdir=demo/terraform init -backend-config=backend.hcl
terraform -chdir=demo/terraform apply
```

**2 · La memoria vectorial**

```bash
python3 -m venv .venv && .venv/bin/pip install "qdrant-client[fastembed]"
cp .env.example .env                                               # tu Qdrant
.venv/bin/python scripts/qdrant_index.py
.venv/bin/python scripts/qdrant_search.py "el servicio se reinicia todo el tiempo"
```

```
0.503  Servicio ECS en crash loop        runbook/ecs
0.439  Recap - semana del 15 de septiembre   recap/general
```

La pregunta no contiene ninguna palabra del documento. La coincidencia es por significado.

**3 · Al terminar**

```bash
./destroy.sh
```

## Ver la memoria por dentro

El panel de Qdrant permite mirar el espacio vectorial, que es la parte que normalmente queda invisible.

| Pestaña | Qué muestra |
|---|---|
| **Collections → `dataplat-runbooks`** | 32 fragmentos de 11 documentos, 384 dimensiones, distancia coseno |
| **Visualize** | cada fragmento como un punto en 2D. Agrupá por `tipo` o por `sistema` y se ven los clusters: lo de Kafka junto, lo de Mongo junto, los recaps aparte |
| **Graph** | la red de similitud entre fragmentos: qué documento se parece a cuál y por qué se recuperan juntos |

En **Visualize**, este payload da buenos resultados:

```json
{ "limit": 300, "color_by": { "payload": "tipo" } }
```

y para ver los clusters por motor de datos:

```json
{ "limit": 300, "color_by": { "payload": "sistema" } }
```

Cada punto lleva `tipo`, `sistema`, `titulo` y `origen`, así que al hacer clic se ve de qué archivo del
repositorio salió.

## Cómo está construido

| Capa | Qué se usó |
|---|---|
| Cómputo | ECS Fargate · 0,25 vCPU / 0,5 GB · sin NAT y sin ALB, para que la demo cueste centavos |
| IaC | Terraform, con el estado en S3 y bloqueo nativo |
| CI/CD | GitHub Actions con OIDC: **ninguna credencial de AWS guardada en el repositorio** |
| Identidad | tres roles separados con permission boundary y `Deny` explícito sobre producción e IAM |
| Memoria | Qdrant + embeddings de 384 dimensiones calculados **en local**: no se envía texto a ningún proveedor |
| Agente | Claude Code con herramientas por MCP |

## Confidencialidad

Nada en este repositorio contiene credenciales, identificadores de cuenta, nombres de clientes ni datos
de ninguna empresa. Los casos reales están anonimizados y las cifras redondeadas.

---

<div align="center">
<sub><b>Milton Hilara Mamani</b> · DevOps &amp; Data Platform Engineer · <a href="https://github.com/mhilara">@mhilara</a></sub>
</div>
