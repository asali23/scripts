# setup_ssh_key.sh

## Purpose
Automate the setup of SSH key-based authentication for a remote user, enabling passwordless login quickly and securely.

## Usage
```bash
./setup_ssh_key.sh [--key-file /path/to/key] <username> <hostname> [port]
```

## Options
- `--key-file PATH` – use the specified private key (default: `~/.ssh/id_ed25519`)
- `-h`, `--help` – display usage help

## Example
```bash
./setup_ssh_key.sh --key-file ~/.ssh/id_ed25519 devuser example.com 2222
```

The script generates a key if one does not exist, uploads the public key to the remote host, and verifies passwordless login.
