#!/usr/bin/env python3
"""Imprime los JSON listos para pegar en el panel de Qdrant y el link directo.

    python scripts/qdrant_panel.py

Las pestanas Visualize y Graph reciben un JSON. Como la coleccion usa un vector
con nombre, ambas necesitan el campo "using": sin el, Graph devuelve cero pares
y no dibuja nada. Este script lee el nombre real del vector de la coleccion,
asi que lo que imprime siempre coincide con lo que hay en el servidor.
"""
import json
import os
import pathlib
import sys
import urllib.request

RAIZ = pathlib.Path(__file__).resolve().parent.parent
N, A, G, C = "\033[0m", "\033[33m", "\033[32m", "\033[90m"


def entorno():
    for linea in (RAIZ / ".env").read_text().splitlines():
        if "=" in linea and not linea.startswith("#"):
            k, v = linea.split("=", 1)
            os.environ.setdefault(k.strip(), v.strip())


def pedir(url, key):
    req = urllib.request.Request(url, headers={"api-key": key})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)["result"]


def main():
    entorno()
    base = os.environ["QDRANT_URL"].rstrip("/")
    key = os.environ["QDRANT_API_KEY"]
    col = os.environ["QDRANT_COLLECTION"]

    info = pedir(f"{base}/collections/{col}", key)
    vectores = info["config"]["params"]["vectors"]
    vector = next(iter(vectores)) if isinstance(vectores, dict) else None
    puntos = info["points_count"]

    print(f"\n{A}Coleccion{N}  {col}   {C}{puntos} puntos{N}")
    print(f"{A}Vector{N}     {vector or '(sin nombre)'}")
    print(f"{A}Panel{N}      {base}:6333/dashboard#/collections/{col}\n")

    def bloque(titulo, nota, cuerpo):
        print(f"{G}── {titulo}{N}  {C}{nota}{N}")
        print(json.dumps(cuerpo, indent=2, ensure_ascii=False))
        print()

    usar = {"using": vector} if vector else {}

    bloque("GRAPH", "pestana Graph · la red de similitud",
           {"limit": 3, "sample": puntos, **usar, "tree": False})

    bloque("VISUALIZE · por sistema", "los clusters por motor de datos",
           {"limit": 500, **usar, "color_by": {"payload": "sistema"}})

    bloque("VISUALIZE · por tipo", "la estructura de la memoria",
           {"limit": 500, **usar, "color_by": {"payload": "tipo"}})

    print(f"{C}Si Graph sale vacio, falta el campo \"using\": esta coleccion usa vector con nombre.{N}\n")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"error: {e}", file=sys.stderr)
        sys.exit(1)
