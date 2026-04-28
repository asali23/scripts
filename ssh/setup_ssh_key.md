# setup_ssh_key.sh

Automate the setup of SSH key-based authentication for a remote user, enabling passwordless login quickly and securely.

Generate a key if one does not exist, upload the public key to the remote host, set correct permissions automatically, and verify passwordless login before exit.

| Without this script | With this script |
|---------|-------------|
| `ssh-keygen -t ed25519`, `ssh-copy-id user@host` | `./setup_ssh_key.sh user host` |
| Fix permissions manually if copy-id fails | Handles permissions automatically |
| Test login manually | Verifies passwordless login |

## Prerequisites
- `ssh` and `ssh-keygen` commands available
- Remote host must allow password authentication (for initial setup)
- Network connectivity to remote host

## Usage
```bash
./setup_ssh_key.sh [--key-file /path/to/key | --key-name name] <username> <hostname> [port]
```

## Options
- `--key-file PATH` – use the specified private key (default: `~/.ssh/id_ed25519`)
- `--key-name NAME` – create/use key in `~/.ssh` with given name (overrides default)
- `-h`, `--help` – display usage help

## Examples

```bash
./setup_ssh_key.sh --key-name mykey devuser example.com
./setup_ssh_key.sh --key-file ~/.ssh/id_ed25519 devuser example.com 2222
```
