from __future__ import annotations

from typing import Any

from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    status: str
    ready: bool
    chroma: dict[str, Any] | None = None
    embedding_model: str | None = None


class DocumentIn(BaseModel):
    id: str = Field(min_length=1)
    text: str = Field(min_length=1)
    metadata: dict[str, Any] | None = None


class IngestRequest(BaseModel):
    documents: list[DocumentIn] = Field(min_length=1)


class IngestResponse(BaseModel):
    collection: str
    upserted: int
    ids: list[str]


class QueryRequest(BaseModel):
    query: str = Field(min_length=1)
    top_k: int = Field(default=3, ge=1, le=50)
    where: dict[str, Any] | None = None


class QueryMatch(BaseModel):
    id: str
    score: float
    text: str | None = None
    metadata: dict[str, Any] | None = None


class QueryResponse(BaseModel):
    collection: str
    matches: list[QueryMatch]
    score_is_distance: bool = True


class EmbeddingsRequest(BaseModel):
    texts: list[str] = Field(min_length=1)


class EmbeddingsResponse(BaseModel):
    model: str
    dimension: int
    embeddings: list[list[float]]
