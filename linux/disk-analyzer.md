# Linux Disk Space Analyzer

Analyze disk space usage across different Linux distributions and identify opportunities to reclaim storage.

Detect package manager (dpkg, rpm, pacman) and get comprehensive analysis of disk usage, large packages, old kernels, package caches, logs, coredumps, container resources (Docker, Podman), Snap, Flatpak packages, and development tool caches (cargo, npm, pip, gradle, maven). Get actionable cleanup commands specific to your system or execute safe cleanups automatically with `--cleanup`.

| Without this script | With this script |
|---------|-------------|
| `df -h`, `du -sh /var/*` | `sudo ./disk_space_analyzer.sh` |
| Research cleanup commands per distro | Copy-paste commands for your system |
| No awareness of orphaned packages | Shows orphaned packages per distro |
| Hunt for large packages manually | Lists top 15 largest packages |

## Usage

```bash
./disk_space_analyzer.sh [options]
```

## Options
- `-h`, `--help` – show help
- `-v`, `--verbose` – detailed output
- `-q`, `--quick` – skip slow file searches
- `-c`, `--cleanup` – execute safe cleanup commands automatically
- `-y`, `--yes` – auto-install missing tools without prompting
- `--quiet` – no prompts, no auto-installs (for non-interactive use)

## Examples

```bash
# Full analysis (requires sudo for complete results)
sudo ./disk_space_analyzer.sh

# Quick scan
./disk_space_analyzer.sh --quick

# Execute safe cleanups automatically
sudo ./disk_space_analyzer.sh --cleanup

# Auto-install missing tools
sudo ./disk_space_analyzer.sh --yes
```

## Cleanup Operations (with --cleanup)
The following safe operations are performed:
- Package cache cleanup (apt, dnf, yum, pacman)
- Systemd journal vacuum (keeps 7 days)
- Thumbnail cache cleanup
- Docker system prune (unused data only)
- Flatpak unused runtime removal
- Disabled snap version removal

## Dependency Handling
- Prompts to install missing tools interactively (default)
- Use `-y` to auto-install without prompts
- Use `--quiet` to suppress all prompts (default in non-interactive environments)

## Sample Output

```
╔════════════════════════════════════════╗
║    Linux Disk Space Analyzer v2.0     ║
╚════════════════════════════════════════╝

Detected package manager: apt/dpkg

=========================================
DISK USAGE OVERVIEW
=========================================
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       100G   75G   25G  75% /

Inode Usage:
Filesystem      Inodes   IUsed   IFree IUse% Mounted on
/dev/sda1      6553600  450000 6103600    7% /

=========================================
LARGEST INSTALLED PACKAGES
=========================================
1250.5 MB	linux-headers-5.15.0
850.2 MB	docker-ce
725.0 MB	libreoffice-core

=========================================
CLEANUP SUGGESTIONS
=========================================
Safe Cleanup Commands:
1. Clean package cache:
   sudo apt clean
   sudo apt autoclean

2. Remove orphaned packages:
   sudo apt autoremove --purge
...
```
