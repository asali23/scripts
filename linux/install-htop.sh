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

# Install EPEL and htop
info "Installing EPEL repository..."
if command -v dnf >/dev/null 2>&1; then
    if ! sudo dnf install -y epel-release; then
        error "Failed to install EPEL repository"
        exit 1
    fi
    if ! sudo dnf install -y htop; then
        error "Failed to install htop"
        exit 1
    fi
else
    if ! sudo yum install -y epel-release; then
        error "Failed to install EPEL repository"
        exit 1
    fi
    if ! sudo yum install -y htop; then
        error "Failed to install htop"
        exit 1
    fi
fi

if command -v htop >/dev/null 2>&1; then
    success "htop installed successfully ($(htop --version | head -n1))"
else
    error "htop installation failed - htop command not found"
    exit 1
fi
