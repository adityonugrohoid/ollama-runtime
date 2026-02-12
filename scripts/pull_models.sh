#!/bin/bash
# Download all models into Ollama
set -e

MODELS=(
    "llama3.2:3b"
    "qwen2.5:3b"
    "phi3.5:3.8b"
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
