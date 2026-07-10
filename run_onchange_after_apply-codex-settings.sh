#!/bin/bash
# Keep portable Codex preferences in sync without replacing ~/.codex/config.toml.
#
# The desktop app owns parts of that file which are intentionally local: trusted
# project paths, app-provided MCP paths, marketplace metadata, and machine-specific
# integrations. This script only upserts the preferences declared below.
set -euo pipefail

python3 <<'PY'
import json
import os
import re
import tempfile
from pathlib import Path


CODEX_HOME = Path(os.environ.get("CODEX_HOME", Path.home() / ".codex"))
CONFIG_PATH = CODEX_HOME / "config.toml"
KEYBINDINGS_PATH = CODEX_HOME / "keybindings.json"

# (section, key, TOML literal). Keep this list limited to portable preferences;
# paths, projects, credentials, dynamic marketplace data, and MCP setup remain
# owned by the local Codex installation.
CONFIG_SETTINGS = (
    (None, "model", '"gpt-5.6-terra"'),
    (None, "model_reasoning_effort", '"high"'),
    (None, "approval_policy", '"never"'),
    (None, "sandbox_mode", '"workspace-write"'),
    (None, "personality", '"pragmatic"'),
    ("desktop", "followUpQueueMode", '"steer"'),
    ("desktop", "show-context-window-usage", "false"),
    ("desktop", "hotkey-window-projectless-default-enabled", "true"),
    ("features", "js_repl", "false"),
    ("features", "memories", "true"),
    ("memories", "generate_memories", "true"),
    ("memories", "use_memories", "true"),
    ("sandbox_workspace_write", "network_access", "true"),
    ('plugins."sites@openai-bundled"', "enabled", "true"),
    ('plugins."browser@openai-bundled"', "enabled", "true"),
    ('plugins."chrome@openai-bundled"', "enabled", "true"),
    ('plugins."visualize@openai-bundled"', "enabled", "true"),
)

MANAGED_KEYBINDINGS = ({"command": "globalDictationHold", "key": "LeftControl"},)


def atomic_write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", dir=path.parent, delete=False) as output:
        output.write(content)
        temporary_path = Path(output.name)
    os.replace(temporary_path, path)


def upsert_toml_setting(document: str, section: str | None, key: str, value: str) -> str:
    """Replace one simple TOML assignment, retaining unrelated text and comments."""
    lines = document.splitlines(keepends=True)
    header = re.compile(r"^\s*\[([^]]+)\]\s*(?:#.*)?$")
    assignment = re.compile(rf"^(\s*){re.escape(key)}\s*=.*$")

    if section is None:
        start = 0
        end = next((index for index, line in enumerate(lines) if header.match(line)), len(lines))
    else:
        start = next(
            (index + 1 for index, line in enumerate(lines) if (match := header.match(line)) and match.group(1) == section),
            None,
        )
        if start is None:
            if lines and not lines[-1].endswith("\n"):
                lines[-1] += "\n"
            if lines and lines[-1].strip():
                lines.append("\n")
            lines.extend((f"[{section}]\n", f"{key} = {value}\n"))
            return "".join(lines)
        end = next((index for index in range(start, len(lines)) if header.match(lines[index])), len(lines))

    for index in range(start, end):
        if assignment.match(lines[index]):
            indent = assignment.match(lines[index]).group(1)
            lines[index] = f"{indent}{key} = {value}\n"
            return "".join(lines)

    lines.insert(end, f"{key} = {value}\n")
    return "".join(lines)


def update_config() -> None:
    document = CONFIG_PATH.read_text() if CONFIG_PATH.exists() else ""
    for section, key, value in CONFIG_SETTINGS:
        document = upsert_toml_setting(document, section, key, value)
    atomic_write(CONFIG_PATH, document)


def update_keybindings() -> None:
    try:
        keybindings = json.loads(KEYBINDINGS_PATH.read_text())
    except FileNotFoundError:
        keybindings = []
    except json.JSONDecodeError as error:
        raise SystemExit(f"Refusing to overwrite invalid JSON: {KEYBINDINGS_PATH}: {error}")

    if not isinstance(keybindings, list):
        raise SystemExit(f"Refusing to overwrite non-list JSON: {KEYBINDINGS_PATH}")

    managed_commands = {binding["command"] for binding in MANAGED_KEYBINDINGS}
    keybindings = [
        binding
        for binding in keybindings
        if not isinstance(binding, dict) or binding.get("command") not in managed_commands
    ]
    keybindings.extend(MANAGED_KEYBINDINGS)
    atomic_write(KEYBINDINGS_PATH, json.dumps(keybindings, indent=2) + "\n")


update_config()
update_keybindings()
PY
