# modify_git_commit.sh

Rewrite Git history to update the author/committer date and/or message of a specific commit.

Modify timestamp and/or message of a specified commit hash in one command. Supports current time (`now`) or RFC2822 formatted dates. Uses `git filter-branch` to rewrite history from the target commit onwards.

**Must be run from the repository root. Clean working tree recommended** (uncommitted changes may interfere).

| Without this script | With this script |
|---------|-------------|
| `git rebase -i HEAD~N`, mark edit, amend, continue | `./modify_git_commit.sh -t now abc123` |
| Complex interactive rebase for simple fixes | One command with validation |
| Manual date formatting | Accepts "now" or RFC2822 dates |

## Usage

```bash
./modify_git_commit.sh [-v] (-t [timestamp|now] | -m message | -t [timestamp|now] -m message) <commit_hash>
```

## Options
- `-v` – verbose mode with detailed progress
- `-t [timestamp|now]` – update timestamp (uses current time if no value provided)
- `-m message` – new commit message
- `commit_hash` – hash of commit to modify (required, must be last)

At least one of `-t` or `-m` must be specified.

## Examples

```bash
# Update timestamp to current time
./modify_git_commit.sh -t abc123

# Update to specific date
./modify_git_commit.sh -t "Thu, 13 Nov 2025 13:50:00 +0000" abc123

# Update message only
./modify_git_commit.sh -m "New commit message" abc123

# Update both
./modify_git_commit.sh -t now -m "Updated commit" abc123

# Verbose mode
./modify_git_commit.sh -v -t now -m "Updated commit" abc123
```

## Sample Output

```
Warning: git filter-branch is deprecated. Consider installing git-filter-repo for better performance.
Rewrite 3a4b5c6d7e8f9g0h1i2j3k4l5m6n7o8p9q0r1s (2/5) (--- seconds passed, remaining --- seconds)
Rewrite a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t (4/5) (--- seconds passed, remaining --- seconds)

Commit a1b2c3d has been updated.
New commit hash: d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v
New date: Mon, 28 Apr 2025 14:30:00 +0000
New message: Updated commit message

Note: This rewrites history. Force pushing will overwrite remote commits.
IMPORTANT: Push rewritten history with: git push origin main --force (or use --force-with-lease)
```

## Warnings
- **Rewrites Git history** – all commits from the target onwards get new hashes
- Requires force push: `git push origin BRANCH_NAME --force`
- Consider `--force-with-lease` for safer pushing
- `git filter-branch` is deprecated; install `git-filter-repo` for better performance
