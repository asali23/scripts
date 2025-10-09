# Windows Utility Scripts

**1. delete_directory.bat** is a useful script for deleting directories with unusually long file paths which can cause Windows explorer to crash or stop responding.
```
delete_directory.bat C:\workspace\my_git_repo
```
Note: This is a core script that other scripts may depend on. Make sure it's present in the same directory as other scripts.

**2. delete_old_system_directory.bat** is a useful script for deleting an old windows installation system directory after upgrading Windows (e.g., upgrading to Windows 10 from Windows 7).
```
delete_old_system_directory.bat C:\windows.old
```
**Note:** 
- Requires administrator privileges
- Uses `takeown` and `cacls` commands to handle file permissions before deletion
- For more information, see: https://www.ghacks.net/2017/07/12/remove-the-windows-old-folder-manually/

**3. delete_ms_teams_app_data.bat** is a useful script for deleting the data of MS Teams. It's useful to work around the problem of malfunctioning/missing TPM chip because of which MS Teams App fails to login. Deleting its data allows you to have a fresh login every time and then you can use the MS Teams App as long as your laptop is ON.
```
delete_ms_teams_app_data.bat
```
**Note:**
- This script depends on `delete_directory.bat` being present in the same directory
- Specifically deletes the MS Teams data from `%appdata%\Microsoft\Teams`