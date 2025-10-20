# configure_git.sh

`configure_git.sh` applies a consistent set of Git settings for everyday development.

## What it does
- Accepts your name and email as command-line parameters, then writes them to the global Git config.
- Tweaks performance options like buffer size and pack limits.
- Normalizes line endings and enables colored output (auto-detects Windows hosts to use `core.autocrlf=true`).
- Enables credential caching for 24 hours so you are not prompted repeatedly.

## How to use
1. Run the script from any directory and pass the name and email you want recorded:
   ```bash
   ./configure_git.sh --name "Your Name" --email "your.email@example.com"
   ```
2. Verify the values were applied:
   ```bash
   git config --list
   ```

## Notes
- All configuration changes are applied with `--global`.
- When run from Git Bash on Windows the script also sets `core.filemode=false` to avoid noisy permission diffs.
