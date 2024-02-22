# Define the name of the folder containing the PowerShell script
$folderName = "ServerScriptDayZ"
$scriptName = "DAYZserver.ps1"

# Change directory to the root of the drive to search all directories
Set-Location -Path "$($env:SystemDrive)\"

# Search for the folder containing the script file
$folderPath = Get-ChildItem -Path $env:SystemDrive -Directory -Recurse -Filter $folderName | Select-Object -ExpandProperty FullName

if ($folderPath) {
    # Change directory to the folder containing the script file
    Set-Location -Path $folderPath

    # Search for the script file in the folder and its subdirectories
    $scriptPath = Get-ChildItem -Path $folderPath -Recurse -Filter $scriptName | Select-Object -ExpandProperty FullName

    if ($scriptPath) {
        # Create shortcut on desktop to run the script
        $shortcutPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "Run $scriptName.lnk")
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$scriptPath`""
        $Shortcut.Save()
    } else {
        Write-Host "Script '$scriptName' not found in the folder '$folderName' or its subdirectories."
    }
} else {
    Write-Host "Folder '$folderName' not found on drive $($env:SystemDrive)."
}