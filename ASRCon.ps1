# Determine the main script folder based on the current script location
# Define the base folder for the script
$Mainfolder = Split-Path -Parent $MyInvocation.MyCommand.Path

# Read the JSON configuration file
$settingsFilePath = Join-Path -Path $MainFolder -ChildPath "settings.json"
$jsonsettingsContent = Get-Content $settingsFilePath | ConvertFrom-Json
$serverConfig1 = $jsonsettingsContent.ScriptConfig

$settingsFilePath = "$MainFolder\settings.json"
	$settingsFilePath = "$($MainFolder)\settings.json"
    $jsonsettingsContent = Get-Content -Path $settingsFilePath | ConvertFrom-Json
    $serverConfigs = $jsonsettingsContent.ServerConfigurations
    $serverConfig1 = $jsonsettingsContent.ScriptConfig
    $SteamCmdRoot = $serverConfig1.SteamCmdRoot
    $Steamlog = $serverConfig1.Steamlog
    $ScriptFolder = $serverConfig1.ScriptFolder
    $SteamAPPFolder = $serverConfig1.SteamAPPFolder
    $SteamCmdMods = $serverConfig1.SteamCmdMods
    $DayzFolder = $serverConfig1.DayzFolder
    $apiKey = $serverConfig1.SteamApi
    $cmd_string = ""
    $GAME_ID = $serverConfig1.SteamGameID
    $BatchSize = $serverConfig1.ModCount
    $Steam_User_Name = $serverConfig1.Steam_User_Name
    $SteamPassword = $serverConfig1.SteamPassword
    #$Rcon = $serverConfig1.Rcon
    $DiscordUrl = $serverConfig1.DiscordUrl
    $logFilePath = "$($MainFolder)\$Steamlog\workshop_log.txt"
    $timestamp1 = Get-Date -Format "dd-MM-yy HH:mm"
    foreach ($serverConfig in $serverConfigs) {
        $serverName = $serverConfig.Name
        $serverPort = $serverConfig.Port
        $serverMap = $serverConfig.Mapfolder
        $serverIP = $serverConfig.Serverip
        $rconPort = $serverConfig.rconport
        $rconPassword = $serverConfig.rconpassword
        $Serverrestart = $serverConfig.Server_restart
        $modlist = $serverConfig.Args[15]  # TEST
	}

# Define the URL of the PHP script
$url = "http://127.0.0.1:7878/settings/Srcon.php"

# D:\ServerScriptDayZ\servercontrol\public\assets\config.php

# Define basic authentication credentials
$info = Get-Content "$($MainFolder)\servercontrol\userpasword.config"
$info
$info | Where-Object {$_ -match "^(.*):(.*)"}
if($Matches.Count -gt 0)
{
	$username = $Matches[1] 
	$password = $Matches[2] 
	"1"
	$username
	$password
}
"2"
$username
$password
# Convert the password to a secure string
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Create a PSCredential object
$credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)

# Parse command line arguments if provided
if ($args) {
    $ip = $args[0]
    $port = $args[1]
    $password = $args[2]
    $command = $args[3]
} else {
    # Prompt the user for input if parameters are not provided
    $ip = Read-Host "Enter RCON Host"
    $port = Read-Host "Enter RCON Port"
    $password = Read-Host "Enter RCON Password"
    $command = Read-Host "Enter Command"
}

try {
    # Create a hashtable containing the RCON details and the command
    $postData = @{
        host = $ip
        port = [int]$port  # Convert port to integer
        pass = $password
        command = $command
    }

    # Convert the data to JSON
    $jsonData = $postData | ConvertTo-Json

    # Debug: Print JSON data
    Write-Host "JSON Data:"
    Write-Host $jsonData

    # Send POST request to the URL with basic authentication
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $jsonData -ContentType "application/json" -Credential $credential
	
    # Read the log file
    $logData = Get-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"

    # Display the entire log file
    foreach ($line in $logData) {
        Write-Host $line
    }

    # Clear the log file
    #Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"

    # Debug: Print response content
    #Write-Host "Response from Server: $($response)"
} catch {
    Write-Host "Error: $_"
}