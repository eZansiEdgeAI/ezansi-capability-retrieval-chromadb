from __future__ import annotations

from typing import Any, Sequence


class ChromaStore:
    def __init__(self, host: str, port: int):
        self.host = host
        self.port = port
        self._client = None

    def _ensure_client(self) -> None:
        if self._client is not None:
            return
        import chromadb  # type: ignore

        self._client = chromadb.HttpClient(host=self.host, port=self.port)

    def heartbeat(self) -> Any:
        self._ensure_client()
        assert self._client is not None
        return self._client.heartbeat()

    def get_or_create_collection(self, name: str):
        self._ensure_client()
        assert self._client is not None
        return self._client.get_or_create_collection(name=name)

    def upsert(
        self,
        collection: str,
        ids: Sequence[str],
        documents: Sequence[str],
        metadatas: Sequence[dict[str, Any] | None],
        embeddings: Sequence[Sequence[float]],
    ) -> None:
        col = self.get_or_create_collection(collection)
        col.upsert(ids=list(ids), documents=list(documents), metadatas=list(metadatas), embeddings=list(embeddings))

    def query(
        self,
        collection: str,
        query_embedding: Sequence[float],
        top_k: int,
        where: dict[str, Any] | None,
    ) -> dict[str, Any]:
        col = self.get_or_create_collection(collection)
        kwargs: dict[str, Any] = {
            "query_embeddings": [list(query_embedding)],
            "n_results": int(top_k),
        }
        if where:
            kwargs["where"] = where
        return col.query(**kwargs)
