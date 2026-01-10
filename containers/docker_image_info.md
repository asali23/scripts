# docker_image_info.sh

## Purpose
The purpose of this script is to provide comprehensive inspection and analysis of Docker images, including metadata, build history, configuration, and a visual timeline of the image layers.

This script inspects Docker images and displays detailed information about their configuration, layers, build history, and metadata in a human-readable format.

## What it does
- Displays image summary with repository tags and basic information
- Shows detailed metadata including ID, size, creation date, Docker version, architecture, and OS
- Lists all labels associated with the image
- Displays environment variables configured in the image
- Shows configuration details (entrypoint, command, working directory, user)
- Lists exposed ports
- Provides a build timeline showing each layer with human-readable sizes and creation time
- Identifies the base image (parent image)
- Optionally exports full image metadata to a JSON file

## How to use

### Basic inspection
```bash
./docker_image_info.sh <image_name[:tag]>
```

Example:
```bash
./docker_image_info.sh nginx:latest
```

### With JSON export
```bash
./docker_image_info.sh <image_name[:tag]> --json
```

Example:
```bash
./docker_image_info.sh nginx:latest --json
```

This will create a JSON file named after the image (e.g., `nginx_latest_info.json`) containing the full `docker inspect` output.

## Output Sections

The script provides organized sections with emoji indicators:

- **🐳 IMAGE SUMMARY**: Basic image listing with tags and size
- **🧾 METADATA**: Core image metadata (ID, tags, size, creation date, etc.)
- **🏷️ LABELS**: All labels attached to the image
- **🌍 ENVIRONMENT VARIABLES**: Environment variables set in the image
- **⚙️ CONFIGURATION**: Entrypoint, CMD, working directory, and user settings
- **🌐 EXPOSED PORTS**: Ports exposed by the container
- **🕒 BUILD TIMELINE**: Layer-by-layer build history with sizes and commands
- **🧱 BASE IMAGE**: Parent image information
- **💾 SAVING FULL JSON**: JSON export confirmation (when --json flag is used)

## Requirements
- Docker must be installed and accessible
- `jq` command-line JSON processor must be installed
- `bc` calculator for human-readable size conversions
- The image must exist locally (use `docker pull` if needed)
