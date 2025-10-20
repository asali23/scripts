# cleanup_git_branches.sh

Removes local branches whose upstream counterparts have been deleted so your repository stays tidy.

## What it does
- Prunes remote-tracking references to synchronize with the remote.
- Lists local branches marked as `: gone` along with the last commit message.
- Confirms before deleting (unless you opt in to auto-confirmation).
- Can create a `git local-prune` alias for future cleanups.

## How to use
Run the script from inside the repository you want to clean:
```bash
./cleanup_git_branches.sh
```

### Options
- `-y`, `--yes`: Skip prompts and automatically create the alias if it is missing.
- `-h`, `--help`: Show usage.

## Git alias
If you allow it, the script registers a global `git local-prune` alias. After that you can simply run `git local-prune` in any repository to prune merged branches.
