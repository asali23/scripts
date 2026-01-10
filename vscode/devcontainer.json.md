# VSCode Dev Container Configuration

This guide explains how to use the `devcontainer.json` file to set up a development container for your project in VSCode.

## Overview

The `devcontainer.json` file defines a containerized development environment that includes all dependencies, tools, and configurations needed for your project. VSCode can automatically build and connect to this container, providing a consistent development experience across different machines.

## Prerequisites

- VSCode with **Dev Containers** extension installed (`ms-vscode-remote.remote-containers`)
- Docker installed and running on your system
- Access to the required Docker registry (e.g., `hub.docker.com`)

## Configuration

### Basic Structure

```json
{
    "name": "nginx container",
    "image": "nginx:latest",
    "runArgs": [
        "--privileged",
        "--network", "host",
        "--env", "LICENSEKEY=<license key>",
        "--name", "nginx-container"
    ],
    "mounts": [
        "source=/home/asad/workspace,target=/home/developer/workspace,type=bind,consistency=cached"
    ],
    "workspaceFolder": "/home/developer/workspace/project-nginx",
    "shutdownAction": "stopContainer",
    "customizations": {
        "vscode": {
            "extensions": [
                "github.copilot",
                "github.copilot-chat",
                "ms-vscode.cpptools-extension-pack"
            ]
        }
    }
}
```

## Configuration Fields

### 1. **name**
Display name for the dev container.
- **Value**: `"nginx container"`
- **Used by**: VS Code to identify the container in the UI

### 2. **image**
Docker image to use for the development container.
- **Value**: `"nginx:latest"`
- **Note**: Ensure you have access to the Docker registry

### 3. **runArgs**
Array of additional arguments passed to `docker run` command.

#### Key Arguments:

- **`--privileged`**: Grants extended privileges to the container

- **`--network host`**: Uses the host's network stack

- **`--env`**: Sets environment variables
  - **Value**: `"LICENSEKEY=<license key>"`
  - **Action**: Replace `<license key>` with your actual license key

- **`--name`**: Container name
  - **Value**: `"nginx-container"`

### 4. **mounts**
Bind mounts for accessing host directories inside the container.
- **Value**: `"source=/home/asad/workspace,target=/home/developer/workspace,type=bind,consistency=cached"`
- **Action**: Update `source` to your actual workspace directory on the host if different
- **Note**: `consistency=cached` improves performance on macOS; can be omitted on Linux

### 5. **workspaceFolder**
Working directory inside the container where VSCode opens.
- **Value**: `"/home/developer/workspace/project-nginx"`
- **Action**: Update to match your project's location inside the container

### 6. **shutdownAction**
Action to take when VSCode window is closed.
- **Value**: `"stopContainer"`
- **Note**: Stops the container when VSCode closes

### 7. **customizations.vscode.extensions**
VSCode extensions to install automatically in the container.
- **Values**:
  - `"github.copilot"`
  - `"github.copilot-chat"`
  - `"ms-vscode.cpptools-extension-pack"`

## Setup Instructions

### Step 1: Copy Configuration File

Copy `devcontainer.json` to your project's `.devcontainer/` directory:

```bash
mkdir -p .devcontainer
cp /home/asad/Workspace/asali23/scripts/vscode/devcontainer.json .devcontainer/
```

### Step 2: Update Configuration

Edit `.devcontainer/devcontainer.json` and update the following:

1. **License key**: Replace `<license key>` in the `--env` argument with your actual license key
2. **Workspace mount**: Update the `source` path in `mounts` to your actual workspace directory on the host (currently `/home/asad/workspace`)
3. **Working directory**: Set `"workspaceFolder"` to your project path inside the container (currently `/home/developer/workspace/project-nginx`)
4. **Extensions**: Modify the `extensions` array if you need different VSCode extensions

### Step 3: Open in Container

1. Open your project folder in VSCode
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
3. Type "Dev Containers: Reopen in Container"
4. VSCode will build/pull the image and start the container
5. Once ready, you'll be connected to the containerized environment

## Example Configuration

The current configuration is set up for an nginx-based development environment:

```json
{
    "name": "nginx container",
    "image": "nginx:latest",
    "runArgs": [
        "--privileged",
        "--network", "host",
        "--env", "LICENSEKEY=<license key>",
        "--name", "nginx-container"
    ],
    "mounts": [
        "source=/home/asad/workspace,target=/home/developer/workspace,type=bind,consistency=cached"
    ],
    "workspaceFolder": "/home/developer/workspace/project-nginx",
    "shutdownAction": "stopContainer",
    "customizations": {
        "vscode": {
            "extensions": [
                "github.copilot",
                "github.copilot-chat",
                "ms-vscode.cpptools-extension-pack"
            ]
        }
    }
}
```

## Additional Resources

- [VSCode Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Dev Container Specification](https://containers.dev/)
- [Docker Run Reference](https://docs.docker.com/engine/reference/run/)
