"""Basic tests for Docker Compose configuration."""
import pytest
import yaml
from pathlib import Path


@pytest.fixture
def docker_compose_path():
    """Path to docker-compose.yaml."""
    return Path(__file__).parent.parent / "docker-compose.yaml"


def test_docker_compose_valid_yaml(docker_compose_path):
    """docker-compose.yaml is valid YAML."""
    with open(docker_compose_path) as f:
        data = yaml.safe_load(f)
    assert isinstance(data, dict)
    assert "services" in data
    assert "ollama" in data["services"]
