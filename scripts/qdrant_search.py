#!/usr/bin/env python3
"""Busca en la memoria del agente por significado, no por palabra exacta.

    python scripts/qdrant_search.py "el servicio se reinicia todo el tiempo"
    python scripts/qdrant_search.py "disco lleno" --tipo runbook --limite 5
"""
import argparse
import os
import pathlib
import sys

from qdrant_client import QdrantClient, models

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from qdrant_index import cliente  # noqa: E402

VERDE, GRIS, NARANJA, FIN = "\033[32m", "\033[90m", "\033[33m", "\033[0m"


def buscar(consulta, limite, tipo):
    c, coleccion = cliente()
    filtro = None
    if tipo:
        filtro = models.Filter(must=[models.FieldCondition(key="tipo", match=models.MatchValue(value=tipo))])

    vistos = set()
    print(f'\n{NARANJA}?{FIN} {consulta}\n')
    for hit in c.query(collection_name=coleccion, query_text=consulta, query_filter=filtro, limit=limite * 4):
        meta = hit.metadata
        if meta["origen"] in vistos:
            continue
        vistos.add(meta["origen"])
        if len(vistos) > limite:
            break
        print(f'{VERDE}{hit.score:.3f}{FIN}  {meta["titulo"]}')
        print(f'       {GRIS}{meta["tipo"]}/{meta["sistema"]} · {meta["origen"]}{FIN}')
    print()


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("consulta", nargs="+")
    ap.add_argument("--limite", type=int, default=3)
    ap.add_argument("--tipo", help="runbook · memoria · recap · comando · instrucciones")
    a = ap.parse_args()
    buscar(" ".join(a.consulta), a.limite, a.tipo)
