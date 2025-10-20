# Windows Scripts

Utilities for Windows maintenance tasks. Each script lives in this directory with a companion markdown file for usage notes.

* [`delete_directory.bat`](./delete_directory.bat) - purges directories with deeply nested or long paths.
* [`delete_old_system_directory.bat`](./delete_old_system_directory.bat) - takes ownership of `Windows.old` (or similar) and removes it after an OS upgrade.
* [`delete_ms_teams_app_data.bat`](./delete_ms_teams_app_data.bat) - clears the Microsoft Teams cache by reusing `delete_directory.bat`.
