#!/usr/bin/env python3
"""Indexa la base de conocimiento del agente en Qdrant.

Cada documento se parte en fragmentos y cada fragmento se convierte en un vector
de 384 dimensiones. El embedding se calcula en local con fastembed: no se envía
texto a ningún proveedor de LLM.

    python scripts/qdrant_index.py            # reindexa todo
    python scripts/qdrant_index.py --stats    # solo muestra el estado

Las fuentes están en FUENTES. El payload que se guarda por fragmento
(tipo, sistema, titulo, origen) es lo que permite colorear los puntos en la
vista Visualize del panel de Qdrant.
"""
import argparse
import glob
import os
import pathlib
import uuid

from qdrant_client import QdrantClient

RAIZ = pathlib.Path(__file__).resolve().parent.parent
MODELO = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"

# Solo se indexa conocimiento recuperable. Las instrucciones (CLAUDE.md) y los
# comandos se cargan directo en cada sesión: indexarlos ensucia la recuperación
# y hace que una consulta de incidente devuelva la definición de un comando.
FUENTES = [
    ("runbook", "agent/skills/**/SKILL.md"),
    ("memoria", "agent/memory/*.md"),
    ("recap", "agent/recaps/*.md"),
]


def entorno():
    for linea in (RAIZ / ".env").read_text().splitlines():
        if "=" in linea and not linea.startswith("#"):
            k, v = linea.split("=", 1)
            os.environ.setdefault(k.strip(), v.strip())


def cliente():
    entorno()
    c = QdrantClient(url=os.environ["QDRANT_URL"], api_key=os.environ["QDRANT_API_KEY"], timeout=120)
    c.set_model(MODELO)
    return c, os.environ["QDRANT_COLLECTION"]


def metadatos(texto):
    meta = {}
    if texto.startswith("---"):
        for linea in texto.split("---", 2)[1].strip().splitlines():
            if ":" in linea:
                k, v = linea.split(":", 1)
                meta[k.strip()] = v.strip()
    return meta


def fragmentos(texto, titulo, tam=420):
    """Un documento largo en un solo vector se diluye y deja de recuperarse.
    Se parte por párrafos y se repite el encabezado en cada fragmento, para que
    cada uno conserve de qué trata aunque se lea suelto."""
    cuerpo = texto.split("---", 2)[-1].strip()
    salida, buf = [], ""
    for parrafo in cuerpo.split("\n\n"):
        if len(buf) + len(parrafo) > tam and buf:
            salida.append(f"{titulo}. {buf.strip()}")
            buf = ""
        buf += parrafo + "\n\n"
    if buf.strip():
        salida.append(f"{titulo}. {buf.strip()}")
    return salida


def indexar():
    c, coleccion = cliente()
    if c.collection_exists(coleccion):
        c.delete_collection(coleccion)
    c.create_collection(collection_name=coleccion, vectors_config=c.get_fastembed_vector_params())

    docs, metas, ids = [], [], []
    for tipo, patron in FUENTES:
        for ruta in sorted(glob.glob(str(RAIZ / patron), recursive=True)):
            texto = pathlib.Path(ruta).read_text()
            meta = metadatos(texto)
            rel = os.path.relpath(ruta, RAIZ)
            titulo = meta.get("titulo") or meta.get("name") or pathlib.Path(ruta).stem.replace("-", " ")
            # La descripción de un skill está escrita en lenguaje natural y con las
            # palabras que usa el operador: entra al encabezado para que la
            # recuperación funcione con una consulta hablada, no con jerga.
            encabezado = f"{titulo}. {meta['description']}" if meta.get("description") else titulo
            base = {
                "tipo": meta.get("tipo", tipo),
                "sistema": meta.get("sistema") or pathlib.Path(ruta).parent.name.split("-")[0],
                "titulo": titulo,
                "origen": rel,
                "texto": texto,
            }
            for i, frag in enumerate(fragmentos(texto, encabezado)):
                docs.append(frag)
                metas.append(base)
                ids.append(str(uuid.uuid5(uuid.NAMESPACE_URL, f"{rel}#{i}")))

    c.add(collection_name=coleccion, documents=docs, metadata=metas, ids=ids, batch_size=64)
    archivos = len({m["origen"] for m in metas})
    print(f"Indexados {len(docs)} fragmentos de {archivos} documentos en '{coleccion}'.")
    estado()


def estado():
    c, coleccion = cliente()
    info = c.get_collection(coleccion)
    print(f"\nColección  : {coleccion}")
    print(f"Puntos     : {info.points_count}")
    print(f"Dimensiones: 384 · distancia coseno · embeddings locales")
    url = os.environ["QDRANT_URL"].replace("https://", "https://").rstrip("/")
    print(f"Panel      : {url}:6333/dashboard#/collections/{coleccion}")
    print("             pestaña Visualize para el mapa 2D · Graph para la red de similitud")


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--stats", action="store_true", help="solo mostrar el estado")
    args = ap.parse_args()
    estado() if args.stats else indexar()
