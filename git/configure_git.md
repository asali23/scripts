# configure_git.sh

## Purpose
The goal of this script is to apply a consistent set of Git settings for everyday development, ensuring that all team members have a similar and optimized Git environment.

`configure_git.sh` applies a consistent set of Git settings for everyday development.

## What it does
- Accepts your name and email as command-line parameters, then writes them to either the global Git config (default) or the repository-local config when `--local` is used.
- Tweaks performance options like buffer size and pack limits.
- Normalizes line endings and enables colored output (auto-detects Windows hosts to use `core.autocrlf=true`).
- Enables credential caching for 24 hours so you are not prompted repeatedly.

## How to use
1. Run the script from any directory and pass the name and email you want recorded:
   ```bash
   ./configure_git.sh --name "Your Name" --email "your.email@example.com"
   ```
   To apply settings only to the current repository instead of globally, add `--local`:
   ```bash
   ./configure_git.sh --name "Your Name" --email "your.email@example.com" --local
   ```
2. Verify the values were applied:
   ```bash
   git config --list
   ```

## Notes
- By default, all configuration changes are applied with `--global`. Use the `--local` flag to target the config of the current repository instead.
- When run from Git Bash on Windows the script also sets `core.filemode=false` to avoid noisy permission diffs.

