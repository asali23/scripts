# Windows Utility Scripts
1. **delete_directory.bat** is a useful script for deleting the directory with unusually long file paths which can cause Windows explorer to crash or stop responding.
```
delete_directory.bat C:\workspace\my_git_repo
```
2. **delete_old_system_directory.bat** is a useful script for deleting an old windows installation system directory after upgrading Windows. e.g. upgrading to Windows 10 from Windows 7.
```
delete_old_system_directory.bat C:\windows.old
```
3. **delete_ms_teams_app_data.bat** is a useful script for deleting the data of MS Teams. It's a useful to work around the problem of malfunctioning / missing TPM chip because of which MS Teams App fails to login. Deleting its data allows you have a fresh login every time and then you can use the MS Teams App as long as your laptop is ON.
```
delete_ms_teams_app_data.bat
```