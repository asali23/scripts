#!/bin/bash
set -euo pipefail

# SSH Agent Loader Script
# Usage: ./load-ssh-agent.sh [--kill] [ssh_key_path] [agent_socket_path]
#   or:  ./load-ssh-agent.sh [--kill] [--socket <path>]

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Defaults
KILL_MODE=false
AGENT_SOCKET="${AGENT_SOCKET:-$HOME/.ssh/ssh-agent-sock}"
SSH_KEY=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --kill)
            KILL_MODE=true
            shift
            ;;
        --socket)
            if [[ -z "${2:-}" || "$2" == -* ]]; then
                echo -e "${RED}✗ --socket requires a path${NC}"
                exit 1
            fi
            AGENT_SOCKET="$2"
            shift 2
            ;;
        -h|--help)
            cat <<EOF
Usage: $0 [options] [ssh_key_path] [agent_socket_path]

Options:
    --kill          Stop the SSH agent and remove socket
    --socket PATH   Use specific agent socket path (default: ~/.ssh/ssh-agent-sock)
    -h, --help      Show this help message

Examples:
    $0 ~/.ssh/id_ed25519                    # Load key with default socket
    $0 ~/.ssh/id_rsa /tmp/my-agent          # Load key with custom socket
    $0 --kill                               # Kill default socket agent
    $0 --kill --socket /tmp/my-agent        # Kill specific agent
EOF
            exit 0
            ;;
        -*)
            echo -e "${RED}✗ Unknown option: $1${NC}"
            echo "Use -h or --help for usage"
            exit 1
            ;;
        *)
            if [[ -z "$SSH_KEY" && "$KILL_MODE" == false ]]; then
                SSH_KEY="$1"
            elif [[ -z "$SSH_KEY" && "$KILL_MODE" == true ]]; then
                # In kill mode, first positional arg could be socket path
                AGENT_SOCKET="$1"
            elif [[ "$KILL_MODE" == false ]]; then
                AGENT_SOCKET="$1"
            fi
            shift
            ;;
    esac
done

# Handle kill mode
if [[ "$KILL_MODE" == true ]]; then
    if [[ -S "$AGENT_SOCKET" ]]; then
        # Try to find and kill the agent
        if [[ -r "$AGENT_SOCKET" ]] && SSH_AUTH_SOCK="$AGENT_SOCKET" ssh-add -l >/dev/null 2>&1; then
            SSH_AUTH_SOCK="$AGENT_SOCKET" ssh-add -D 2>/dev/null || true
            # Find PID from socket (agent writes PID to socket metadata)
            AGENT_PID=$(lsof -t "$AGENT_SOCKET" 2>/dev/null || echo "")
            if [[ -n "$AGENT_PID" ]]; then
                kill "$AGENT_PID" 2>/dev/null || true
                echo -e "${GREEN}✓${NC} SSH agent stopped (PID: $AGENT_PID)"
            else
                echo -e "${YELLOW}!${NC} Could not determine agent PID, removing socket only"
            fi
        fi
        rm -f "$AGENT_SOCKET"
        echo -e "${GREEN}✓${NC} Socket removed: $AGENT_SOCKET"
    else
        echo -e "${YELLOW}!${NC} No agent running at: $AGENT_SOCKET"
    fi
    exit 0
fi

# Load mode - require SSH key
if [[ -z "$SSH_KEY" ]]; then
    echo -e "${RED}✗ SSH key path required${NC}"
    echo "Usage: $0 <ssh_key_path> [agent_socket_path]"
    echo "   or: $0 --kill [--socket <path>]"
    exit 1
fi

# Check required commands
for cmd in ssh-agent ssh-add ssh-keygen; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}✗ Required command '$cmd' not found in PATH${NC}"
        exit 1
    fi
done

# Validate key file exists and is readable
if [[ ! -f "$SSH_KEY" ]]; then
    echo -e "${RED}✗ SSH key file not found: $SSH_KEY${NC}"
    exit 1
fi

if [[ ! -r "$SSH_KEY" ]]; then
    echo -e "${RED}✗ SSH key file is not readable: $SSH_KEY${NC}"
    exit 1
fi

# Check/start agent
if [[ -S "$AGENT_SOCKET" ]] && SSH_AUTH_SOCK="$AGENT_SOCKET" ssh-add -l >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Agent running at $AGENT_SOCKET"
else
    rm -f "$AGENT_SOCKET"
    # Capture ssh-agent output and export both SSH_AUTH_SOCK and SSH_AGENT_PID
    eval "$(ssh-agent -a "$AGENT_SOCKET")"
    echo -e "${GREEN}✓${NC} Agent started: $AGENT_SOCKET"
fi
export SSH_AUTH_SOCK="$AGENT_SOCKET"

# Load key - capture exit code to check for errors
KEY_ADDED=false
if ssh-add "$SSH_KEY" 2>&1 | grep -v "Identity already in agent"; then
    KEY_ADDED=true
fi

# Check if key is now available in agent
KEY_FINGERPRINT=$(ssh-keygen -lf "$SSH_KEY" 2>/dev/null | awk '{print $2}') || true
if [[ -n "$KEY_FINGERPRINT" ]] && SSH_AUTH_SOCK="$AGENT_SOCKET" ssh-add -l 2>/dev/null | grep -q "$KEY_FINGERPRINT"; then
    echo -e "${GREEN}✓${NC} Key available: $SSH_KEY"
else
    echo -e "${RED}✗ Failed to add key to agent: $SSH_KEY${NC}"
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}✓ Done!${NC} SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
[[ -n "${SSH_AGENT_PID:-}" ]] && echo "SSH_AGENT_PID=$SSH_AGENT_PID"
echo ""
echo "Commands to use this agent:"
echo "  export SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
echo ""
echo "Git: git config --local core.sshCommand \"SSH_AUTH_SOCK=$SSH_AUTH_SOCK ssh\""
echo "SSH: SSH_AUTH_SOCK=$SSH_AUTH_SOCK ssh user@host"
echo ""
echo "To kill this agent: $0 --kill --socket $AGENT_SOCKET"
