import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Settings:
    port: int
    chroma_host: str
    chroma_port: int
    embedding_model: str
    cache_dir: str | None


def get_settings() -> Settings:
    port = int(os.getenv("PORT", "8801"))
    chroma_host = os.getenv("CHROMA_HTTP_HOST", "chroma")
    chroma_port = int(os.getenv("CHROMA_HTTP_PORT", "8000"))
    embedding_model = os.getenv("EMBEDDING_MODEL", "BAAI/bge-small-en-v1.5")
    cache_dir = os.getenv("XDG_CACHE_HOME") or os.getenv("HF_HOME")

    return Settings(
        port=port,
        chroma_host=chroma_host,
        chroma_port=chroma_port,
        embedding_model=embedding_model,
        cache_dir=cache_dir,
    )
