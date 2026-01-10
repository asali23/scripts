#!/bin/bash
# -------------------------------------------------------------
# Docker Image Inspector with Build Timeline
# Usage:
#   ./docker-image-info.sh <image_name[:tag]> [--json]
# -------------------------------------------------------------

set -e

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <image_name[:tag]> [--json]"
  exit 1
fi

IMAGE="$1"
JSON_FLAG="$2"

if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "❌ Error: Image '$IMAGE' not found locally."
  exit 1
fi

# Helper to convert bytes → human readable
function human_readable() {
  local bytes=$1
  local kib=$((1024))
  local mib=$((1024 * 1024))
  local gib=$((1024 * 1024 * 1024))
  if ((bytes >= gib)); then
    printf "%.2f GB" "$(bc -l <<< "$bytes/$gib")"
  elif ((bytes >= mib)); then
    printf "%.2f MB" "$(bc -l <<< "$bytes/$mib")"
  elif ((bytes >= kib)); then
    printf "%.2f KB" "$(bc -l <<< "$bytes/$kib")"
  else
    printf "%d B" "$bytes"
  fi
}

# -------------------------------------------------------------
# BASIC SUMMARY
# -------------------------------------------------------------
echo "=== 🐳 IMAGE SUMMARY ==="
docker images "$IMAGE" --no-trunc
echo

# -------------------------------------------------------------
# BASIC METADATA
# -------------------------------------------------------------
echo "=== 🧾 METADATA ==="
docker inspect --format '
ID: {{.Id}}
RepoTags: {{.RepoTags}}
Size: {{.Size}} bytes
Created: {{.Created}}
DockerVersion: {{.DockerVersion}}
Architecture: {{.Architecture}}
OS: {{.Os}}
' "$IMAGE"
echo

# -------------------------------------------------------------
# COMMIT MESSAGE
# -------------------------------------------------------------
echo "=== 💬 COMMIT MESSAGE ==="
COMMIT_MSG=$(docker inspect "$IMAGE" | jq -r '.[0].Config.Labels.CommitMessage // empty' 2>/dev/null)
if [[ -n "$COMMIT_MSG" ]]; then
  printf '%b\n' "$COMMIT_MSG"
else
    echo "No commit message available"
fi
echo

# -------------------------------------------------------------
# LABELS
# -------------------------------------------------------------
echo "=== 🏷️ LABELS ==="
docker inspect --format '{{ json .Config.Labels }}' "$IMAGE" | jq .
echo

# -------------------------------------------------------------
# ENVIRONMENT VARIABLES
# -------------------------------------------------------------
echo "=== 🌍 ENVIRONMENT VARIABLES ==="
docker inspect --format '{{ range $index, $value := .Config.Env }}{{$value}}{{"\n"}}{{end}}' "$IMAGE"
echo

# -------------------------------------------------------------
# ENTRYPOINT / CMD / USER / WORKDIR
# -------------------------------------------------------------
echo "=== ⚙️  CONFIGURATION ==="
docker inspect --format '
Entrypoint: {{.Config.Entrypoint}}
Cmd: {{.Config.Cmd}}
WorkingDir: {{.Config.WorkingDir}}
User: {{.Config.User}}
' "$IMAGE"
echo

# -------------------------------------------------------------
# EXPOSED PORTS
# -------------------------------------------------------------
echo "=== 🌐 EXPOSED PORTS ==="
docker inspect --format '{{ json .Config.ExposedPorts }}' "$IMAGE" | jq .
echo

# -------------------------------------------------------------
# BUILD TIMELINE (HISTORY)
# -------------------------------------------------------------
echo "=== 🕒 BUILD TIMELINE ==="
docker history --no-trunc --format '{{.CreatedBy}}|{{.CreatedSince}}|{{.Size}}' "$IMAGE" \
  | while IFS="|" read -r cmd created size; do
      size_readable=$(human_readable "$(echo "$size" | tr -dc '0-9')")
      # Replace literal \n with actual newlines
      cmd_formatted=$(echo "$cmd" | sed 's/\\n/\n/g')
      printf "%-15s | %-10s | " "$size_readable" "$created"
      echo "$cmd_formatted"
    done
echo

# -------------------------------------------------------------
# BASE IMAGE INFO
# -------------------------------------------------------------
echo "=== 🧱 BASE IMAGE ==="
BASE_IMAGE=$(docker inspect --format '{{.Parent}}' "$IMAGE" 2>/dev/null || true)
if [[ -n "$BASE_IMAGE" ]]; then
  echo "Derived from base image: $BASE_IMAGE"
else
  echo "No base image recorded (might be FROM scratch or metadata unavailable)"
fi
echo

# -------------------------------------------------------------
# OPTIONAL: SAVE FULL JSON
# -------------------------------------------------------------
if [[ "$JSON_FLAG" == "--json" ]]; then
  OUTFILE="${IMAGE//[:\/]/_}_info.json"
  echo "=== 💾 SAVING FULL JSON TO $OUTFILE ==="
  docker inspect "$IMAGE" | jq . > "$OUTFILE"
  echo "✅ JSON saved to: $OUTFILE"
  echo
fi

