#!/bin/bash

# ctop Installation Script - Enhanced Version
# A comprehensive installer for ctop (container top) with multiple installation methods
# 
# FEATURES:
# - Multi-architecture support (x86_64, ARM64, ARM)
# - Multiple package managers (DNF, APT, Pacman, Zypper, APK, Homebrew)
# - SHA256 checksum verification for security
# - User-level installation (no sudo required)
# - Smart version checking
# - Comprehensive error handling
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

# Detect system architecture
detect_arch() {
    local arch=$(uname -m)
    case $arch in
        x86_64|amd64)
            echo "linux-amd64"
            ;;
        aarch64|arm64)
            echo "linux-arm64"
            ;;
        armv7l|arm)
            echo "linux-arm"
            ;;
        *)
            log_error "Unsupported architecture: $arch"
            return 1
            ;;
    esac
}

# Detect OS and package manager
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    else
        log_error "Cannot detect OS"
        return 1
    fi
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v curl >/dev/null 2>&1; then
        missing_deps+=("curl")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_error "Please install them first:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        return 1
    fi
    
    # Check if jq is available for better JSON parsing
    if command -v jq >/dev/null 2>&1; then
        return 0
    else
        return 0
    fi
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
    local arch="$1"
    local api_url="https://api.github.com/repos/$CTOP_REPO/releases/latest"
    
    local response
    if ! response=$(curl -s "$api_url"); then
        log_error "Failed to fetch release information from GitHub"
        return 1
    fi
    
    local download_url
    local checksum_url
    
    if command -v jq >/dev/null 2>&1; then
        # Use jq for proper JSON parsing
        download_url=$(echo "$response" | jq -r ".assets[] | select(.name | contains(\"$arch\")) | .browser_download_url" | head -n1)
        # Try to find checksum file
        checksum_url=$(echo "$response" | jq -r '.assets[] | select(.name | contains("sha256") or contains("checksums")) | .browser_download_url' | head -n1)
    else
        # Fallback to grep/cut
        download_url=$(echo "$response" | grep -o "\"browser_download_url\"[^}]*$arch[^\"]*" | cut -d'"' -f4 | head -n1)
        checksum_url=$(echo "$response" | grep -o "\"browser_download_url\"[^}]*\(sha256\|checksums\)[^\"]*" | cut -d'"' -f4 | head -n1)
    fi
    
    if [[ -z "$download_url" ]]; then
        log_error "Could not find download URL for architecture: $arch"
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
    local arch
    if ! arch=$(detect_arch); then
        return 1
    fi
    
    log "Detecting architecture: $arch"
    
    local release_info
    if ! release_info=$(get_latest_release_info "$arch"); then
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

# Try package manager installation
try_package_manager() {
    local os_id="$1"
    
    # Skip if user installation requested
    if [[ "$USER_INSTALL" == "true" ]]; then
        return 1
    fi
    
    # Skip if no sudo access
    if ! sudo -n true 2>/dev/null; then
        return 1
    fi
    
    log "Trying package manager installation..."
    
    # DNF (Fedora, RHEL, CentOS)
    if command -v dnf >/dev/null 2>&1; then
        if sudo dnf list available ctop >/dev/null 2>&1; then
            log "Installing ctop via DNF..."
            if sudo dnf install -y ctop; then
                return 0
            fi
        fi
    fi
    
    # APT (Debian, Ubuntu)
    if command -v apt >/dev/null 2>&1; then
        if sudo apt-cache show ctop >/dev/null 2>&1; then
            log "Installing ctop via APT..."
            sudo apt update >/dev/null 2>&1
            if sudo apt install -y ctop; then
                return 0
            fi
        fi
    fi
    
    # Pacman (Arch Linux)
    if command -v pacman >/dev/null 2>&1; then
        if pacman -Si ctop >/dev/null 2>&1; then
            log "Installing ctop via Pacman..."
            if sudo pacman -S --noconfirm ctop; then
                return 0
            fi
        fi
    fi
    
    # Zypper (openSUSE)
    if command -v zypper >/dev/null 2>&1; then
        if zypper search ctop >/dev/null 2>&1; then
            log "Installing ctop via Zypper..."
            if sudo zypper install -y ctop; then
                return 0
            fi
        fi
    fi
    
    # APK (Alpine)
    if command -v apk >/dev/null 2>&1; then
        if apk search ctop | grep -q ctop; then
            log "Installing ctop via APK..."
            if sudo apk add ctop; then
                return 0
            fi
        fi
    fi
    
    # Homebrew (Linux)
    if command -v brew >/dev/null 2>&1; then
        if brew search ctop | grep -q ctop; then
            log "Installing ctop via Homebrew..."
            if brew install ctop; then
                return 0
            fi
        fi
    fi
    
    return 1
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
    
    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi
    
    # Detect OS
    local os_id
    if ! os_id=$(detect_os); then
        exit 1
    fi
    
    # Check existing installation
    if check_existing_installation; then
        exit 0
    fi
    
    # Try package manager first
    if try_package_manager "$os_id"; then
        log_success "ctop installed successfully via package manager"
    else
        # Fallback to binary installation
        log "Package manager installation failed or unavailable, trying binary installation..."
        if install_ctop_binary; then
            log_success "ctop installed successfully via binary download"
        else
            log_error "All installation methods failed"
            exit 1
        fi
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