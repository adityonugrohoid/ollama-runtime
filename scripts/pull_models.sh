#!/bin/bash
# Download all models into Ollama
set -e

MODELS=(
    "gemma2:2b"
    "llama3.2:1b"
    "phi3:3.8b"
    "llama3.2:3b"
    "mistral:7b"
    "llama3.1:8b"
)

OLLAMA_CONTAINER="${OLLAMA_CONTAINER:-ollama}"

echo "Pulling models into Ollama..."
for model in "${MODELS[@]}"; do
    echo "--- Pulling $model ---"
    docker exec "$OLLAMA_CONTAINER" ollama pull "$model"
done

echo ""
echo "All models pulled successfully!"
docker exec "$OLLAMA_CONTAINER" ollama list
