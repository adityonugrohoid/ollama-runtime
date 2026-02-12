"""Basic tests for Ollama API."""
import os
import pytest
import httpx

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")


@pytest.mark.integration
def test_ollama_api_available():
    """Ollama API is reachable."""
    try:
        client = httpx.Client(base_url=OLLAMA_HOST, timeout=5.0)
        resp = client.get("/api/tags")
        assert resp.status_code == 200
    except httpx.ConnectError:
        pytest.skip("Ollama container not running. Start with: ./scripts/start.sh")
