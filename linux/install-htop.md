# htop Installer

Automate installation of htop, an interactive process viewer, on any Linux distribution.

Detect distribution (Debian/Ubuntu, RHEL/CentOS/Fedora, Arch) and install htop via the appropriate package manager. On Debian/Ubuntu, runs `apt-get update` before installation. On RHEL-based systems, automatically handles the EPEL repository. Exits gracefully if htop is already installed.

| Without this script | With this script |
|---------|-------------|
| `sudo apt install htop` (Debian) or `sudo dnf install htop` (RHEL) | `./install-htop.sh` (works on any distro) |
| Handle EPEL manually (RHEL) | Auto-detects and handles EPEL |
| Check if already installed | Exits gracefully if present |
| Remember distro-specific commands | One command for all distros |

## Usage

```bash
./install-htop.sh
```

The script will:
1. Check if htop is already installed
2. Detect your Linux distribution
3. Install htop via apt (Debian/Ubuntu), dnf/yum (RHEL), or pacman (Arch)
4. Verify successful installation

## Supported Distributions
- Debian/Ubuntu (apt)
- RHEL/CentOS/Fedora (dnf/yum with EPEL)
- Arch Linux (pacman)

## Requirements
- Linux distribution (see supported list)
- sudo privileges
- Internet connection
