# Network Architecture

## Overview

Phase 0 creates a **shared Docker network** (`ollama-runtime-network`) that enables all portfolio phases to access the Ollama LLM runtime without port conflicts or complex networking configuration.

## Network Configuration

### Network Details

- **Name:** `ollama-runtime-network`
- **Driver:** `bridge`
- **Scope:** External (accessible by other Docker Compose projects)
- **Container Name:** `ollama` (reachable at `http://ollama:11434`)

### Network Creation

The network is created automatically when Phase 0 starts:

```yaml
networks:
  ollama-network:
    name: ollama-runtime-network
    driver: bridge
```

## Integration with Other Phases

### Phase 1: ollama-multi-llm-server

```yaml
services:
  api:
    networks:
      - default
      - ollama-network

networks:
  ollama-network:
    external: true
    name: ollama-runtime-network
```

The API service connects to Ollama via:
```python
OLLAMA_HOST = "http://ollama:11434"
```

### Phase 2: rag-operator-console

```yaml
services:
  query:
    networks:
      - default
      - ollama-network
  console:
    networks:
      - default
      - ollama-network

networks:
  ollama-network:
    external: true
    name: ollama-runtime-network
```

Both services use the same `OLLAMA_HOST = "http://ollama:11434"` configuration.

## Network Benefits

### 1. **Service Isolation**
- Each phase runs in its own Docker Compose project
- No port conflicts between phases
- Independent lifecycle management

### 2. **Shared Resource**
- Single Ollama instance serves all phases
- Models pulled once, reused everywhere
- Reduced memory footprint

### 3. **Container Name Resolution**
- Other phases access Ollama via container name (`ollama`)
- No need for `host.docker.internal` or IP addresses
- Works reliably across WSL2, Linux, and macOS

### 4. **Network Independence**
- Phase 0 can be started/stopped independently
- Other phases gracefully handle Ollama unavailability
- No circular dependencies

## Verification

### Check Network Exists

```bash
docker network ls | grep ollama-runtime-network
```

### Test Connectivity from Phase 1

```bash
docker exec llm-api curl http://ollama:11434/api/tags
```

### Test Connectivity from Phase 2

```bash
docker exec rag-query curl http://ollama:11434/api/tags
```

### Inspect Network

```bash
docker network inspect ollama-runtime-network
```

## Troubleshooting

### Network Not Found

**Error:** `network ollama-runtime-network not found`

**Solution:**
1. Start Phase 0 first: `cd ~/projects/ollama-runtime && ./scripts/start.sh`
2. Verify network exists: `docker network ls | grep ollama-runtime-network`
3. Then start other phases

### Container Name Resolution Failed

**Error:** `Failed to resolve 'ollama'`

**Solution:**
1. Verify Ollama container is running: `docker ps | grep ollama`
2. Check container name matches: `docker ps --format '{{.Names}}' | grep ollama`
3. Verify network connection: `docker network inspect ollama-runtime-network`

### Connection Refused

**Error:** `Connection refused` when accessing `http://ollama:11434`

**Solution:**
1. Check Ollama is running: `docker ps | grep ollama`
2. Check Ollama logs: `docker logs ollama`
3. Verify port mapping: `docker port ollama`
4. Test from host: `curl http://localhost:11434/api/tags`

## Network Lifecycle

### Starting Phase 0

```bash
cd ~/projects/ollama-runtime
./scripts/start.sh
```

This creates the network if it doesn't exist and starts the Ollama container.

### Stopping Phase 0

```bash
cd ~/projects/ollama-runtime
./scripts/stop.sh
```

**Note:** Stopping Phase 0 will break connectivity for Phase 1 and Phase 2. They will show "Ollama disconnected" status until Phase 0 is restarted.

### Removing Network

The network persists even after stopping Phase 0. To remove it:

```bash
docker network rm ollama-runtime-network
```

**Warning:** Only remove the network if you're sure no other phases are using it.

## Best Practices

1. **Always start Phase 0 first** before starting other phases
2. **Use container name** (`ollama`) not IP addresses for reliability
3. **Check network exists** before starting dependent phases
4. **Monitor Ollama health** via `/api/tags` endpoint
5. **Keep network external** to allow cross-project communication
