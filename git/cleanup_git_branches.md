# cleanup_git_branches.sh

Remove local branches whose upstream counterparts have been deleted on the remote.

Prune remote-tracking references, preview branches marked as `: gone` with their last commit message, and batch delete with confirmation (or use `--dry-run` for safety). Optionally create a `git local-prune` alias for zero-friction future cleanups.

**Must be run from within a Git repository.**

| Without this script | With this script |
|---------|-------------|
| `git remote prune origin && git branch -vv \| grep gone` | `./cleanup_git_branches.sh` |
| Manually delete each branch | Preview + batch delete with confirmation |
| Repeat 3 commands weekly | One command or `git local-prune` alias |

## Usage

```bash
./cleanup_git_branches.sh [options]
```

## Options
- `-y`, `--yes` – skip prompts and auto-setup the alias if missing
- `-n`, `--dry-run` – preview what would be deleted without actually deleting
- `-h`, `--help` – show usage

## Examples

```bash
# Preview what would be deleted
./cleanup_git_branches.sh --dry-run

# Actually delete branches (with confirmation)
./cleanup_git_branches.sh

# Skip all prompts
./cleanup_git_branches.sh --yes
```

## Sample Output

```
=== Pruning remote-tracking branches ===
Pruning origin
URL: git@github.com:user/repo.git
 * [pruned] origin/feature/old-branch

=== Analyzing local branches ===
Found the following local branches that no longer exist on remote:

- Branch: feature/old-branch
  Remote: [origin/feature/old-branch: gone]
  Last commit: a1b2c3d Fix the thing

- Branch: hotfix/legacy
  Remote: [origin/hotfix/legacy: gone]
  Last commit: e4f5g6h Emergency patch

=== Confirmation ===
About to delete 2 local branch(es).

Do you want to proceed with deletion? (y/N): y

=== Deleting local branches ===
Deleting branch: feature/old-branch
[OK] Successfully deleted feature/old-branch

Deleting branch: hotfix/legacy
[OK] Successfully deleted hotfix/legacy

=== Cleanup completed ===
```

## Git alias
Allow the script to register the `git local-prune` alias, then run `git local-prune` in any repository to prune merged branches.

