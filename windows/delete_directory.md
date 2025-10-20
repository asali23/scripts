# Delete Directory

Batch script that removes directories even when Windows Explorer cannot delete them because of long paths or locked metadata.

## Usage

Run the script with the absolute path of the directory you want to remove:

```
delete_directory.bat "C:\\workspace\\my_git_repo"
```

The script mirrors an empty temporary directory over the target to ensure every file and subfolder is purged before removal.
