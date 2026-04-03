# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A single-file FastAPI web app that acts as a Claude-powered AI assistant for two Home Assistant instances (`home` and `farm`). It exposes a chat UI at `http://localhost:8888` and uses the Anthropic API with tool use to query and control both HA systems.

## Running

```bash
# Build and start
docker compose up --build -d

# View logs
docker compose logs -f

# Stop
docker compose down
```

The app runs on port **8888** (mapped from container port 8000).

## Required Environment Variables

Create a `.env` file (picked up automatically by docker compose):

```
ANTHROPIC_API_KEY=
HOME_HA_URL=http://<home-ha-ip>:8123
HOME_HA_TOKEN=
FARM_HA_URL=http://<farm-ha-ip>:8123
FARM_HA_TOKEN=
```

## Architecture

Everything lives in `main.py`:

- **`build_system_context()`** — fetches all HA entity states at startup and caches them for 30 minutes (`CONTEXT_TTL`). Expands entity IDs for actionable domains (lights, switches, climate, etc.) and summarises others by count. This snapshot is injected into every system prompt so Claude can reference entity IDs without a tool call.
- **`get_system_prompt()`** — builds the system prompt fresh per request, calling `build_system_context()` for both systems.
- **`sessions` dict** — in-memory conversation history keyed by UUID session ID. Limited to last 20 messages. Sessions are lost on container restart.
- **Tool loop** — the `/chat` endpoint runs a `while True` loop driving the Anthropic messages API: if `stop_reason == "tool_use"`, tool results are appended and the loop continues; if `stop_reason == "end_turn"`, the text response is returned.
- **HTML** — the entire frontend is an inline string constant served at `GET /`.

## Available Tools Claude Can Call

| Tool | HA API endpoint |
|---|---|
| `get_entities` | `GET /api/states` (returns id + state only) |
| `get_services` | `GET /api/services` |
| `get_automations` | filters `GET /api/states` for `automation.*` |
| `call_service` | `POST /api/services/{domain}/{service}` |
| `create_automation` | `POST /api/config/automation/config` |

## Model

Currently hardcoded to `claude-sonnet-4-6` in the `client.messages.create()` call (`main.py:289`).
