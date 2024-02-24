@echo off

echo Setting execution policy...
powershell.exe -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force" 2>nul

echo Running PowerShell script to unblock files...
powershell.exe -ExecutionPolicy Bypass -Command "Get-ChildItem -Recurse | Unblock-File" 2>nul

echo Running PowerShell script...
powershell.exe -ExecutionPolicy Bypass -File "makeshortcut.ps1" 2>nul
