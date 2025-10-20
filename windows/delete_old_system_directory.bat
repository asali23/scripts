@echo OFF
SETLOCAL
SET "TARGET_DIR=%~1"
IF "%TARGET_DIR%"=="" (
    ECHO Usage: %~nx0 "C:\\Windows.old"
    EXIT /B 1
)
ECHO Taking ownership of %TARGET_DIR% ...
takeown /F "%TARGET_DIR%\*" /R /A /D Y
ECHO Granting administrator permissions ...
cacls "%TARGET_DIR%\*.*" /T /grant administrators:F
ECHO Removing %TARGET_DIR% ...
rmdir /S /Q "%TARGET_DIR%"
ENDLOCAL

:: Reference: https://www.ghacks.net/2017/07/12/remove-the-windows-old-folder-manually/
