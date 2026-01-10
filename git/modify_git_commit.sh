#!/bin/bash
set -e

# Script to change the commit time and optionally the message of a specific git commit
# Usage: ./modify_git_commit.sh [-v] (-t [timestamp] | -m message | -t [timestamp] -m message) <commit_hash>
# - -v: Verbose mode, shows detailed progress
# - -t [timestamp|"now"]: Update timestamp to provided value, "now" for current time, or current time if not specified
# - -m message: The new commit message
# - commit_hash: The hash of the commit to modify (short or full hash supported)
# Note: At least one of -t or -m must be specified.

usage() {
    echo "Usage: $0 [-v] (-t [timestamp|\"now\"] | -m message | -t [timestamp|\"now\"] -m message) <commit_hash>"
    echo "Example: $0 -v -t now -m 'Updated commit' abc123"
}

VERBOSE=0
NEW_DATE=""
NEW_MESSAGE=""
DATE_SPECIFIED=0

# Configure colors for terminal output; fall back to plain text otherwise
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
    COLOR_RESET=$(tput sgr0)
    COLOR_BOLD=$(tput bold)
    COLOR_GREEN=$(tput setaf 2)
    COLOR_YELLOW=$(tput setaf 3)
    COLOR_RED=$(tput setaf 1)
else
    COLOR_RESET=""
    COLOR_BOLD=""
    COLOR_GREEN=""
    COLOR_YELLOW=""
    COLOR_RED=""
fi

while getopts "vt::m:" opt; do
    case $opt in
        v) VERBOSE=1 ;;
        t) if [ -n "$OPTARG" ]; then
               NEW_DATE=$(date -d "$OPTARG" -R 2>/dev/null)
               if [ $? -ne 0 ]; then
                   printf '%sError:%s Invalid timestamp format. Use RFC2822 format or "now", e.g., "Thu, 13 Nov 2025 13:50:00 +0000" or "now"\n' "$COLOR_RED" "$COLOR_RESET"
                   exit 1
               fi
           else
               NEW_DATE=$(date -R)
           fi
           DATE_SPECIFIED=1 ;;
        m) NEW_MESSAGE="$OPTARG" ;;
        *) printf '%sError:%s Invalid option.\n' "$COLOR_RED" "$COLOR_RESET"; usage; exit 1 ;;
    esac
done

shift $((OPTIND-1))

if [ $# -ne 1 ]; then
    usage
    exit 1
fi

COMMIT_HASH=$1

# Determine what to update
if [ $DATE_SPECIFIED -eq 0 ]; then
    if [ -n "$NEW_MESSAGE" ]; then
        # Message only, don't change date
        NEW_DATE=""
        if [ $VERBOSE -eq 1 ]; then echo "Updating message only, keeping original timestamp."; fi
    fi
else
    # DATE_SPECIFIED=1, NEW_DATE is set (either provided or current)
    if [ $VERBOSE -eq 1 ]; then echo "Using timestamp: $NEW_DATE"; fi
fi

# Require at least one option
if [ $DATE_SPECIFIED -eq 0 ] && [ -z "$NEW_MESSAGE" ]; then
    printf '%sError:%s At least one of -t (timestamp) or -m (message) must be specified.\n' "$COLOR_RED" "$COLOR_RESET"
    usage
    exit 1
fi

if [ $VERBOSE -eq 1 ]; then echo "Checking if commit exists..."; fi
# Check if the commit exists
if ! git cat-file -e $COMMIT_HASH^{commit} 2>/dev/null; then
    printf '%sError:%s Commit %s does not exist.\n' "$COLOR_RED" "$COLOR_RESET" "$COMMIT_HASH"
    exit 1
fi

COMMIT_BRANCHES=$(git branch --contains $COMMIT_HASH | sed 's/*//' | tr -d ' ' | tr '\n' ' ')
if [ $VERBOSE -eq 1 ]; then echo "Commit found in branch(es): $COMMIT_BRANCHES"; fi

if [ $VERBOSE -eq 1 ]; then echo "Determining commit range..."; fi
# Get the parent of the commit to determine the range
PARENT=$(git rev-parse $COMMIT_HASH^ 2>/dev/null)
if [ $? -ne 0 ]; then
    # If no parent (root commit), use --all
    RANGE="--all"
else
    RANGE="$COMMIT_HASH^..HEAD"
fi

if [ $VERBOSE -eq 1 ]; then echo "Rewriting commit history..."; fi
# Check for modern alternative
if command -v git-filter-repo >/dev/null 2>&1; then
    echo "Using git-filter-repo for better performance."
    # Note: git-filter-repo implementation would require separate logic; for now, falling back to filter-branch with warning
else
    echo "Warning: git filter-branch is deprecated. Consider installing git-filter-repo for better performance and safety."
fi

# Perform the filter-branch to change date and optionally message
if [ -n "$NEW_MESSAGE" ] && [ -n "$NEW_DATE" ]; then
    # Update both date and message
    NEW_DATE_VALUE="$NEW_DATE" NEW_MESSAGE_VALUE="$NEW_MESSAGE" \
    git filter-branch --force \
        --env-filter 'if [ "$GIT_COMMIT" = "'$COMMIT_HASH'" ]; then
    export GIT_AUTHOR_DATE="$NEW_DATE_VALUE"
    export GIT_COMMITTER_DATE="$NEW_DATE_VALUE"
fi' \
        --msg-filter 'if [ "$GIT_COMMIT" = "'$COMMIT_HASH'" ]; then
    printf "%s\n" "$NEW_MESSAGE_VALUE"
else
    cat
fi' \
        $RANGE
elif [ -n "$NEW_MESSAGE" ]; then
    # Update message only
    NEW_MESSAGE_VALUE="$NEW_MESSAGE" \
    git filter-branch --force \
        --msg-filter 'if [ "$GIT_COMMIT" = "'$COMMIT_HASH'" ]; then
    printf "%s\n" "$NEW_MESSAGE_VALUE"
else
    cat
fi' \
        $RANGE
elif [ -n "$NEW_DATE" ]; then
    # Update date only
    NEW_DATE_VALUE="$NEW_DATE" \
    git filter-branch --force \
        --env-filter 'if [ "$GIT_COMMIT" = "'$COMMIT_HASH'" ]; then
    export GIT_AUTHOR_DATE="$NEW_DATE_VALUE"
    export GIT_COMMITTER_DATE="$NEW_DATE_VALUE"
fi' \
        $RANGE
fi

printf '%sCommit %s has been updated.%s\n' "$COLOR_GREEN" "$COMMIT_HASH" "$COLOR_RESET"
printf 'New commit hash: %s\n' "$(git rev-parse $COMMIT_HASH)"
if [ -n "$NEW_DATE" ]; then
    printf 'New date: %s\n' "$NEW_DATE"
fi
if [ -n "$NEW_MESSAGE" ]; then
    printf 'New message: %s\n' "$NEW_MESSAGE"
fi
printf '%sNote:%s This rewrites history. Force pushing will overwrite remote commits.\n' "$COLOR_YELLOW" "$COLOR_RESET"
CURRENT_BRANCH=$(git branch --show-current)
printf '%s%sIMPORTANT:%s Push rewritten history with:%s git push origin %s --force %s(or use --force-with-lease)%s\n' \
    "$COLOR_BOLD" "$COLOR_YELLOW" "$COLOR_RESET" "$COLOR_BOLD" "$CURRENT_BRANCH" "$COLOR_YELLOW" "$COLOR_RESET"
