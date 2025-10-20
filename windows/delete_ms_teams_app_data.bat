@echo OFF
SETLOCAL
TITLE Delete Microsoft Teams cache
CALL "%~dp0delete_directory.bat" "%APPDATA%\Microsoft\Teams"
ENDLOCAL
