#!/bin/bash
# Start Ollama runtime
set -e

echo "Starting Ollama Runtime (Phase 0)..."
docker compose up -d

echo ""
echo "Ollama is running at: http://localhost:11434"
echo ""
echo "To verify:"
echo "  curl http://localhost:11434/api/tags"
echo ""
echo "To pull models: ./scripts/pull_models.sh"
