# Nextcloud Sync Lab

Tools for AI agents to set up and test Nextcloud desktop client synchronization scenarios in a development environment.

More specifically, with this agents like Claude Code can efficiently:

- set up a Nextcloud server container
- configure a Nextcloud desktop client account connected to such server
- inspect the local file provider domain state
- inspect the remove server file tree state
- perform mutations on the local and remote state
- reproduce synchronization processes

## Features

- Nextcloud server MCP
- Nextcloud desktop client MCP

## Requirements

- macOS 26 Tahoe (support for other platforms might be possible but is out of scope for now)
- Docker Desktop (or drop-in replacements like Orbstack)

## How to Use

This project exposes a local **MCP server** — a process that Claude Code (or any MCP-compatible agent) can call tools on, the same way it calls web APIs, except it runs entirely on your Mac with direct access to Docker. No cloud, no API keys.

### Setup

1. **Prerequisites** — macOS 26, Docker Desktop (or OrbStack) running, Xcode Command Line Tools, Claude Code installed
   ```bash
   xcode-select --install
   ```

2. **Build the binary** (first time only, ~30 s):
   ```bash
   swift build
   ```

3. **Open a Claude Code session** in this directory — the `.mcp.json` file is already committed to the repo, so the `nextcloud-sync-lab` MCP is listed as available automatically.

### Available Tools

| Tool | What it does |
|------|-------------|
| `start_server` | Deploys a Nextcloud Docker container; returns a URL and container ID |
| `stop_server` | Stops and removes a container by ID |

### Example: Reproducing a Bug

Say you have a bug report against Nextcloud 30.0.1. In your Claude Code session:

```
Spin up a Nextcloud 30.0.1 server so I can reproduce a bug.
```

Claude calls `start_server`, waits for the container to be ready (~60 s), and replies with something like:

```
Container ID: a3f9c2b1...
URL: http://localhost:8743
```

Open that URL in Safari (default credentials: **admin / admin**), follow the reproduction steps from the bug report. When you're done:

```
Stop the Nextcloud server a3f9c2b1...
```

Claude calls `stop_server`, the container is removed, and the port is freed.

## License

See [LICENSE](LICENSE).
