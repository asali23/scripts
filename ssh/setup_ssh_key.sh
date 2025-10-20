#!/bin/bash
#
# Automates SSH key-based authentication setup
# Usage: ./setup_ssh_key.sh [--key-file /path/to/key] <username> <hostname> [port]
#
# Example:
#   ./setup_ssh_key.sh asad 192.168.1.100
#   ./setup_ssh_key.sh --key-file "$HOME/.ssh/id_ed25519" asad myserver.com 2222


set -euo pipefail

for cmd in ssh ssh-keygen; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Required command '$cmd' not found in PATH."
        exit 1
    fi
done

usage() {
    cat <<USAGE
Usage: $0 [--key-file /path/to/key] <username> <hostname> [port]

Options:
  --key-file PATH   Use an existing key pair instead of the default (~/.ssh/id_ed25519)
  -h, --help        Show this help message

Examples:
  $0 devuser example.com
  $0 --key-file ~/.ssh/my_key devuser example.com 2222
USAGE
}

KEY_FILE="$HOME/.ssh/id_ed25519"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --key-file)
            if [[ $# -lt 2 || "$2" == -* ]]; then
                echo "ERROR: --key-file requires a path argument."
                usage
                exit 1
            fi
            KEY_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --*)
            echo "ERROR: Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

if [[ $# -lt 2 ]]; then
    usage
    exit 1
fi

USER_NAME="$1"
HOST_NAME="$2"
PORT="${3:-22}"

if [ -z "$USER_NAME" ] || [ -z "$HOST_NAME" ]; then
    usage
    exit 1
fi

echo "Setting up SSH key-based login for $USER_NAME@$HOST_NAME (port $PORT)"

LOCAL_SSH_DIR=$(dirname "$KEY_FILE")
mkdir -p "$LOCAL_SSH_DIR"
chmod 700 "$LOCAL_SSH_DIR" >/dev/null 2>&1 || true

# Generate key if it doesn't exist
if [ ! -f "$KEY_FILE" ]; then
    echo "Generating a new SSH key at $KEY_FILE ..."
    ssh-keygen -t ed25519 -a 100 -q -f "$KEY_FILE" -C "${USER_NAME}@${HOST_NAME}" -N ""
else
    echo "SSH key already exists at $KEY_FILE"
fi

# Ensure public key file exists when private key is present
if [ ! -f "${KEY_FILE}.pub" ]; then
    echo "Public key not found. Rebuilding ${KEY_FILE}.pub ..."
    ssh-keygen -y -f "$KEY_FILE" > "${KEY_FILE}.pub"
fi

# Create remote ~/.ssh directory and add the public key
echo "Copying public key to remote server..."
PUB_KEY=$(cat "${KEY_FILE}.pub")

SSH_BASE_OPTS=(-p "$PORT" -o StrictHostKeyChecking=accept-new)

ssh "${SSH_BASE_OPTS[@]}" "${USER_NAME}@${HOST_NAME}" "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
printf '%s\n' "$PUB_KEY" | ssh "${SSH_BASE_OPTS[@]}" "${USER_NAME}@${HOST_NAME}" "cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

# Test passwordless login
echo "Testing passwordless login..."
if ssh "${SSH_BASE_OPTS[@]}" -o PasswordAuthentication=no -o BatchMode=yes "${USER_NAME}@${HOST_NAME}" "echo 'SSH key authentication successful!'" 2>/dev/null; then
    echo "All done! You can now SSH without a password:"
    echo "    ssh ${USER_NAME}@${HOST_NAME}"
else
    echo "Key setup completed, but passwordless login failed."
    echo "Please check ~/.ssh/authorized_keys permissions or the server's SSH config."
fi
