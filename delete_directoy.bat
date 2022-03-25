SET directory_to_delete=%1
mkdir empty_dir
robocopy /PURGE empty_dir %directory_to_delete%
rmdir /Q /S %directory_to_delete%
rmdir /Q /S empty_dir