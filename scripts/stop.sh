#!/bin/bash
# Stop Ollama runtime
set -e

echo "Stopping Ollama Runtime..."
docker compose down

echo "Ollama stopped."
