"""Basic tests for shell scripts."""
import pytest
from pathlib import Path


@pytest.fixture
def scripts_dir():
    """Path to scripts directory."""
    return Path(__file__).parent.parent / "scripts"


def test_scripts_exist(scripts_dir):
    """Required scripts exist."""
    required_scripts = ["start.sh", "stop.sh", "restart.sh", "pull_models.sh"]
    for script_name in required_scripts:
        assert (scripts_dir / script_name).exists()
