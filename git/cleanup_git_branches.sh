#!/bin/bash

# Script to delete local branches that have been deleted on remote
# Usage: ./cleanup_git_branches.sh [-y|--yes] [-h|--help]

# Function to check if git alias exists
check_git_alias() {
    git config --global alias.local-prune >/dev/null 2>&1
}

# Function to setup git alias
setup_git_alias() {
    local alias_command="!git remote | xargs -n 1 git remote prune && git branch -vv | grep ': gone]' | awk '{print \\$1}' | xargs -r git branch -D"
    git config --global alias.local-prune "$alias_command"
    echo "[OK] Git alias 'git local-prune' has been added to your global git configuration."
    echo "    You can now use 'git local-prune' anywhere to clean up local branches."
}

# Parse command line arguments
AUTO_YES=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [-y|--yes] [-h|--help]"
            echo ""
            echo "Delete local branches that have been deleted on remote."
            echo ""
            echo "Options:"
            echo "  -y, --yes    Skip all prompts and auto-setup git alias if missing"
            echo "  -h, --help   Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Handle git alias setup and usage
if check_git_alias; then
    # Alias exists, use it directly
    echo "Using existing git alias 'git local-prune'..."
    git local-prune
    exit 0
else
    # Alias doesn't exist, set it up
    if [ "$AUTO_YES" = true ]; then
        # Auto mode: setup alias without asking
        setup_git_alias
        echo "Now using the new git alias..."
        git local-prune
        exit 0
    else
        # Interactive mode: ask before setting up alias
        echo ""
        echo "TIP: Git alias 'git local-prune' is not set up."
        echo "     This would allow you to run 'git local-prune' from anywhere to clean up branches."
        read -p "Would you like to set up this git alias now? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            setup_git_alias
            echo "Now using the new git alias..."
            git local-prune
            exit 0
        else
            echo "Continuing with detailed script..."
        fi
    fi
fi

# Prune remote tracking branches first
echo "=== Pruning remote-tracking branches ==="
git remote | xargs -n 1 git remote prune

echo ""
echo "=== Analyzing local branches ==="

# Get branches marked as gone and show details
gone_branches=$(git branch -vv | grep ': gone]')

if [ -z "$gone_branches" ]; then
    echo "No local branches found that are deleted on remote."
    exit 0
fi

echo "Found the following local branches that no longer exist on remote:"
echo ""

# Show detailed information
echo "$gone_branches" | while IFS= read -r line; do
    branch=$(echo "$line" | awk '{print $1}')
    remote_info=$(echo "$line" | grep -o '\[.*: gone\]')
    # Use git log to get the last commit message for this branch
    last_commit=$(git log -1 --format="%h %s" "$branch" 2>/dev/null || echo "No commit info")
    echo "- Branch: $branch"
    echo "  Remote: $remote_info"
    echo "  Last commit: $last_commit"
    echo ""
done

# Add confirmation prompt (unless auto-yes is enabled)
if [ "$AUTO_YES" = false ]; then
    echo "=== Confirmation ==="
    branch_count=$(echo "$gone_branches" | wc -l)
    echo "About to delete $branch_count local branch(es)."
    echo ""
    read -p "Do you want to proceed with deletion? (y/N): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deletion cancelled. No branches were deleted."
        exit 0
    fi
else
    branch_count=$(echo "$gone_branches" | wc -l)
    echo "=== Auto-confirmation enabled ==="
    echo "Proceeding to delete $branch_count local branch(es) without prompt."
fi

echo ""
echo "=== Deleting local branches ==="

# Delete each branch with confirmation
echo "$gone_branches" | awk '{print $1}' | while read -r branch; do
    echo "Deleting branch: $branch"
    if git branch -D "$branch"; then
        echo "[OK] Successfully deleted $branch"
    else
        echo "[FAIL] Could not delete $branch"
    fi
    echo ""
done

echo "=== Cleanup completed ==="
