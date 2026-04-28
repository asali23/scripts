# VSCode Dev Container Configuration

Development container configuration for consistent, reproducible development environments.

## What this provides

Pre-configured `devcontainer.json` for containerized development with:
- Privileged container with host network access
- Bind mount for workspace access
- Pre-installed extensions (Copilot, C/C++ tools)
- Environment variable configuration for license keys

## Quick Start

1. Copy to your project:
   ```bash
   mkdir -p .devcontainer
   cp devcontainer.json .devcontainer/
   ```

2. Update placeholders:
   - Replace `<license key>` in `runArgs`
   - Adjust `source` path in `mounts` to your workspace
   - Update `workspaceFolder` to your project path

3. Open in VSCode: `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

## Key Fields

| Field | Purpose |
|-------|---------|
| `image` | Docker image for the container |
| `runArgs` | Docker run options (`--privileged`, `--network host`, env vars) |
| `mounts` | Bind mounts for host directory access |
| `workspaceFolder` | Project directory inside container |
| `customizations.vscode.extensions` | Auto-installed extensions |

## References

- [VSCode Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Dev Container Specification](https://containers.dev/)
