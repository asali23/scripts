# load-ssh-agent.sh

Manage an SSH agent and load a specific key, or stop a running agent.

Check if an SSH agent is already running, start a new agent if needed (capturing both `SSH_AUTH_SOCK` and `SSH_AGENT_PID`), load a key, and verify it's available. Stop agents cleanly with `--kill`.

| Without this script | With this script |
|---------|-------------|
| `eval $(ssh-agent -s)`, `ssh-add ~/.ssh/id_rsa` | `./load-ssh-agent.sh ~/.ssh/id_ed25519` |
| Manually export SSH_AUTH_SOCK each session | Exports vars and provides command hints |
| Forget agent PID, can't kill later | `./load-ssh-agent.sh --kill` stops cleanly |

## Usage

The script exports `SSH_AUTH_SOCK` and `SSH_AGENT_PID` for the current session. To use the agent in other terminals, export the same `SSH_AUTH_SOCK` value.

```bash
# Load a key (default socket: ~/.ssh/ssh-agent-sock)
./load-ssh-agent.sh <ssh_key_path>

# Load with custom socket
./load-ssh-agent.sh <ssh_key_path> <agent_socket_path>

# Stop the agent (removes keys, stops agent, cleans up socket)
./load-ssh-agent.sh --kill

# Stop agent at specific socket
./load-ssh-agent.sh --kill --socket <path>
```

For Git, configure: `git config --local core.sshCommand "SSH_AUTH_SOCK=$SSH_AUTH_SOCK ssh"`

## Options
- `--kill` – stop the SSH agent and remove socket
- `--socket PATH` – use specific socket path
- `-h`, `--help` – show usage

## Examples

```bash
# Load default key
./load-ssh-agent.sh ~/.ssh/id_ed25519

# Load key with custom socket
./load-ssh-agent.sh ~/.ssh/id_rsa /tmp/my-ssh-agent

# Stop the default agent
./load-ssh-agent.sh --kill

# Stop specific agent
./load-ssh-agent.sh --kill --socket /tmp/my-ssh-agent
```

## Sample Output

```
✓ Agent started: /home/user/.ssh/ssh-agent-sock
Identity added: /home/user/.ssh/id_ed25519
✓ Key available: /home/user/.ssh/id_ed25519

✓ Done! SSH_AUTH_SOCK=/home/user/.ssh/ssh-agent-sock
SSH_AGENT_PID=12345

Commands to use this agent:
  export SSH_AUTH_SOCK=/home/user/.ssh/ssh-agent-sock

Git: git config --local core.sshCommand "SSH_AUTH_SOCK=/home/user/.ssh/ssh-agent-sock ssh"
SSH: SSH_AUTH_SOCK=/home/user/.ssh/ssh-agent-sock ssh user@host

To kill this agent: ./load-ssh-agent.sh --kill --socket /home/user/.ssh/ssh-agent-sock
```
