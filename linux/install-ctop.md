# ctop Installer

Automate installation of ctop, a top-like interface for container metrics, with SHA256 checksum verification.

Download latest ctop release from GitHub, verify SHA256 checksum before installation, and install system-wide (requires sudo) or user-level (no sudo). Detects existing installations and skips if already present. Provides uninstall functionality.

| Without this script | With this script |
|---------|-------------|
| Visit GitHub releases, download manually | `./install-ctop.sh` |
| Verify checksum manually | SHA256 verified automatically |
| `chmod +x`, move to PATH | Installed to system or user location |
| No uninstall path | `./install-ctop.sh --uninstall` |

## Usage

```bash
# System-wide (requires sudo)
./install-ctop.sh

# User-level (no sudo required)
./install-ctop.sh --user

# Uninstall
./install-ctop.sh --uninstall

# Show help
./install-ctop.sh --help
```

## Options
- `-h`, `--help` – show help
- `-u`, `--user` – install to `~/.local/bin` without sudo
- `--uninstall` – remove ctop

## Installation Locations

- System: `/usr/local/bin/ctop` (requires sudo)
- User: `~/.local/bin/ctop` – ensure this directory is in your PATH

Auto-detects the latest version from GitHub releases.

## Requirements
- x86_64 architecture
- curl
- Internet connection
- sudo (for system-wide only)

## Security
Verifies SHA256 checksum of the downloaded binary before installation.
