# GenAI Portfolio Suite – Phase 0: Ollama Runtime

Shared Ollama LLM runtime for the **GenAI Portfolio Suite**.

This repository provides a GPU-accelerated Ollama container and shared Docker network that all portfolio phases connect to.

> **Phase:** 0 – LLM Runtime & Infrastructure  
> **Role in Suite:** Central Ollama service used by Phase 1 (LLM server), Phase 2 (RAG console), and future phases.

---

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Available Models](#available-models)
- [Ports](#ports)
- [Network & Integration](#network--integration)
- [Requirements](#requirements)
- [Tech Stack](#tech-stack)
- [Author](#author)
- [License](#license)

---

## Overview

`ollama-runtime` is the **shared LLM runtime** for the suite.  
It runs a single Ollama container that:

- Exposes the standard Ollama API on port `11434`
- Hosts all configured models (pulled once, reused by all phases)
- Provides a shared Docker network so other services can reach Ollama at `http://ollama:11434`

---

## Quick Start

```bash
./scripts/start.sh
curl http://localhost:11434/api/tags
```

To stop:

```bash
./scripts/stop.sh
```

---

## Usage

| Command | Description |
|---------|-------------|
| `./scripts/start.sh` | Start Ollama container |
| `./scripts/stop.sh` | Stop Ollama container |
| `./scripts/restart.sh` | Restart Ollama container |
| `./scripts/pull_models.sh` | Download all configured models |

---

## Available Models

> **Default model across Phase 0–1–2:** `gemma2:2b`

| Tier    | Model       | Size   | Notes                         |
|---------|------------|--------|-------------------------------|
| Fast    | gemma2:2b  | 1.6 GB | **Default – suite-wide**      |
| Fast    | llama3.2:1b| 1.3 GB | Ultra-fast, smallest memory   |
| Balanced| phi3:3.8b  | 2.2 GB | Reasoning, code, structured   |
| Balanced| llama3.2:3b| 2.0 GB | General-purpose, balanced     |
| Quality | mistral:7b | 4.4 GB | Strong instruction-following  |
| Quality | llama3.1:8b| 4.9 GB | Highest quality, complex tasks|

These are pulled via `./scripts/pull_models.sh` and then reused by all phases.

---

## Ports

| Service | Port | URL |
|---------|------|-----|
| Ollama API | 11434 | http://localhost:11434 |

Port scheme across the suite:

- **Phase 0:** 11434 (standard Ollama port)
- **Phase 1:** 1xxx range (e.g. 1080, 1501)
- **Phase 2:** 2xxx range (e.g. 2080, 2501)

---

## Network & Integration

This repository creates the shared Docker network:

- Network name: `ollama-runtime-network`
- Driver: `bridge`
- Ollama is reachable for other containers at: `http://ollama:11434`

This repository provides the shared Ollama service for:

- **Phase 1:** [ollama-multi-llm-server](https://github.com/adityonugrohoid/ollama-multi-llm-server) – Multi-model inference API + playground
- **Phase 2:** [rag-operator-console](https://github.com/adityonugrohoid/rag-operator-console) – RAG pipeline + operator debugging UI
- **Phase 3+:** Future phases in the suite

Each phase’s `docker-compose.yaml` declares `ollama-runtime-network` as an external network:

```yaml
networks:
  ollama-network:
    external: true
    name: ollama-runtime-network
```

This keeps Ollama’s lifecycle **independent** while allowing all phases to share the same LLM runtime.

---

## Requirements

- Docker with Compose v2
- NVIDIA GPU + `nvidia-container-toolkit` (for GPU acceleration, optional but recommended)

---

## Tech Stack

- **Runtime:** Ollama
- **Containerization:** Docker + Docker Compose
- **Networking:** `ollama-runtime-network` (bridge)
- **Hardware Acceleration:** NVIDIA GPU (optional)

---

## Author

**Adityo Nugroho** – [github.com/adityonugrohoid](https://github.com/adityonugrohoid)

---

## License

MIT License – see [LICENSE](LICENSE).

