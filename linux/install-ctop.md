# ctop Installer

## Purpose
The purpose of this script is to automate the installation of ctop, a popular tool for monitoring container metrics, while ensuring security through checksum verification.

Automated installation script for ctop, a top-like interface for container metrics.

## Script

- [`install-ctop.sh`](./install-ctop.sh)

## Description

This script downloads and installs ctop from the official GitHub releases. It supports both system-wide and user-level installation, includes SHA256 checksum verification for security, and provides uninstall functionality.

## What it does

- x86_64 architecture support
- SHA256 checksum verification for security
- User-level installation (no sudo required)
- System-wide installation option
- Smart version checking
- Uninstall functionality
- Automatic latest version detection from GitHub releases

## Usage

### Basic Installation (System-wide)

```bash
./install-ctop.sh
```

### User Installation (No sudo required)

```bash
./install-ctop.sh --user
```

### Uninstall

```bash
./install-ctop.sh --uninstall
```

### Show Help

```bash
./install-ctop.sh --help
```

## Options

- `-h, --help` - Show help message
- `-u, --user` - Install to user directory (~/.local/bin) without sudo
- `--uninstall` - Uninstall ctop

## Installation Locations

- **System-wide**: `/usr/local/bin/ctop` (requires sudo)
- **User-level**: `~/.local/bin/ctop` (no sudo required)

## Requirements

- x86_64 architecture
- curl or wget for downloading
- Internet connection
- sudo privileges (for system-wide installation only)

## Example Output

```
[INFO] Detecting architecture...
[INFO] Fetching latest ctop release...
[INFO] Latest version: v0.7.7
[INFO] Downloading ctop...
[INFO] Verifying checksum...
[SUCCESS] Checksum verification passed
[INFO] Installing to /usr/local/bin/ctop...
[SUCCESS] ctop v0.7.7 installed successfully!
```

## Security

The script verifies the SHA256 checksum of the downloaded binary to ensure integrity and authenticity before installation.

## Notes

- For user installation, ensure `~/.local/bin` is in your PATH
- The script automatically detects the latest version from GitHub releases
- ctop provides a real-time overview of Docker and other container metrics
