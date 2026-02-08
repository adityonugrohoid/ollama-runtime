#!/bin/bash
# Restart Ollama runtime
set -e

echo "Restarting Ollama Runtime..."
docker compose restart

echo ""
echo "Ollama is running at: http://localhost:11434"
