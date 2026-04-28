# Delete Directory

Batch script that removes directories even when Windows Explorer cannot delete them because of long paths or locked metadata.

Mirrors an empty temporary directory over the target to ensure every file and subfolder is purged before removal.

| Without this script | With this script |
|---------|-------------|
| Windows Explorer fails on long paths | `delete_directory.bat "C:\path\to\dir"` |
| Manual unlock of files required | Handles locked metadata automatically |
| Multiple attempts needed | Single command execution |

## Prerequisites
- Administrator privileges (for protected directories)
- Windows 7 or later

## Usage

Run the script with the absolute path of the directory you want to remove:

```
delete_directory.bat "C:\workspace\my_git_repo"
```
