# Delete Old System Directory

Removes legacy `Windows.old` directories after an OS upgrade.

Takes ownership, grants full access permissions, and deletes the Windows.old directory that remains after Windows upgrades, reclaiming significant disk space.

| Without this script | With this script |
|---------|-------------|
| Manual Disk Cleanup tool (limited) | `delete_old_system_directory.bat "C:\Windows.old"` |
| Permission denied errors | Automatically takes ownership |
| Multiple permission steps | Single command with admin rights |

## Prerequisites
- Administrator privileges (required)
- Windows 7 or later

## Usage

Run the script from an elevated command prompt and pass the directory you want to remove:

```
delete_old_system_directory.bat "C:\Windows.old"
```
