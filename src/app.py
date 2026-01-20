from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse

from .chroma_store import ChromaStore
from .embeddings import Embedder
from .schemas import (
    EmbeddingsRequest,
    EmbeddingsResponse,
    HealthResponse,
    IngestRequest,
    IngestResponse,
    QueryRequest,
    QueryResponse,
)
from .settings import get_settings

app = FastAPI(title="chromadb-retrieval")

_settings = get_settings()
_store = ChromaStore(host=_settings.chroma_host, port=_settings.chroma_port)
_embedder = Embedder(model_name=_settings.embedding_model)


@app.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    chroma_info: dict[str, Any] | None
    try:
        hb = _store.heartbeat()
        chroma_info = {"host": _settings.chroma_host, "port": _settings.chroma_port, "heartbeat": hb}
        ready = True
    except Exception as e:  # pragma: no cover
        chroma_info = {"host": _settings.chroma_host, "port": _settings.chroma_port, "error": str(e)}
        ready = False

    return HealthResponse(
        status="ok" if ready else "degraded",
        ready=ready,
        chroma=chroma_info,
        embedding_model=_settings.embedding_model,
    )


@app.get("/.well-known/capability.json")
def capability() -> JSONResponse:
    # In the container, the repo root is mounted at /app.
    capability_path = Path("/app/capability.json")
    try:
        data = json.loads(capability_path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise HTTPException(status_code=500, detail="capability.json not found")
    except json.JSONDecodeError as e:
        raise HTTPException(status_code=500, detail=f"capability.json invalid: {e}")
    return JSONResponse(content=data)


@app.post("/embeddings", response_model=EmbeddingsResponse)
def embeddings(req: EmbeddingsRequest) -> EmbeddingsResponse:
    try:
        vectors = _embedder.embed(req.texts)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"embedding_failed: {e}")

    dimension = len(vectors[0]) if vectors else 0
    return EmbeddingsResponse(model=_settings.embedding_model, dimension=dimension, embeddings=vectors)


@app.post("/collections/{collection}/documents", response_model=IngestResponse)
def ingest(collection: str, req: IngestRequest) -> IngestResponse:
    if not collection:
        raise HTTPException(status_code=400, detail="collection is required")

    ids = [d.id for d in req.documents]
    texts = [d.text for d in req.documents]
    metadatas = [d.metadata for d in req.documents]

    try:
        vectors = _embedder.embed(texts)
        _store.upsert(collection=collection, ids=ids, documents=texts, metadatas=metadatas, embeddings=vectors)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"ingest_failed: {e}")

    return IngestResponse(collection=collection, upserted=len(ids), ids=ids)


@app.post("/collections/{collection}/query", response_model=QueryResponse)
def query(collection: str, req: QueryRequest) -> QueryResponse:
    if not collection:
        raise HTTPException(status_code=400, detail="collection is required")

    try:
        qvec = _embedder.embed([req.query])[0]
        raw = _store.query(collection=collection, query_embedding=qvec, top_k=req.top_k, where=req.where)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"query_failed: {e}")

    # Chroma returns nested lists
    ids = (raw.get("ids") or [[]])[0]
    docs = (raw.get("documents") or [[]])[0]
    metadatas = (raw.get("metadatas") or [[]])[0]
    distances = (raw.get("distances") or [[]])[0]

    matches = []
    for i in range(min(len(ids), len(distances))):
        matches.append(
            {
                "id": ids[i],
                "score": float(distances[i]),
                "text": docs[i] if i < len(docs) else None,
                "metadata": metadatas[i] if i < len(metadatas) else None,
            }
        )

    return QueryResponse(collection=collection, matches=matches, score_is_distance=True)
