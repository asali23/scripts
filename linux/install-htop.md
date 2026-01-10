# htop Installer

## Purpose
The purpose of this script is to automate the installation of htop, a popular process viewer, on RHEL-based systems, including the setup of the required EPEL repository.

Automated installation script for htop, an interactive process viewer for Unix systems.

## Script

- [`install-htop.sh`](./install-htop.sh)

## Description

This script automates the installation of htop on RHEL/CentOS/Fedora-based systems. It handles EPEL repository installation if needed and provides clear status messages throughout the installation process.

## What it does

- Automatic EPEL repository configuration
- Checks for existing installation to avoid duplication
- Supports both dnf and yum package managers
- Error handling and validation

## Usage

```bash
./install-htop.sh
```

The script will:
1. Check if htop is already installed
2. Install EPEL repository if not present
3. Install htop via dnf or yum
4. Verify successful installation

## Requirements

- RHEL/CentOS/Fedora-based Linux distribution
- sudo privileges
- Internet connection for package download

## Example Output

```
Info: Installing htop...
Info: Installing EPEL repository...
Info: Installing htop...
Success: htop installed successfully (htop 3.x.x)
```

## Notes

- The script requires sudo access to install system packages
- EPEL (Extra Packages for Enterprise Linux) repository is required for htop on RHEL-based systems
- If htop is already installed, the script will exit gracefully without reinstalling
