# configure_git.sh

Apply a consistent set of Git settings for everyday development. Uses `--global` scope by default; use `--local` for repository-specific settings.

Set user identity (name, email), performance options (buffer sizes, pack limits), line endings (auto-detects Windows for `core.autocrlf` and sets `core.filemode=false` on Windows Git Bash), and credential caching (24 hours) in one command. Preview changes with `--list` before applying.

| Without this script | With this script |
|---------|-------------|
| 10+ manual `git config` commands | `./configure_git.sh --name "X" --email "Y"` |
| Inconsistent settings across machines | Consistent, documented defaults |
| Copy-paste from docs each time | One command with validation |

## Usage

```bash
./configure_git.sh --name "Your Name" --email "your.email@example.com" [options]
```

## Options
- `--local` – apply to repository-local config instead of global
- `--list` – preview changes without applying (dry run)
- `-h`, `--help` – show usage

## Examples

```bash
# Preview what would change
./configure_git.sh --list

# Apply globally (default)
./configure_git.sh --name "Your Name" --email "your.email@example.com"

# Apply to current repository only
./configure_git.sh --name "Your Name" --email "your.email@example.com" --local
```

## Sample Output

Preview mode (`--list`):
```
=== Git Configuration Comparison (--global) ===

Platform: unix

Current -> Proposed:
--------------------
user.name: '<not set>' -> 'Your Name'
user.email: '<not set>' -> 'your.email@example.com'
http.postBuffer: '<not set>' -> '1048576000'
pack.packSizeLimit: '<not set>' -> '50m'
pack.windowMemory: '<not set>' -> '50m'
core.compression: '<not set>' -> '5'
color.ui: '<not set>' -> 'auto'
core.autocrlf: 'input' -> 'input' (no change)
credential.helper: '<not set>' -> 'cache --timeout=86400'

Run without --list to apply these changes.
```

Apply mode:
```
Starting Git configuration (scope: --global)...
Detected platform: unix
Git configuration completed successfully!
To verify your settings (scope: --global), run: git config "--global" --list
```

