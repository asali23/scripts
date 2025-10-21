#!/bin/bash

# disk_space_analyzer.sh - Generic Linux Disk Space Analysis Tool
# Identifies space-saving opportunities across different Linux distributions

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
VERBOSE=false
QUICK_MODE=false
TOTAL_RECLAIMABLE=0

# Show usage information
show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Linux Disk Space Analyzer - Identifies space-saving opportunities

OPTIONS:
    -h, --help          Show this help message
    -v, --verbose       Show detailed output
    -q, --quick         Skip slow operations (large file searches)
    --no-color          Disable colored output

EXAMPLES:
    sudo $(basename "$0")              # Full analysis
    $(basename "$0") --quick           # Quick scan
    sudo $(basename "$0") --verbose    # Detailed output

EOF
    exit 0
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -q|--quick)
                QUICK_MODE=true
                shift
                ;;
            --no-color)
                RED='' GREEN='' YELLOW='' BLUE='' CYAN='' NC=''
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                ;;
        esac
    done
}

# Distribution detection
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_NAME=$NAME
        VERSION=$VERSION_ID
    else
        DISTRO=$(uname -s)
        DISTRO_NAME=$DISTRO
        VERSION="unknown"
    fi
    echo -e "${BLUE}Detected distribution: $DISTRO_NAME ${VERSION}${NC}\n"
}

# Log verbose messages
log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}[VERBOSE] $1${NC}"
    fi
}

# Add to reclaimable space total
add_reclaimable() {
    local size=$1
    # Convert to KB for consistent calculation
    local kb=0
    if [[ $size =~ ([0-9.]+)G ]]; then
        kb=$(echo "${BASH_REMATCH[1]} * 1024 * 1024" | bc 2>/dev/null || echo "0")
    elif [[ $size =~ ([0-9.]+)M ]]; then
        kb=$(echo "${BASH_REMATCH[1]} * 1024" | bc 2>/dev/null || echo "0")
    elif [[ $size =~ ([0-9.]+)K ]]; then
        kb=${BASH_REMATCH[1]}
    fi
    TOTAL_RECLAIMABLE=$(echo "$TOTAL_RECLAIMABLE + $kb" | bc 2>/dev/null || echo "$TOTAL_RECLAIMABLE")
}

# Format bytes to human readable
format_size() {
    local kb=$1
    if (( $(echo "$kb >= 1048576" | bc -l) )); then
        echo "$(echo "scale=2; $kb / 1048576" | bc)G"
    elif (( $(echo "$kb >= 1024" | bc -l) )); then
        echo "$(echo "scale=2; $kb / 1024" | bc)M"
    else
        echo "${kb}K"
    fi
}

# Header function
print_header() {
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}=========================================${NC}"
}

# Check root privileges
check_privileges() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}Warning: Some checks require root privileges. Run with sudo for full analysis.${NC}\n"
    fi
}

# Disk usage overview
analyze_disk_usage() {
    print_header "DISK USAGE OVERVIEW"
    df -h | grep -v tmpfs | grep -v devtmpfs | grep -v "^Filesystem"
    
    echo ""
    echo "Inode Usage:"
    df -i | grep -v tmpfs | grep -v devtmpfs | awk 'NR==1 || $5+0 > 50' 2>/dev/null || true
    echo ""
}

# Large package analysis
analyze_large_packages() {
    print_header "LARGEST INSTALLED PACKAGES"
    
    case $DISTRO in
        debian|ubuntu|linuxmint|pop)
            if command -v dpkg-query >/dev/null 2>&1; then
                log_verbose "Analyzing Debian/Ubuntu packages..."
                dpkg-query -Wf '${Installed-Size}\t${Package}\n' 2>/dev/null | \
                awk '{printf "%.1f MB\t%s\n", $1/1024, $2}' | \
                sort -nr | head -15
            fi
            ;;
        fedora|rhel|centos|rocky|almalinux)
            if command -v rpm >/dev/null 2>&1; then
                log_verbose "Analyzing RPM packages..."
                rpm -qa --queryformat '%{SIZE} %{NAME}\n' 2>/dev/null | \
                sort -nr | \
                awk '{printf "%.1f MB\t%s\n", $1/1024/1024, $2}' | \
                head -15
            fi
            ;;
        arch|manjaro|endeavouros)
            if command -v pacman >/dev/null 2>&1; then
                log_verbose "Analyzing Arch packages..."
                pacman -Qi 2>/dev/null | \
                awk '/^Name/{name=$3} /^Installed Size/{print $4" "$5"\t"name}' | \
                sort -hr | head -15
            fi
            ;;
        opensuse*|sles)
            if command -v rpm >/dev/null 2>&1; then
                log_verbose "Analyzing openSUSE packages..."
                rpm -qa --queryformat '%{SIZE} %{NAME}\n' 2>/dev/null | \
                sort -nr | \
                awk '{printf "%.1f MB\t%s\n", $1/1024/1024, $2}' | \
                head -15
            fi
            ;;
        *)
            echo "Package analysis not supported for $DISTRO"
            ;;
    esac
    echo ""
}

# Old kernel analysis
analyze_old_kernels() {
    print_header "OLD KERNEL VERSIONS"
    
    case $DISTRO in
        debian|ubuntu)
            if [ -x "$(command -v dpkg)" ]; then
                current_kernel=$(uname -r)
                echo -e "Current kernel: ${GREEN}$current_kernel${NC}"
                echo -e "\nOther installed kernels:"
                dpkg -l | grep 'linux-image' | grep -v "$current_kernel" | grep -v 'linux-image-generic' | awk '{print $2 " " $3}' || true
            fi
            ;;
        fedora|rhel|centos)
            if [ -x "$(command -v rpm)" ]; then
                current_kernel=$(uname -r)
                echo -e "Current kernel: ${GREEN}$current_kernel${NC}"
                echo -e "\nOther installed kernels:"
                rpm -q kernel | grep -v "$current_kernel" || true
            fi
            ;;
    esac
    echo ""
}

# Package cache analysis
analyze_package_cache() {
    print_header "PACKAGE CACHE SIZE"
    
    case $DISTRO in
        debian|ubuntu|linuxmint|pop)
            if [ -d /var/cache/apt/archives ]; then
                cache_size=$(du -sh /var/cache/apt/archives 2>/dev/null | cut -f1 || echo "0")
                echo -e "APT cache size: ${YELLOW}$cache_size${NC}"
                add_reclaimable "$cache_size"
            fi
            ;;
        fedora|rhel|centos|rocky|almalinux)
            if [ -d /var/cache/dnf ]; then
                cache_size=$(du -sh /var/cache/dnf 2>/dev/null | cut -f1 || echo "0")
                echo -e "DNF cache size: ${YELLOW}$cache_size${NC}"
                add_reclaimable "$cache_size"
            fi
            if [ -d /var/cache/yum ]; then
                cache_size=$(du -sh /var/cache/yum 2>/dev/null | cut -f1 || echo "0")
                echo -e "YUM cache size: ${YELLOW}$cache_size${NC}"
                add_reclaimable "$cache_size"
            fi
            ;;
        arch|manjaro|endeavouros)
            if [ -d /var/cache/pacman/pkg ]; then
                cache_size=$(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f1 || echo "0")
                echo -e "Pacman cache size: ${YELLOW}$cache_size${NC}"
                add_reclaimable "$cache_size"
            fi
            ;;
        opensuse*|sles)
            if [ -d /var/cache/zypp ]; then
                cache_size=$(du -sh /var/cache/zypp 2>/dev/null | cut -f1 || echo "0")
                echo -e "Zypper cache size: ${YELLOW}$cache_size${NC}"
                add_reclaimable "$cache_size"
            fi
            ;;
    esac
    echo ""
}

# Orphaned packages analysis
analyze_orphaned_packages() {
    print_header "ORPHANED PACKAGES"
    
    case $DISTRO in
        debian|ubuntu)
            if [ -x "$(command -v deborphan)" ]; then
                orphaned=$(deborphan 2>/dev/null | wc -l)
                echo -e "Orphaned packages: ${YELLOW}$orphaned${NC}"
                if [ "$orphaned" -gt 0 ]; then
                    echo "List:"
                    deborphan
                fi
            else
                echo "Install 'deborphan' for detailed analysis"
            fi
            ;;
        fedora|rhel|centos)
            if [ -x "$(command -v package-cleanup)" ]; then
                package-cleanup --leaves 2>/dev/null | head -10
            else
                echo "Install 'yum-utils' for leaf package analysis"
            fi
            ;;
    esac
    echo ""
}

# Log files analysis
analyze_log_files() {
    print_header "LARGE LOG FILES"
    
    # Check systemd journal size
    if command -v journalctl >/dev/null 2>&1; then
        journal_size=$(journalctl --disk-usage 2>/dev/null | grep -oP '\d+\.\d+[KMGT]' || echo "unknown")
        echo -e "Systemd journal size: ${YELLOW}$journal_size${NC}"
        if [[ $journal_size =~ ([0-9.]+)G ]] && (( $(echo "${BASH_REMATCH[1]} > 1" | bc -l) )); then
            add_reclaimable "$journal_size"
        fi
    fi
    
    echo ""
    echo "Large log files (>10M):"
    find /var/log -type f -size +10M 2>/dev/null | xargs -r du -h 2>/dev/null | sort -hr | head -10 || echo "None found"
    
    echo ""
    echo "Compressed logs (can be reviewed/removed):"
    find /var/log -type f -name "*.gz" 2>/dev/null | wc -l | xargs echo "Count:" || true
    local gz_size=$(find /var/log -type f -name "*.gz" -exec du -ch {} + 2>/dev/null | tail -1 | cut -f1 || echo "0")
    echo -e "Total size: ${YELLOW}$gz_size${NC}"
    echo ""
}

# Temporary files analysis
analyze_temp_files() {
    print_header "TEMPORARY & CACHE FILES"
    
    for dir in /tmp /var/tmp; do
        if [ -d "$dir" ]; then
            local size=$(du -sh "$dir" 2>/dev/null | cut -f1 || echo "0")
            echo -e "${BLUE}$dir total size: ${YELLOW}$size${NC}"
            if [ "$QUICK_MODE" = false ]; then
                find "$dir" -type f -size +1M 2>/dev/null | head -5 | xargs -r du -h 2>/dev/null | sort -hr || true
            fi
        fi
    done
    
    echo ""
    echo "User cache directories:"
    for cache_dir in ~/.cache ~/.npm ~/.cargo ~/.local/share/Trash; do
        if [ -d "$cache_dir" ]; then
            local size=$(du -sh "$cache_dir" 2>/dev/null | cut -f1 || echo "0")
            echo -e "  $(basename $cache_dir): ${YELLOW}$size${NC}"
        fi
    done
    
    # Thumbnail cache
    if [ -d ~/.cache/thumbnails ]; then
        local thumb_size=$(du -sh ~/.cache/thumbnails 2>/dev/null | cut -f1 || echo "0")
        echo -e "\nThumbnail cache: ${YELLOW}$thumb_size${NC}"
    fi
    
    echo ""
}

# Container and virtualization analysis
analyze_containers() {
    local found_any=false
    
    # Docker
    if command -v docker >/dev/null 2>&1; then
        print_header "DOCKER SYSTEM RESOURCES"
        docker system df 2>/dev/null || true
        echo ""
        found_any=true
    fi
    
    # Podman
    if command -v podman >/dev/null 2>&1; then
        if [ "$found_any" = false ]; then
            print_header "CONTAINER RESOURCES"
        fi
        echo "Podman:"
        podman system df 2>/dev/null || true
        echo ""
        found_any=true
    fi
    
    # Snap packages
    if command -v snap >/dev/null 2>&1; then
        if [ "$found_any" = false ]; then
            print_header "SNAP PACKAGES"
        else
            echo "Snap packages:"
        fi
        local snap_size=$(du -sh /var/lib/snapd/snaps 2>/dev/null | cut -f1 || echo "0")
        echo -e "Total snap size: ${YELLOW}$snap_size${NC}"
        
        # Check for disabled snaps
        local disabled=$(snap list --all 2>/dev/null | grep disabled | wc -l || echo "0")
        if [ "$disabled" -gt 0 ]; then
            echo -e "Disabled snaps (can be removed): ${YELLOW}$disabled${NC}"
        fi
        echo ""
        found_any=true
    fi
    
    # Flatpak
    if command -v flatpak >/dev/null 2>&1; then
        if [ "$found_any" = false ]; then
            print_header "FLATPAK PACKAGES"
        else
            echo "Flatpak packages:"
        fi
        local flatpak_size=$(du -sh ~/.local/share/flatpak 2>/dev/null | cut -f1 || echo "0")
        [ -d /var/lib/flatpak ] && flatpak_size=$(du -sh /var/lib/flatpak 2>/dev/null | cut -f1 || echo "$flatpak_size")
        echo -e "Total flatpak size: ${YELLOW}$flatpak_size${NC}"
        
        # Show unused runtimes
        flatpak list --runtime 2>/dev/null | wc -l | xargs echo "Runtimes installed:" || true
        echo ""
        found_any=true
    fi
}

# Browser cache analysis
analyze_browser_caches() {
    if [ "$QUICK_MODE" = true ]; then
        return
    fi
    
    print_header "BROWSER CACHES"
    
    # Firefox
    if [ -d ~/.mozilla/firefox ]; then
        local ff_size=$(find ~/.mozilla/firefox -type d -name "cache*" -o -name "Cache" 2>/dev/null | xargs -r du -sh 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")
        echo -e "Firefox cache: ${YELLOW}~$(du -sh ~/.mozilla/firefox/*/cache* 2>/dev/null | awk '{s+=$1} END {print s}' || echo "0")${NC}"
    fi
    
    # Chrome/Chromium
    for chrome_dir in ~/.config/google-chrome ~/.config/chromium; do
        if [ -d "$chrome_dir" ]; then
            local chrome_size=$(du -sh "$chrome_dir/Default/Cache" 2>/dev/null | cut -f1 || echo "0")
            echo -e "$(basename $chrome_dir) cache: ${YELLOW}$chrome_size${NC}"
        fi
    done
    
    echo ""
}

# Coredumps and crash reports
analyze_coredumps() {
    print_header "COREDUMPS & CRASH REPORTS"
    
    # Check /var/crash
    if [ -d /var/crash ]; then
        local crash_count=$(find /var/crash -type f 2>/dev/null | wc -l || echo "0")
        local crash_size=$(du -sh /var/crash 2>/dev/null | cut -f1 || echo "0")
        if [ "$crash_count" -gt 0 ]; then
            echo -e "Crash reports in /var/crash: ${YELLOW}$crash_count files ($crash_size)${NC}"
        fi
    fi
    
    # Check systemd coredumps
    if [ -d /var/lib/systemd/coredump ]; then
        local core_count=$(find /var/lib/systemd/coredump -type f 2>/dev/null | wc -l || echo "0")
        local core_size=$(du -sh /var/lib/systemd/coredump 2>/dev/null | cut -f1 || echo "0")
        if [ "$core_count" -gt 0 ]; then
            echo -e "Systemd coredumps: ${YELLOW}$core_count files ($core_size)${NC}"
            add_reclaimable "$core_size"
        fi
    fi
    
    # Check for core files in common locations
    local user_cores=$(find ~ -maxdepth 2 -name "core.*" -o -name "core" -type f 2>/dev/null | wc -l || echo "0")
    if [ "$user_cores" -gt 0 ]; then
        echo -e "Core files in home directory: ${YELLOW}$user_cores${NC}"
    fi
    
    if [ "$crash_count" = "0" ] && [ "$core_count" = "0" ] && [ "$user_cores" = "0" ]; then
        echo "No coredumps found"
    fi
    
    echo ""
}

# Development tools analysis
analyze_dev_tools() {
    print_header "DEVELOPMENT TOOLS & CACHES"
    
    # Language-specific caches
    if [ -d ~/.cargo ]; then
        cargo_size=$(du -sh ~/.cargo 2>/dev/null | cut -f1 || echo "0")
        echo -e "Rust/Cargo cache: ${YELLOW}$cargo_size${NC}"
    fi
    
    if [ -d ~/.npm ]; then
        npm_size=$(du -sh ~/.npm 2>/dev/null | cut -f1 || echo "0")
        echo -e "NPM cache: ${YELLOW}$npm_size${NC}"
    fi
    
    if [ -d ~/.cache/pip ]; then
        pip_size=$(du -sh ~/.cache/pip 2>/dev/null | cut -f1 || echo "0")
        echo -e "Python pip cache: ${YELLOW}$pip_size${NC}"
    fi
    
    if [ -d ~/.gradle ]; then
        gradle_size=$(du -sh ~/.gradle/caches 2>/dev/null | cut -f1 || echo "0")
        echo -e "Gradle cache: ${YELLOW}$gradle_size${NC}"
    fi
    
    if [ -d ~/.m2 ]; then
        maven_size=$(du -sh ~/.m2/repository 2>/dev/null | cut -f1 || echo "0")
        echo -e "Maven repository: ${YELLOW}$maven_size${NC}"
    fi
    
    if [ -d ~/.gem ]; then
        gem_size=$(du -sh ~/.gem 2>/dev/null | cut -f1 || echo "0")
        echo -e "Ruby gems cache: ${YELLOW}$gem_size${NC}"
    fi
    
    echo ""
    
    case $DISTRO in
        debian|ubuntu|linuxmint|pop)
            dev_packages=$(dpkg -l 2>/dev/null | grep -E '(gcc|g\+\+|build-essential|cmake|make|python3-dev|nodejs|npm|git)' | wc -l || echo "0")
            echo -e "Development packages installed: ${YELLOW}$dev_packages${NC}"
            ;;
        fedora|rhel|centos|rocky|almalinux)
            dev_packages=$(rpm -qa 2>/dev/null | grep -E '(gcc|gcc-c++|cmake|make|python3-devel|nodejs|npm|git)' | wc -l || echo "0")
            echo -e "Development packages installed: ${YELLOW}$dev_packages${NC}"
            ;;
        arch|manjaro|endeavouros)
            dev_packages=$(pacman -Qq 2>/dev/null | grep -E '(gcc|cmake|make|python|nodejs|npm|git)' | wc -l || echo "0")
            echo -e "Development packages installed: ${YELLOW}$dev_packages${NC}"
            ;;
    esac
    echo ""
}

# Generate cleanup suggestions
generate_suggestions() {
    print_header "CLEANUP SUGGESTIONS"
    
    echo -e "${GREEN}Safe Cleanup Commands:${NC}"
    echo -e "1. Clean package cache:"
    case $DISTRO in
        debian|ubuntu|linuxmint|pop)
            echo -e "   ${YELLOW}sudo apt clean${NC}"
            echo -e "   ${YELLOW}sudo apt autoclean${NC}  # Remove old package files"
            ;;
        fedora|rhel|centos|rocky|almalinux)
            echo -e "   ${YELLOW}sudo dnf clean all${NC}"
            ;;
        arch|manjaro|endeavouros)
            echo -e "   ${YELLOW}sudo pacman -Sc${NC}  # Clean package cache"
            echo -e "   ${YELLOW}sudo pacman -Scc${NC}  # Clean all cache (aggressive)"
            ;;
        opensuse*|sles)
            echo -e "   ${YELLOW}sudo zypper clean --all${NC}"
            ;;
    esac
    
    echo -e "\n2. Remove orphaned packages:"
    case $DISTRO in
        debian|ubuntu|linuxmint|pop)
            echo -e "   ${YELLOW}sudo apt autoremove --purge${NC}"
            ;;
        fedora|rhel|centos|rocky|almalinux)
            echo -e "   ${YELLOW}sudo dnf autoremove${NC}"
            ;;
        arch|manjaro|endeavouros)
            echo -e "   ${YELLOW}sudo pacman -Rns \$(pacman -Qtdq)${NC}  # Remove orphans"
            ;;
        opensuse*|sles)
            echo -e "   ${YELLOW}sudo zypper packages --unneeded${NC}"
            ;;
    esac
    
    echo -e "\n3. Clean system logs:"
    echo -e "   ${YELLOW}sudo journalctl --vacuum-time=7d${NC}  # Keep last 7 days"
    echo -e "   ${YELLOW}sudo journalctl --vacuum-size=500M${NC}  # Limit to 500MB"
    
    echo -e "\n4. Clean user caches:"
    echo -e "   ${YELLOW}rm -rf ~/.cache/thumbnails/*${NC}"
    echo -e "   ${YELLOW}npm cache clean --force${NC}  # If using npm"
    echo -e "   ${YELLOW}pip cache purge${NC}  # If using pip"
    echo -e "   ${YELLOW}cargo clean${NC}  # In Rust project directories"
    
    echo -e "\n5. Clean temp files:"
    echo -e "   ${YELLOW}sudo rm -rf /tmp/*${NC}"
    echo -e "   ${YELLOW}sudo rm -rf /var/tmp/*${NC}"
    
    echo -e "\n${GREEN}Container/Package-specific:${NC}"
    
    if command -v docker >/dev/null 2>&1; then
        echo -e "6. Docker cleanup:"
        echo -e "   ${YELLOW}docker system prune -a${NC}  # Remove all unused data"
        echo -e "   ${YELLOW}docker volume prune${NC}  # Remove unused volumes"
    fi
    
    if command -v snap >/dev/null 2>&1; then
        echo -e "7. Remove old snap revisions:"
        echo -e "   ${YELLOW}sudo snap list --all | awk '/disabled/{print \$1, \$3}' | while read name rev; do sudo snap remove \"\$name\" --revision=\$rev; done${NC}"
    fi
    
    if command -v flatpak >/dev/null 2>&1; then
        echo -e "8. Flatpak cleanup:"
        echo -e "   ${YELLOW}flatpak uninstall --unused${NC}  # Remove unused runtimes"
    fi
    
    echo -e "\n${GREEN}Advanced (Review carefully before running):${NC}"
    echo -e "9. Remove old kernels (keep current + 1):"
    case $DISTRO in
        debian|ubuntu|linuxmint|pop)
            echo -e "   ${RED}sudo apt autoremove --purge${NC}  # Usually handles old kernels"
            ;;
        fedora|rhel|centos|rocky|almalinux)
            echo -e "   ${RED}sudo dnf remove \$(dnf repoquery --installonly --latest-limit=-2 -q)${NC}"
            ;;
        arch|manjaro|endeavouros)
            echo -e "   ${RED}# Manually remove old kernels from /boot${NC}"
            ;;
    esac
    
    echo -e "\n10. Remove coredumps:"
    echo -e "   ${RED}sudo rm -rf /var/lib/systemd/coredump/*${NC}"
    echo -e "   ${RED}sudo rm -rf /var/crash/*${NC}"
    
    echo -e "\n${YELLOW}⚠ Always review packages/files before removal!${NC}"
    echo -e "${YELLOW}⚠ Make backups of important data first!${NC}"
}

# Display summary
show_summary() {
    print_header "SUMMARY"
    
    echo -e "Total potentially reclaimable space: ${GREEN}$(format_size $TOTAL_RECLAIMABLE)${NC}"
    echo ""
    echo -e "${CYAN}This is an estimate based on caches and temporary files.${NC}"
    echo -e "${CYAN}Actual space freed may vary depending on what you choose to clean.${NC}"
    echo ""
}

# Main function
main() {
    parse_args "$@"
    
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║    Linux Disk Space Analyzer v2.0     ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"
    
    detect_distro
    check_privileges
    
    log_verbose "Starting disk analysis..."
    
    analyze_disk_usage
    analyze_large_packages
    analyze_old_kernels
    analyze_package_cache
    analyze_orphaned_packages
    analyze_log_files
    analyze_coredumps
    analyze_temp_files
    analyze_browser_caches
    analyze_containers
    analyze_dev_tools
    
    show_summary
    generate_suggestions
    
    echo -e "${GREEN}✓ Analysis complete!${NC}"
    echo -e "${CYAN}Run with --help to see available options.${NC}\n"
}

# Run the script
main "$@"