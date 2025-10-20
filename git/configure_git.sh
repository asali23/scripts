#!/bin/bash

#############################################################
# Git Configuration Script
#############################################################

#############################################################
# COMMAND-LINE PARAMETERS
#############################################################
NAME=""
EMAIL=""

print_usage() {
        cat <<USAGE
Usage: $0 --name "Full Name" --email "user@example.com" [options]

Required arguments:
    --name   Git user.name value
    --email  Git user.email value

Optional arguments:
    -h, --help  Show this help message and exit
USAGE
}

#############################################################
# USAGE GUIDE
#############################################################
#
# PURPOSE:
#   This script configures Git with optimal settings for performance and usability.
#
# BEFORE RUNNING:
#   1. Gather the name and email you want to store in your Git config.
#
# HOW TO USE:
#   1. Run script:         ./configure_git.sh --name "Full Name" --email "user@example.com"
#   2. Verify settings:    git config --list
#
# WHAT THIS CONFIGURES:
#   - User identity (name, email)
#   - Performance optimizations (buffer sizes, compression)
#   - Line ending normalization
#   - Credential caching (5 hours timeout)
#

#############################################################
# Validation checks
#############################################################
# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "ERROR: --name requires a value."
                echo ""
                print_usage
                exit 1
            fi
            NAME="$2"
            shift 2
            ;;
        --email)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "ERROR: --email requires a value."
                echo ""
                print_usage
                exit 1
            fi
            EMAIL="$2"
            shift 2
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

if [[ -z "$NAME" || -z "$EMAIL" ]]; then
    echo "ERROR: --name and --email are required."
    echo ""
    print_usage
    exit 1
fi

echo "Starting Git configuration..."
#
#############################################################
# Detect host platform
#############################################################
UNAME_OUT=$(uname 2>/dev/null | tr '[:upper:]' '[:lower:]')
PLATFORM="unix"
case "$UNAME_OUT" in
    mingw*|msys*|cygwin*)
        PLATFORM="windows"
        ;;
esac

echo "Detected platform: $PLATFORM"

#############################################################
# Set user identity (replace with your actual information)
#############################################################
git config --global user.name "$NAME"
git config --global user.email "$EMAIL"

#############################################################
# Performance and memory settings
#############################################################
# http.postBuffer: Increases the buffer size for HTTP operations
# This is especially useful when pushing large repositories or files
git config --global http.postBuffer 1048576000

# pack.packSizeLimit: Controls the maximum size of a pack file
# Smaller pack files reduce memory usage during clone/fetch operations
git config --global pack.packSizeLimit 50m

# pack.windowMemory: Limits memory used during pack file creation
# Helps prevent Git from consuming too much RAM on systems with limited resources
git config --global pack.windowMemory 50m

# core.compression: Sets the compression level used by Git
# Level 5 provides a good balance between compression ratio and speed
# Range is 0 (no compression) to 9 (maximum compression)
git config --global core.compression 5

#############################################################
# User interface settings
#############################################################
# color.ui: Enables colored output in Git commands for improved readability
# Makes it easier to distinguish different types of information in Git output
git config --global color.ui auto

# core.autocrlf: Handles line ending conversions between operating systems
# Use platform-specific defaults: 'true' for Windows Git, 'input' elsewhere
CORE_AUTOCRLF="input"
if [[ "$PLATFORM" == "windows" ]]; then
    CORE_AUTOCRLF="true"
fi
git config --global core.autocrlf "$CORE_AUTOCRLF"

# core.filemode: Prevent Git on Windows from flagging permission changes
if [[ "$PLATFORM" == "windows" ]]; then
    git config --global core.filemode false
fi

#############################################################
# Security and compatibility settings
#############################################################
# credential.helper: Stores credentials temporarily to avoid repeated password entry
# Timeout value (86400 seconds = 24 hours) determines how long credentials are cached
git config --global credential.helper 'cache --timeout=86400'

echo "Git configuration completed successfully!"
echo "To verify your settings, run: git config --list"
