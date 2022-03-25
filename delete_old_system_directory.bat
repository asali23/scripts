SET directory_to_delete=%1
takeown /F %directory_to_delete%\* /R /A /D Y
cacls %directory_to_delete%\*.* /T /grant administrators:F
rmdir /S /Q %directory_to_delete%


:: Reference: https://www.ghacks.net/2017/07/12/remove-the-windows-old-folder-manually/