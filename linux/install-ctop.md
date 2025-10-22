# ctop Installation Script

A comprehensive installer for [ctop](https://github.com/bcicen/ctop) (Container Top) with multiple installation methods, architecture detection, and security features.

## Features

- **Multi-architecture support**: Automatically detects and installs the correct binary for x86_64, ARM64, and ARM systems
- **Multiple package managers**: Tries to install via system package manager first (DNF, APT, Pacman, Zypper, APK, Homebrew)
- **SHA256 checksum verification**: Downloads and verifies checksums for security
- **User-level installation**: Install to `~/.local/bin` without requiring sudo privileges
- **Smart version checking**: Detects existing installations and prevents duplicate installs
- **Colored output**: Clear status messages with color-coded logging
- **Uninstall functionality**: Clean removal of ctop from system
- **Comprehensive error handling**: Validates dependencies and provides helpful error messages

## Usage

### Basic Installation

```bash
# System-wide installation (requires sudo)
./install-ctop.sh

# User installation (no sudo required)
./install-ctop.sh --user
```

### Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `-u, --user` | Install to user directory (~/.local/bin) without sudo |
| `--uninstall` | Uninstall ctop |

### Examples

```bash
# Install ctop system-wide (default)
./install-ctop.sh

# Install to user directory (no sudo needed)
./install-ctop.sh --user

# Uninstall ctop
./install-ctop.sh --uninstall
```

## Installation Methods

The script tries multiple installation methods in order:

1. **Package Manager** (if sudo available and system install):
   - DNF (Fedora, RHEL, CentOS)
   - APT (Debian, Ubuntu)
   - Pacman (Arch Linux)
   - Zypper (openSUSE)
   - APK (Alpine Linux)
   - Homebrew (Linux)

2. **Binary Installation** (fallback):
   - Downloads latest release from GitHub
   - Detects system architecture automatically
   - Verifies SHA256 checksum
   - Installs to `/usr/local/bin` (system) or `~/.local/bin` (user)

## Requirements

- `curl` - Required for downloading files
- `jq` - Optional, for better JSON parsing (falls back to grep/cut if not available)
- `sha256sum` - For checksum verification

## Security

- Validates checksums when available from GitHub releases
- Uses HTTPS for all downloads
- Temporary files are cleaned up on success or failure
- Clear error messages if checksum verification fails

## Architecture Support

- **x86_64/amd64**: Standard Intel/AMD 64-bit systems
- **aarch64/arm64**: ARM 64-bit systems (Raspberry Pi 4, Apple Silicon via Linux, etc.)
- **armv7l/arm**: ARM 32-bit systems (older Raspberry Pi models)

## Troubleshooting

### Already Installed

If ctop is already installed, the script will display:

```
[SUCCESS] ctop is already installed
[INFO] Version: x.x.x
[INFO] Location: /path/to/ctop
[INFO] Use --uninstall to remove it
```

### No Sudo Access

For system-wide installation without sudo, the script will suggest:

```
[ERROR] This script requires sudo privileges for system installation
[ERROR] Use --user flag to install to user directory instead
```

### User Installation PATH

If installing to user directory and `~/.local/bin` is not in your PATH:

```
[WARNING] Add /home/user/.local/bin to your PATH to use ctop:
export PATH="$HOME/.local/bin:$PATH"
```

Add this to your `~/.bashrc` or `~/.zshrc` to make it permanent.

## What is ctop?

ctop is a top-like interface for container metrics. It provides:

- Real-time metrics for running containers
- CPU, memory, network, and disk I/O stats
- Container lifecycle management (start, stop, remove)
- Support for Docker and other container runtimes
- Clean, interactive terminal UI

## License

This installation script is provided as-is. ctop itself is licensed under the MIT License.
