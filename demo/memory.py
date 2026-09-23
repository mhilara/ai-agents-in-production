#!/usr/bin/env python3
"""Memoria vectorial de la plataforma: indexa runbooks y recaps, y los recupera por similitud.

Uso:
    python memory.py seed              # indexa demo/seed-memory/*.md
    python memory.py "ecs en crash loop"   # recupera lo relevante
    python memory.py remember <archivo.md> # guarda un aprendizaje nuevo

El embedding corre local (fastembed). No se envia texto a ningun proveedor de LLM.
"""
import os
import sys
import glob
import uuid
import pathlib

from qdrant_client import QdrantClient, models

ROOT = pathlib.Path(__file__).resolve().parent.parent
MODEL = "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"


def load_env():
    for line in (ROOT / ".env").read_text().splitlines():
        if "=" in line and not line.startswith("#"):
            k, v = line.split("=", 1)
            os.environ.setdefault(k.strip(), v.strip())


def client():
    load_env()
    c = QdrantClient(url=os.environ["QDRANT_URL"], api_key=os.environ["QDRANT_API_KEY"], timeout=60)
    c.set_model(MODEL)
    return c, os.environ["QDRANT_COLLECTION"]


def front_matter(text):
    meta = {}
    if text.startswith("---"):
        head = text.split("---", 2)[1]
        for line in head.strip().splitlines():
            if ":" in line:
                k, v = line.split(":", 1)
                meta[k.strip()] = v.strip()
    return meta


def chunks(text, meta, size=420):
    """Un documento largo en un solo vector se diluye. Se indexa por parrafos,
    con el titulo en cada chunk para no perder el contexto."""
    body = text.split("---", 2)[-1].strip()
    titulo = meta.get("titulo", "")
    out, buf = [], ""
    for para in body.split("\n\n"):
        if len(buf) + len(para) > size and buf:
            out.append(f"{titulo}. {buf.strip()}")
            buf = ""
        buf += para + "\n\n"
    if buf.strip():
        out.append(f"{titulo}. {buf.strip()}")
    return out


def seed():
    c, coll = client()
    if c.collection_exists(coll):
        c.delete_collection(coll)
    c.create_collection(
        collection_name=coll,
        vectors_config=c.get_fastembed_vector_params(),
    )

    docs, metas, ids = [], [], []
    for path in sorted(glob.glob(str(ROOT / "demo/seed-memory/*.md"))):
        text = pathlib.Path(path).read_text()
        meta = front_matter(text)
        meta["archivo"] = os.path.basename(path)
        meta["texto"] = text
        for i, chunk in enumerate(chunks(text, meta)):
            docs.append(chunk)
            metas.append(meta)
            ids.append(str(uuid.uuid5(uuid.NAMESPACE_URL, f"{path}#{i}")))

    c.add(collection_name=coll, documents=docs, metadata=metas, ids=ids)
    print(f"Indexados {len(docs)} fragmentos de {len(set(m['archivo'] for m in metas))} documentos en '{coll}'.")


def remember(path):
    c, coll = client()
    text = pathlib.Path(path).read_text()
    meta = front_matter(text)
    meta["archivo"] = os.path.basename(path)
    meta["texto"] = text
    c.add(
        collection_name=coll,
        documents=[text],
        metadata=[meta],
        ids=[str(uuid.uuid5(uuid.NAMESPACE_URL, str(path)))],
    )
    print(f"Guardado en memoria: {meta.get('titulo', path)}")


def search(query, limit=3):
    c, coll = client()
    vistos = set()
    for hit in c.query(collection_name=coll, query_text=query, limit=limit * 4):
        meta = hit.metadata
        if meta["archivo"] in vistos:
            continue
        vistos.add(meta["archivo"])
        if len(vistos) > limit:
            break
        print(f"\n[{hit.score:.3f}] {meta.get('titulo')}  ({meta.get('tipo')}/{meta.get('sistema')})")
        body = meta["texto"].split("---", 2)[-1].strip()
        print("\n".join(body.splitlines()[:14]))
        print("-" * 70)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
    elif sys.argv[1] == "seed":
        seed()
    elif sys.argv[1] == "remember":
        remember(sys.argv[2])
    else:
        search(" ".join(sys.argv[1:]))
