# Utility Scripts

Helper scripts for Windows cleanup, Git maintenance, and SSH onboarding.

## Windows

Batch files live under the `windows/` directory.

| Tool | Language(s) | Description |
| :--- | :--- | :--- |
| [Delete Directory](./windows/delete_directory.md) | Batch | Purges directories with deeply nested or long paths by mirroring an empty temp folder before removal. |
| [Delete Old System Directory](./windows/delete_old_system_directory.md) | Batch | Takes ownership of `Windows.old` (or similar) and removes it after an OS upgrade. |
| [Delete MS Teams App Data](./windows/delete_ms_teams_app_data.md) | Batch | Clears the Microsoft Teams cache by reusing the Delete Directory tool. |

## Git

Shell scripts live under the `git/` directory.

| Tool | Language(s) | Description |
| :--- | :--- | :--- |
| [Configure Git](./git/configure_git.md) | Bash | Applies a standard set of Git configuration defaults including user info and credential caching. |
| [Cleanup Git Branches](./git/cleanup_git_branches.md) | Bash | Prunes merged branches and can register a reusable `git local-prune` alias. |

## SSH

Shell scripts live under the `ssh/` directory.

| Tool | Language(s) | Description |
| :--- | :--- | :--- |
| [Setup SSH Key](./ssh/README.md) | Bash | Generates (or reuses) an SSH key and installs it on a remote host for passwordless login. |

## Contributing

Open a pull request if you have improvements or additional scripts to share.