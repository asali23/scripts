# Delete MS Teams App Data

Clears the Microsoft Teams cache to resolve login and TPM-related issues.

Remove Teams app data folders that accumulate stale authentication tokens and cached data, forcing a clean re-authentication on next launch.

| Without this script | With this script |
|---------|-------------|
| Manual navigation to hidden AppData folders | `delete_ms_teams_app_data.bat` |
| Risk of deleting wrong folders | Targets only Teams-specific directories |
| Multiple cache locations to remember | Single command clears all locations |

## Prerequisites
- Windows with Microsoft Teams installed
- `delete_directory.bat` must be in the same folder

## Usage

Double-click the batch file or run it from a command prompt:

```
delete_ms_teams_app_data.bat
```
