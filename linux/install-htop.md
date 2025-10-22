# htop Installation Script

A robust, cross-distribution installer for htop with automatic OS detection, package manager lock handling, and comprehensive error reporting.

## Features

- ✅ **Skip if Already Installed**: Detects existing htop installation and exits early
- ✅ **Multi-Distribution Support**: Works across major Linux distributions
- ✅ **Automatic OS Detection**: Uses `/etc/os-release` for intelligent distribution identification
- ✅ **Package Manager Lock Handling**: Waits for other package operations to complete (up to 60 seconds)
- ✅ **Color-Coded Output**: Visual feedback with green (success), yellow (info), and red (error) messages
- ✅ **Comprehensive Error Handling**: Validates each step with informative error messages
- ✅ **EPEL Repository Management**: Automatically installs EPEL for RHEL-based distributions

## Supported Distributions

### RedHat Family
- Oracle Linux (6, 7, 8, 9)
- RHEL (6, 7, 8, 9)
- CentOS (6, 7, 8)
- Rocky Linux
- AlmaLinux
- Fedora

### Debian Family
- Debian
- Ubuntu
- Linux Mint
- Pop!_OS

### Arch Family
- Arch Linux
- Manjaro
- EndeavourOS

### SUSE Family
- openSUSE (Leap, Tumbleweed)
- SLES

### Other
- Alpine Linux

## Usage

### Basic Usage

```bash
# Make the script executable
chmod +x install-htop.sh

# Run the script
./install-htop.sh
```

The script will:
1. Check if htop is already installed
2. Detect your Linux distribution
3. Wait for any package manager locks to clear
4. Install required repositories (EPEL for RHEL-based systems)
5. Install htop
6. Verify the installation

### Output Examples

**Already Installed:**
```
Success: htop is already installed (htop 3.2.1)
```

**Fresh Installation:**
```
Info: Installing htop...
Info: Installing EPEL repository for RHEL/CentOS 8...
Info: Installing htop...
Success: htop installed successfully (htop 3.2.1)
```

**Error Handling:**
```
Error: Package manager is locked. Please try again later.
```

## Requirements

- Bash shell
- sudo privileges for package installation
- Internet connection for downloading packages

## How It Works

### 1. Pre-Installation Check
The script first checks if htop is already installed to avoid unnecessary reinstallation.

### 2. OS Detection
Reads `/etc/os-release` to identify the distribution and version.

### 3. Package Manager Lock Handling
Before package operations, the script checks for active package manager processes and waits up to 60 seconds for them to complete.

### 4. Repository Setup (RHEL-based systems)
For RHEL, CentOS, and Oracle Linux, the script automatically installs and enables the EPEL repository since htop is not in the default repositories.

### 5. Installation
Uses the appropriate package manager for your distribution:
- `dnf`/`yum` for RHEL-based
- `apt` for Debian-based
- `pacman` for Arch-based
- `zypper` for SUSE-based
- `apk` for Alpine

### 6. Verification
Confirms htop was installed successfully and displays the version.

## Error Handling

The script handles various error conditions:

- **Unsupported Distribution**: Clear error message with suggestion to install manually
- **Unsupported Version**: Specific error for RHEL/CentOS versions not in the supported list
- **Repository Installation Failure**: Exits with error if EPEL or other repositories fail to install
- **Package Installation Failure**: Validates each installation step
- **Package Manager Locked**: Waits or exits with helpful message
- **OS Detection Failure**: Exits if `/etc/os-release` is not available

## Exit Codes

- `0`: Success (htop installed or already present)
- `1`: Error (with descriptive message)

## Examples

### Successful Installation on Ubuntu
```bash
$ ./install-htop.sh
Info: Installing htop...
Info: Updating package list...
Info: Installing htop...
Success: htop installed successfully (htop 3.2.1)
```

### Already Installed
```bash
$ ./install-htop.sh
Success: htop is already installed (htop 3.2.1)
```

### Unsupported Distribution
```bash
$ ./install-htop.sh
Error: Unsupported OS: gentoo
Info: Please install htop manually for your distribution
```

## Troubleshooting

### Package Manager Locked
If you see "Package manager is locked", another package operation is in progress. Wait for it to complete or:

**For apt (Debian/Ubuntu):**
```bash
sudo killall apt apt-get
sudo rm /var/lib/dpkg/lock-frontend
sudo dpkg --configure -a
```

**For dnf/yum (RHEL/Fedora):**
```bash
sudo killall dnf yum
sudo rm /var/run/yum.pid
```

### Manual Installation Fallback

If the script doesn't support your distribution, install manually:

**Debian/Ubuntu:**
```bash
sudo apt install htop
```

**RHEL/CentOS/Fedora:**
```bash
sudo dnf install htop
```

**Arch:**
```bash
sudo pacman -S htop
```

## Contributing

Contributions are welcome! To add support for a new distribution:

1. Add the distribution ID to the case statement
2. Create an installation function if needed
3. Add appropriate error handling
4. Update this documentation

## License

This script is provided as-is for educational and utility purposes.
