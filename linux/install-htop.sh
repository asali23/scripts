#!/bin/bash

# htop Installation Script
set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions for colored output
error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

success() {
    echo -e "${GREEN}Success: $1${NC}"
}

info() {
    echo -e "${YELLOW}Info: $1${NC}"
}

# Check if htop is already installed
if command -v htop >/dev/null 2>&1; then
    success "htop is already installed ($(htop --version | head -n1))"
    exit 0
fi

info "Installing htop..."

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    # Better version detection
    if [ -n "$VERSION_ID" ]; then
        OS_VERSION=${VERSION_ID%%.*}
    else
        OS_VERSION=""
    fi
else
    error "Cannot detect OS"
    exit 1
fi

# Wait for package manager lock (up to 60 seconds)
wait_for_lock() {
    local pkg_manager=$1
    local lock_file=""
    local max_wait=60
    local waited=0
    
    case $pkg_manager in
        "apt")
            lock_file="/var/lib/dpkg/lock-frontend"
            ;;
        "yum"|"dnf")
            lock_file="/var/run/yum.pid"
            ;;
    esac
    
    if [ -n "$lock_file" ] && [ -f "$lock_file" ]; then
        info "Waiting for package manager lock to be released..."
        while fuser "$lock_file" >/dev/null 2>&1 && [ $waited -lt $max_wait ]; do
            sleep 2
            waited=$((waited + 2))
        done
        
        if [ $waited -ge $max_wait ]; then
            error "Package manager is locked. Please try again later."
            exit 1
        fi
    fi
}

install_htop_redhat() {
    local version=$1
    
    wait_for_lock "dnf"
    
    case $version in
        9)
            info "Installing EPEL repository for Oracle Linux/RHEL 9..."
            if ! sudo dnf install -y oracle-epel-release-el9 2>/dev/null; then
                # Fallback for RHEL 9
                if ! sudo dnf install -y epel-release; then
                    error "Failed to install EPEL repository"
                    exit 1
                fi
            fi
            sudo dnf config-manager --enable ol9_developer_EPEL 2>/dev/null || true
            ;;
        8)
            info "Installing EPEL repository for RHEL/CentOS 8..."
            if ! sudo dnf install -y epel-release; then
                error "Failed to install EPEL repository"
                exit 1
            fi
            ;;
        7)
            info "Installing EPEL repository for RHEL/CentOS 7..."
            if ! sudo yum install -y epel-release; then
                error "Failed to install EPEL repository"
                exit 1
            fi
            ;;
        6)
            info "Installing EPEL repository for RHEL/CentOS 6..."
            if ! sudo yum install -y epel-release; then
                error "Failed to install EPEL repository"
                exit 1
            fi
            ;;
        *)
            error "Unsupported RHEL/CentOS version: $version"
            exit 1
            ;;
    esac
    
    info "Installing htop..."
    if command -v dnf >/dev/null 2>&1; then
        if ! sudo dnf install -y htop; then
            error "Failed to install htop"
            exit 1
        fi
    else
        if ! sudo yum install -y htop; then
            error "Failed to install htop"
            exit 1
        fi
    fi
}

install_htop_debian() {
    wait_for_lock "apt"
    
    info "Updating package list..."
    if ! sudo apt update; then
        error "Failed to update package list"
        exit 1
    fi
    
    info "Installing htop..."
    if ! sudo apt install -y htop; then
        error "Failed to install htop"
        exit 1
    fi
}

install_htop_arch() {
    info "Installing htop..."
    if ! sudo pacman -S --noconfirm htop; then
        error "Failed to install htop"
        exit 1
    fi
}

install_htop_suse() {
    info "Installing htop..."
    if ! sudo zypper install -y htop; then
        error "Failed to install htop"
        exit 1
    fi
}

install_htop_alpine() {
    info "Updating package index..."
    if ! sudo apk update; then
        error "Failed to update package index"
        exit 1
    fi
    
    info "Installing htop..."
    if ! sudo apk add htop; then
        error "Failed to install htop"
        exit 1
    fi
}

case $OS in
    "ol"|"rhel"|"centos"|"rocky"|"almalinux")
        install_htop_redhat "$OS_VERSION"
        ;;
    "fedora")
        wait_for_lock "dnf"
        info "Installing htop..."
        if ! sudo dnf install -y htop; then
            error "Failed to install htop"
            exit 1
        fi
        ;;
    "ubuntu"|"debian"|"linuxmint"|"pop")
        install_htop_debian
        ;;
    "arch"|"manjaro"|"endeavouros")
        install_htop_arch
        ;;
    "opensuse"|"opensuse-leap"|"opensuse-tumbleweed"|"sles")
        install_htop_suse
        ;;
    "alpine")
        install_htop_alpine
        ;;
    *)
        error "Unsupported OS: $OS"
        info "Please install htop manually for your distribution"
        exit 1
        ;;
esac

if command -v htop >/dev/null 2>&1; then
    success "htop installed successfully ($(htop --version | head -n1))"
else
    error "htop installation failed - htop command not found"
    exit 1
fi
