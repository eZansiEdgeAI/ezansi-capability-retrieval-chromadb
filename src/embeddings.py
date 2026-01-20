from __future__ import annotations

from typing import Iterable, Sequence


class Embedder:
    def __init__(self, model_name: str):
        self.model_name = model_name
        self._model = None

    def _ensure_model(self) -> None:
        if self._model is not None:
            return
        # Lazy import so basic repo checks can run without deps installed.
        from fastembed import TextEmbedding  # type: ignore

        self._model = TextEmbedding(model_name=self.model_name)

    def embed(self, texts: Sequence[str]) -> list[list[float]]:
        self._ensure_model()
        assert self._model is not None

        vectors: Iterable = self._model.embed(list(texts))
        result: list[list[float]] = []
        for v in vectors:
            # v may be a numpy array; coerce to plain list[float]
            result.append([float(x) for x in v])
        return result
