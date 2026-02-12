"""Test configuration and fixtures."""
import os
import sys
from pathlib import Path

# Add project root to path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

# Ollama API base URL
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")
