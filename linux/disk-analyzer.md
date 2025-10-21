# Linux Disk Space Analyzer

A comprehensive bash script to analyze disk usage and identify space-saving opportunities across different Linux distributions.

## Features

### Multi-Distribution Support
- **Debian/Ubuntu** family (including Mint, Pop!_OS)
- **Red Hat** family (RHEL, Fedora, CentOS, Rocky, AlmaLinux)
- **Arch Linux** family (Arch, Manjaro, EndeavourOS)
- **openSUSE/SLES** family

### Analysis Capabilities
- 📊 Disk usage overview with inode tracking
- 📦 Largest installed packages
- 🐧 Old kernel versions
- 💾 Package manager caches (apt, dnf, pacman, zypper)
- 🗑️ Orphaned packages
- 📝 Large log files and systemd journal
- 💥 Coredumps and crash reports
- 📁 Temporary files and user caches
- 🐳 Container resources (Docker, Podman)
- 📱 Snap packages and Flatpak
- 🌐 Browser caches (Firefox, Chrome)
- 💻 Development tool caches (npm, pip, cargo, gradle, maven, gems)
- 🎨 Thumbnail caches
- 🗂️ Trash directories

### Output Features
- 🎯 Total reclaimable space estimation
- 🎨 Colored output for better readability
- 📋 Comprehensive cleanup suggestions
- ⚡ Quick mode for fast scans
- 🔍 Verbose mode for detailed information

## Usage

### Basic Usage
```bash
# Run basic analysis (no root required for most checks)
./disk_space_analyzer.sh

# Full analysis with root privileges (recommended)
sudo ./disk_space_analyzer.sh
```

### Command-Line Options
```bash
# Show help
./disk_space_analyzer.sh --help

# Quick scan (skip slow file searches)
./disk_space_analyzer.sh --quick

# Verbose output (show detailed information)
./disk_space_analyzer.sh --verbose

# Disable colors (for scripts/logs)
./disk_space_analyzer.sh --no-color

# Combine options
sudo ./disk_space_analyzer.sh --quick --verbose
```

## Installation

```bash
# Download the script
wget https://raw.githubusercontent.com/asali23/scripts/main/linux/disk_space_analyzer.sh

# Make it executable
chmod +x disk_space_analyzer.sh

# Run it
./disk_space_analyzer.sh
```

Or place it in your PATH for system-wide access:
```bash
sudo cp disk_space_analyzer.sh /usr/local/bin/disk-analyzer
sudo chmod +x /usr/local/bin/disk-analyzer
disk-analyzer
```

## Sample Output

```
╔════════════════════════════════════════╗
║    Linux Disk Space Analyzer v2.0     ║
╚════════════════════════════════════════╝

Detected distribution: Ubuntu 22.04

=========================================
DISK USAGE OVERVIEW
=========================================
/dev/sda1       100G   45G   50G  48% /

=========================================
LARGEST INSTALLED PACKAGES
=========================================
1234.5 MB       linux-firmware
987.6 MB        libreoffice-core
...

=========================================
SUMMARY
=========================================
Total potentially reclaimable space: 5.2G
```

## Cleanup Suggestions

The script provides distribution-specific cleanup commands. Always review before executing:

### Safe Commands
- Clean package caches
- Remove orphaned packages
- Clean system logs
- Clear user caches
- Remove temp files

### Container Cleanup
- Docker system prune
- Snap revision cleanup
- Flatpak unused runtime removal

### Advanced (Use Caution)
- Remove old kernels
- Remove coredumps
- Remove development tools

## Requirements

### Minimal Requirements
- Bash 4.0+
- Standard GNU coreutils (du, df, find, etc.)
- bc (for calculations)

### Optional (for full functionality)
- Package managers: apt/dpkg, dnf/yum/rpm, pacman, zypper
- journalctl (for systemd journal analysis)
- docker/podman (for container analysis)
- snap/flatpak (for package analysis)

## Performance

- **Quick mode**: 2-5 seconds
- **Full mode**: 10-30 seconds (depends on filesystem size)
- **With root**: Full access to all directories and logs

## Safety

✅ **Read-only analysis** - Script never deletes anything automatically  
✅ **Requires explicit user action** - All cleanup must be done manually  
✅ **Clear warnings** - Dangerous operations are marked in red  
✅ **Review suggestions** - Always check what will be removed  

## Contributing

Contributions welcome! Areas for improvement:
- Support for more distributions
- Interactive cleanup mode
- JSON output format
- Configuration file support
- Dry-run mode for cleanup operations

## License

See License.txt in the repository.

## Author

Part of the [asali23/scripts](https://github.com/asali23/scripts) collection.

