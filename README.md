# Ollama Runtime

Shared Ollama LLM runtime for the GenAI Portfolio Suite.

Provides a GPU-accelerated Ollama container and Docker network that all portfolio phases connect to.

## Quick Start

```bash
./scripts/start.sh
curl http://localhost:11434/api/tags
```

## Usage

| Command | Description |
|---------|-------------|
| `./scripts/start.sh` | Start Ollama container |
| `./scripts/stop.sh` | Stop Ollama container |
| `./scripts/restart.sh` | Restart Ollama container |
| `./scripts/pull_models.sh` | Download all configured models |

## Available Models

| Tier | Model | Size |
|------|-------|------|
| Fast | gemma2:2b | 1.6 GB |
| Fast | llama3.2:1b | 1.3 GB |
| Balanced | llama3.2:3b | 2.0 GB |
| Balanced | phi3:3.8b | 2.2 GB |
| Quality | mistral:7b | 4.4 GB |
| Quality | llama3.1:8b | 4.9 GB |

## Port

| Service | Port | URL |
|---------|------|-----|
| Ollama API | 11434 | http://localhost:11434 |

## Network

Creates `ollama-runtime-network` (bridge driver). Other phases join this network to reach Ollama at `http://ollama:11434` (container name).

## Integration

This repository provides the shared Ollama service for:

- **Phase 1**: [ollama-multi-llm-server](https://github.com/adityonugrohoid/ollama-multi-llm-server) -- Multi-model inference API + playground
- **Phase 2**: [rag-operator-console](https://github.com/adityonugrohoid/rag-operator-console) -- RAG pipeline + operator debugging UI
- **Phase 3+**: Future phases

Each phase's `docker-compose.yaml` declares `ollama-runtime-network` as an external network:

```yaml
networks:
  ollama-network:
    external: true
    name: ollama-runtime-network
```

## Requirements

- Docker with Compose v2
- NVIDIA GPU + nvidia-container-toolkit (for GPU acceleration)

## License

MIT License - Adityo Nugroho
