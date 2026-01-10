# modify_git_commit.sh

## Purpose
The goal of this script is to modify the timestamp and/or commit message of a specific Git commit in the repository history.

`modify_git_commit.sh` rewrites Git history to update the author/committer date and/or message of a specific commit.

## What it does
- Accepts a commit hash (short or full) and modifies its timestamp and/or message
- Can update just the timestamp, just the message, or both simultaneously
- Supports setting timestamp to current time with "now" or a specific RFC2822 formatted date
- Uses `git filter-branch` to rewrite commit history from the specified commit onwards
- Provides colored terminal output for better visibility of warnings and results
- Shows the new commit hash and updated values after modification

## How to use

### Update timestamp only (to current time)
```bash
./modify_git_commit.sh -t abc123
```

### Update timestamp to specific date
```bash
./modify_git_commit.sh -t "Thu, 13 Nov 2025 13:50:00 +0000" abc123
```

### Update timestamp to "now"
```bash
./modify_git_commit.sh -t now abc123
```

### Update commit message only
```bash
./modify_git_commit.sh -m "New commit message" abc123
```

### Update both timestamp and message
```bash
./modify_git_commit.sh -t now -m "Updated commit" abc123
```

### Verbose mode (shows detailed progress)
```bash
./modify_git_commit.sh -v -t now -m "Updated commit" abc123
```

## Options
- `-v`: Verbose mode, shows detailed progress during execution
- `-t [timestamp|"now"]`: Update timestamp to provided value, "now" for current time, or current time if no value specified
- `-m message`: The new commit message
- `commit_hash`: The hash of the commit to modify (required, must be last argument)

**Note:** At least one of `-t` or `-m` must be specified.

## Important Warnings
- **This rewrites Git history** - all commits from the specified commit onwards will have new hashes
- You must force push to update remote branches: `git push origin BRANCH_NAME --force`
- Consider using `--force-with-lease` instead of `--force` for safer pushing
- `git filter-branch` is deprecated; consider installing `git-filter-repo` for better performance
