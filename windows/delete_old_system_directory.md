# Delete Old System Directory

Removes legacy `Windows.old` directories after an OS upgrade.

## Usage

Run the script from an elevated command prompt and pass the directory you want to remove:

```
delete_old_system_directory.bat "C:\\Windows.old"
```

Administrator privileges are required because the script first takes ownership, then grants full access, and finally deletes the directory.
