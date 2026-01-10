# Linux Disk Space Analyzer

## Purpose
The purpose of this script is to provide a single, comprehensive tool to analyze disk space usage on various Linux systems. It identifies common areas where space can be saved and provides system-specific commands to help users reclaim storage, abstracting away the differences between package managers.

## What it does

- **Package Manager Agnostic**: Works with systems using `dpkg` (Debian/Ubuntu), `rpm` (Fedora/RHEL), and `pacman` (Arch Linux).
- **Comprehensive Analysis**: Checks disk usage, large packages, old kernels, package caches, logs, coredumps, container images (Docker/Podman), and various development tool caches.
- **Cleanup Suggestions**: Provides actionable, package-manager-specific commands to reclaim disk space.

## Usage

### Basic Usage
```bash
# Run basic analysis
./disk_space_analyzer.sh

# Full analysis with root privileges
sudo ./disk_space_analyzer.sh
```

### Command-Line Options
```bash
# Show help
./disk_space_analyzer.sh --help

# Quick scan (skip slow file searches)
./disk_space_analyzer.sh --quick


# Auto-install missing supporting tools (no prompts)
./disk_space_analyzer.sh -y

# Quiet mode (no prompts, no auto-installs)
./disk_space_analyzer.sh --quiet
```

**Dependency Handling:**
- If a required tool is missing, the script will prompt to install it interactively.
- Use `-y`/`--yes` to auto-install missing tools without prompting.
- Use `--quiet` to suppress all prompts and auto-installs (warnings will be shown in the summary).
- In non-interactive environments, the script defaults to quiet mode.


