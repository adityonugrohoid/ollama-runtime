# Setup & Deployment Guide

## Prerequisites

### Required

- **Docker** (version 20.10+)
- **Docker Compose** (version 2.0+)

### Optional (Recommended)

- **NVIDIA GPU** with drivers installed
- **nvidia-container-toolkit** for GPU acceleration

## Installation

### 1. Install Docker & Docker Compose

#### Ubuntu/Debian

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt-get update
sudo apt-get install docker-compose-plugin
```

#### macOS

```bash
# Install Docker Desktop (includes Compose)
brew install --cask docker
```

### 2. Install NVIDIA Container Toolkit (GPU Support)

#### Ubuntu/Debian

```bash
# Add NVIDIA package repositories
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install nvidia-container-toolkit
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Restart Docker
sudo systemctl restart docker
```

#### Verify GPU Access

```bash
docker run --rm --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
```

## Deployment

### Quick Start

```bash
# Clone repository
git clone https://github.com/adityonugrohoid/ollama-runtime.git
cd ollama-runtime

# Start Ollama
./scripts/start.sh

# Verify it's running
curl http://localhost:11434/api/tags
```

### Pull Models

```bash
# Download all configured models
./scripts/pull_models.sh
```

This will download 3 models (~6 GB total):
- `llama3.2:3b` (2.0 GB)
- `qwen2.5:3b` (1.9 GB)
- `phi3.5:3.8b` (2.2 GB)

## Configuration

### GPU Configuration

The `docker-compose.yaml` includes GPU support by default:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all
          capabilities: [gpu]
```

**CPU-only mode:** If you don't have a GPU, Docker Compose will ignore the GPU configuration and Ollama will run on CPU (slower but functional).

### Port Configuration

Ollama runs on the standard port `11434`:

```yaml
ports:
  - "11434:11434"
```

This port is:
- Exposed to the host for direct access
- Used by other phases via the Docker network
- Standard Ollama port (no need to change)

### Volume Configuration

Model data is persisted in a Docker volume:

```yaml
volumes:
  - ollama_data:/root/.ollama
```

**Location:** Models are stored in the Docker volume, not in the repository directory.

**Backup:** To backup models:
```bash
docker run --rm -v ollama-runtime_ollama_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/ollama-backup.tar.gz -C /data .
```

**Restore:** To restore models:
```bash
docker run --rm -v ollama-runtime_ollama_data:/data -v $(pwd):/backup \
  alpine tar xzf /backup/ollama-backup.tar.gz -C /data
```

## Verification

### Check Container Status

```bash
docker ps | grep ollama
```

Expected output:
```
CONTAINER ID   IMAGE                STATUS         PORTS                    NAMES
abc123def456   ollama/ollama:latest Up 2 minutes  0.0.0.0:11434->11434/tcp ollama
```

### Test Ollama API

```bash
# List available models
curl http://localhost:11434/api/tags

# Generate test response
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:3b",
  "prompt": "Hello, how are you?",
  "stream": false
}'
```

### Check GPU Usage (if available)

```bash
# From host
nvidia-smi

# From container
docker exec ollama nvidia-smi
```

### Verify Network

```bash
# Check network exists
docker network ls | grep ollama-runtime-network

# Inspect network
docker network inspect ollama-runtime-network
```

## Troubleshooting

### Container Won't Start

**Check logs:**
```bash
docker logs ollama
```

**Common issues:**
- Port 11434 already in use → Stop other Ollama instances
- GPU driver issues → Check `nvidia-smi` works
- Docker daemon not running → `sudo systemctl start docker`

### Models Not Loading

**Check model files:**
```bash
docker exec ollama ls -lh /root/.ollama/models
```

**Re-pull models:**
```bash
./scripts/pull_models.sh
```

### GPU Not Detected

**Verify GPU access:**
```bash
docker run --rm --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
```

**If GPU test fails:**
1. Install `nvidia-container-toolkit`
2. Restart Docker: `sudo systemctl restart docker`
3. Check Docker GPU support: `docker info | grep -i runtime`

**CPU fallback:** Ollama will work on CPU if GPU is unavailable, just slower.

### Network Issues

See [NETWORK.md](NETWORK.md) for detailed network troubleshooting.

## Performance Tuning

### GPU Memory

Ollama automatically uses available GPU memory. To limit:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
          device_ids: ['0']  # Use specific GPU
```

### CPU Limits

To limit CPU usage:

```yaml
deploy:
  resources:
    limits:
      cpus: '4.0'
    reservations:
      cpus: '2.0'
```

### Memory Limits

To limit memory:

```yaml
deploy:
  resources:
    limits:
      memory: 16G
    reservations:
      memory: 8G
```

## Production Considerations

### Security

- **Network isolation:** Use Docker networks to isolate Ollama
- **No authentication:** Ollama has no built-in auth (use reverse proxy for production)
- **Firewall:** Restrict port 11434 to internal networks only

### Monitoring

- **Health checks:** Use `/api/tags` endpoint for health monitoring
- **Logs:** Monitor `docker logs ollama` for errors
- **Resource usage:** Monitor GPU/CPU/memory via `nvidia-smi` and `docker stats`

### Scaling

- **Single instance:** Current setup runs one Ollama instance
- **Multiple instances:** For scaling, run multiple Ollama containers on different ports
- **Load balancing:** Use a reverse proxy (nginx/traefik) to distribute requests

### Backup

- **Model backup:** Backup the `ollama_data` volume regularly
- **Configuration:** Version control `docker-compose.yaml` and scripts

## Next Steps

After Phase 0 is running:

1. **Start Phase 1:** `cd ~/projects/ollama-multi-llm-server && ./scripts/start.sh`
2. **Start Phase 2:** `cd ~/projects/rag-operator-console && ./scripts/start.sh`
3. **Verify integration:** Check that Phase 1 and Phase 2 can connect to Ollama

See the main [README.md](../README.md) for more information.
