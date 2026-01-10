#!/bin/bash

# ctop Installation Script
# Installer for ctop (container top)
# 
# FEATURES:
# - x86_64 architecture support
# - SHA256 checksum verification for security
# - User-level installation (no sudo required)
# - Smart version checking
# - Uninstall functionality
#
# USAGE:
#   ./install-ctop.sh [OPTIONS]
#
# Author: Enhanced version
# Version: 2.0

set -e

# Script configuration
SCRIPT_NAME=$(basename "$0")
VERSION="2.0"
CTOP_REPO="bcicen/ctop"
USER_INSTALL=false
UNINSTALL=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Help function
show_help() {
    cat << EOF
$SCRIPT_NAME - ctop Installation Script v$VERSION

USAGE:
    $SCRIPT_NAME [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -u, --user          Install to user directory (~/.local/bin) without sudo
    --uninstall         Uninstall ctop

EXAMPLES:
    $SCRIPT_NAME                    # Install ctop system-wide
    $SCRIPT_NAME --user             # Install to user directory
    $SCRIPT_NAME --uninstall        # Remove ctop

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -u|--user)
                USER_INSTALL=true
                shift
                ;;
            --uninstall)
                UNINSTALL=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Check if ctop is already installed
check_existing_installation() {
    if command -v ctop >/dev/null 2>&1; then
        local installed_version=$(ctop -v 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        local ctop_path=$(which ctop)
        log_success "ctop is already installed"
        log "Version: $installed_version"
        log "Location: $ctop_path"
        log "Use --uninstall to remove it"
        return 0
    fi
    return 1
}

# Get latest release info from GitHub
get_latest_release_info() {
    local api_url="https://api.github.com/repos/$CTOP_REPO/releases/latest"
    
    # Check if curl is available
    if ! command -v curl >/dev/null 2>&1; then
        log_error "curl is required but not installed"
        return 1
    fi
    
    local response
    if ! response=$(curl -s "$api_url"); then
        log_error "Failed to fetch release information from GitHub"
        return 1
    fi
    
    local download_url
    local checksum_url
    
    if command -v jq >/dev/null 2>&1; then
        # Use jq for proper JSON parsing
        download_url=$(echo "$response" | jq -r '.assets[] | select(.name | contains("linux-amd64")) | .browser_download_url' | head -n1)
        checksum_url=$(echo "$response" | jq -r '.assets[] | select(.name | contains("sha256") or contains("checksums")) | .browser_download_url' | head -n1)
    else
        # Fallback to grep/cut
        download_url=$(echo "$response" | grep -o '"browser_download_url"[^}]*linux-amd64[^"]*' | cut -d'"' -f4 | head -n1)
        checksum_url=$(echo "$response" | grep -o '"browser_download_url"[^}]*\(sha256\|checksums\)[^"]*' | cut -d'"' -f4 | head -n1)
    fi
    
    if [[ -z "$download_url" ]]; then
        log_error "Could not find download URL for linux-amd64"
        return 1
    fi
    
    echo "$download_url|$checksum_url"
}

# Verify checksum
verify_checksum() {
    local file="$1"
    local checksum_url="$2"
    
    if [[ -z "$checksum_url" || "$checksum_url" == "null" ]]; then
        log_warning "No checksum available for verification"
        return 0
    fi
    
    log "Verifying checksum..."
    local temp_checksum=$(mktemp)
    
    if curl -s "$checksum_url" -o "$temp_checksum"; then
        local filename=$(basename "$file")
        local expected_sum=$(grep "$filename" "$temp_checksum" 2>/dev/null | awk '{print $1}' | head -n1)
        
        if [[ -n "$expected_sum" ]]; then
            local actual_sum=$(sha256sum "$file" | awk '{print $1}')
            
            if [[ "$actual_sum" == "$expected_sum" ]]; then
                log_success "Checksum verification passed"
                rm -f "$temp_checksum"
                return 0
            else
                log_error "Checksum verification failed!"
                log_error "Expected: $expected_sum"
                log_error "Actual:   $actual_sum"
                rm -f "$temp_checksum"
                return 1
            fi
        else
            log_warning "Could not find checksum for $filename in checksum file"
        fi
    else
        log_warning "Failed to download checksum file"
    fi
    
    rm -f "$temp_checksum"
    return 0
}

# Install ctop binary
install_ctop_binary() {
    local release_info
    if ! release_info=$(get_latest_release_info); then
        return 1
    fi
    
    local download_url=$(echo "$release_info" | cut -d'|' -f1)
    local checksum_url=$(echo "$release_info" | cut -d'|' -f2)
    
    # Determine installation directory
    local install_dir
    local use_sudo=false
    
    if [[ "$USER_INSTALL" == "true" ]]; then
        install_dir="$HOME/.local/bin"
        mkdir -p "$install_dir"
        log "Installing to user directory: $install_dir"
    else
        install_dir="/usr/local/bin"
        use_sudo=true
        log "Installing to system directory: $install_dir"
        
        # Check for sudo privileges
        if ! sudo -n true 2>/dev/null; then
            log_error "This script requires sudo privileges for system installation"
            log_error "Use --user flag to install to user directory instead"
            return 1
        fi
    fi
    
    # Download to temporary file first
    local temp_file=$(mktemp)
    
    log "Downloading ctop..."
    if ! curl -L "$download_url" -o "$temp_file"; then
        log_error "Failed to download ctop"
        rm -f "$temp_file"
        return 1
    fi
    
    # Verify checksum if available
    if ! verify_checksum "$temp_file" "$checksum_url"; then
        log_error "Checksum verification failed - aborting installation"
        rm -f "$temp_file"
        return 1
    fi
    
    # Install the binary
    local install_cmd="cp '$temp_file' '$install_dir/ctop' && chmod +x '$install_dir/ctop'"
    
    if [[ "$use_sudo" == "true" ]]; then
        if ! sudo sh -c "$install_cmd"; then
            log_error "Failed to install ctop"
            rm -f "$temp_file"
            return 1
        fi
    else
        if ! sh -c "$install_cmd"; then
            log_error "Failed to install ctop"
            rm -f "$temp_file"
            return 1
        fi
    fi
    
    rm -f "$temp_file"
    log_success "ctop binary installed successfully"
    
    # Add to PATH if user install
    if [[ "$USER_INSTALL" == "true" ]] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        log_warning "Add $HOME/.local/bin to your PATH to use ctop:"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

# Uninstall ctop
uninstall_ctop() {
    log "Uninstalling ctop..."
    
    if ! command -v ctop >/dev/null 2>&1; then
        log_warning "ctop is not installed"
        return 0
    fi
    
    local ctop_path=$(which ctop)
    log "Found ctop at: $ctop_path"
    
    # Determine if sudo is needed
    local use_sudo=false
    if [[ "$ctop_path" == "/usr/local/bin/ctop" || "$ctop_path" == "/usr/bin/ctop" ]]; then
        use_sudo=true
    fi
    
    if [[ "$use_sudo" == "true" ]]; then
        if ! sudo -n true 2>/dev/null; then
            log_error "Sudo privileges required to remove ctop from system directory"
            return 1
        fi
        
        if sudo rm -f "$ctop_path"; then
            log_success "ctop uninstalled successfully"
        else
            log_error "Failed to uninstall ctop"
            return 1
        fi
    else
        if rm -f "$ctop_path"; then
            log_success "ctop uninstalled successfully"
        else
            log_error "Failed to uninstall ctop"
            return 1
        fi
    fi
}

# Main installation function
main() {
    parse_args "$@"
    
    # Handle uninstall
    if [[ "$UNINSTALL" == "true" ]]; then
        uninstall_ctop
        exit $?
    fi
    
    log "ctop Installation Script v$VERSION"
    
    # Check existing installation
    if check_existing_installation; then
        exit 0
    fi
    
    # Install binary
    if install_ctop_binary; then
        log_success "ctop installed successfully"
    else
        log_error "Installation failed"
        exit 1
    fi
    
    # Verify installation
    if command -v ctop >/dev/null 2>&1; then
        local version=$(ctop -v 2>/dev/null | head -n1 || echo "unknown")
        log_success "Installation completed successfully!"
        log "Installed version: $version"
        log "Run 'ctop' to start using it"
    else
        log_error "Installation verification failed - ctop command not found"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"