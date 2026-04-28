# docker_image_info.sh

Inspect Docker images and display metadata, build history, and configuration in a human-readable format.

View image summary, metadata (ID, size, creation date, architecture), labels, environment variables, configuration (entrypoint, CMD, working directory, user, exposed ports), and a build timeline with human-readable layer sizes. Identify base image (parent) and export full JSON with `--json`.

| Without this script | With this script |
|---------|-------------|
| `docker inspect image \| jq .` (raw JSON) | `./docker_image_info.sh nginx:latest` |
| `docker history --no-trunc image` | Organized, human-readable output |
| Pipe through `jq` multiple times | All metadata in one view |

## Usage

```bash
./docker_image_info.sh <image_name[:tag]> [--json]
```

## Examples

```bash
# Basic inspection
./docker_image_info.sh nginx:latest

# Export to JSON
./docker_image_info.sh nginx:latest --json
```

## Sample Output

```
=== 🐳 IMAGE SUMMARY ===
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
nginx        latest    123abc456def   2 weeks ago    187MB

=== 🧾 METADATA ===
ID: sha256:123abc456def...
RepoTags: [nginx:latest]
Size: 187000000 bytes
Created: 2025-04-15T10:30:00Z
DockerVersion: 24.0.7
Architecture: amd64
OS: linux

=== 💬 COMMIT MESSAGE ===
No commit message available

=== 🏷️ LABELS ===
{
  "maintainer": "NGINX Docker Maintainers <docker-maint@nginx.com>",
  "org.opencontainers.image.title": "nginx"
}

=== 🌍 ENVIRONMENT VARIABLES ===
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
NGINX_VERSION=1.25.0

=== ⚙️  CONFIGURATION ===
Entrypoint: []
Cmd: [nginx -g daemon off;]
WorkingDir:
User:

=== 🌐 EXPOSED PORTS ===
{
  "80/tcp": {},
  "443/tcp": {}
}

=== 🕒 BUILD TIMELINE ===
0B         | 2 weeks ago | /bin/sh -c #(nop)  CMD ["nginx" "-g" "daemon off;"]
1.23 KB    | 2 weeks ago | /bin/sh -c #(nop)  STOPSIGNAL SIGQUIT
61.02 MB   | 2 weeks ago | /bin/sh -c set -x     && addgroup --system ...
125.60 MB  | 2 weeks ago | /bin/sh -c #(nop) COPY file:abc in /etc/nginx/

=== 🧱 BASE IMAGE ===
No base image recorded (might be FROM scratch or metadata unavailable)
```

## Requirements
- Docker installed and running
- `jq` for JSON processing
- `bc` for size calculations
- Image must exist locally (`docker pull` if needed)
