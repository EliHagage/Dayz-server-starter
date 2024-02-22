$RestartmyPID = $PID
# Determine the main script folder based on the current script location
$MainFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
# If the script is run from the website, adjust the main folder accordingly
if ($MainFolder -like "*\servercontrol\public\settings\") {
    $MainFolder = Split-Path -Parent (Split-Path -Parent $MainFolder)
}
# Read arguments from the configuration file
$configFilePath = "$MainFolder\Restart_Config.json"
$config = Get-Content $configFilePath | ConvertFrom-Json
# Ensure that the $timeToRestart is of type [int]
$timeToRestart = [int]$config.timeToRestart
$serverIP = $config.serverIP
$rconPort = $config.RconPort
$serverName = $config.serverName
$rconPassword = $config.rconPassword
$MainFolder = $config.ScriptFolder
$settingsFilePath = "$MainFolder\settings.json"
$jsonsettingsContent = Get-Content $settingsFilePath  | ConvertFrom-Json
$serverConfig = $jsonsettingsContent.ServerConfigurations
$serverConfig1 = $jsonsettingsContent.ScriptConfig
$serverIP
$rconPort
$serverName
$rconPassword
$timeToRestart
$MainFolder
# Function to send a warning message
function SendWarning {
    param (
        [string]$message
    )
    # Send the message using rcon.exe
    Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $RconPort ""$RconPassword"" ""Say -1 $message"""
	$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
	# Clear the log file
    Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
}
$configFilePath = "$($MainFolder)\Restart_Config.json"
Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $RconPort ""$RconPassword"" ""Say -1 Admin Set restart Time to $timeToRestart minutes """
$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
# Clear the log file
Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
# Convert minutes to seconds
$totalSeconds = $timeToRestart * 60

Set-Content "$($MainFolder)$($RconPort)RestartPID.txt" -Value $RestartmyPID

$configFilePath = "$($MainFolder)\Restart_Config.json"
Set-Content $configFilePath -Value ""
$delay=60
    # Send warning messages at the specified intervals
    for ($i = $totalSeconds; $i -ge 60; $i=$i-$delay) 
	{
        if ($i -ge 3600) 
		{
			$delay = 3600
            $hours = [math]::Floor($i / 3600)
            $remainingMinutes = $i % 60
            $message = "WARNING.. Server Restarting in $hours hour(s) $remainingMinutes minute(s)"
            SendWarning -message $message
        }
		else
		{
			if ($i -lt 900)
			{
				$delay = 60
				$minutes = [math]::Floor($i / $delay)
				$message = "WARNING.. Server Restarting in $minutes minute(s)"
				SendWarning -message $message
			}
		}       
	Start-Sleep -Seconds $delay
    }
    # Countdown for the last 120 seconds
    for ($i = 120; $i -ge 0; $i--) 
	{
        $message = "WARNING.. Server Restarting in $i seconds"
        SendWarning -message $message
        Start-Sleep -Seconds 1
    }
    # Trigger the server restart
    SendWarning -message "WARNING.. Server Restarting Now"
	Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $RconPort ""$RconPassword"" ""#lock"""
	$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
	# Clear the log file
    Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
	Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $RconPort ""$RconPassword"" ""#kick -1"""
	$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
	# Clear the log file
    Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
    Start-Sleep -Seconds 60  # Sleep for 10 seconds before triggering the server restart (adjust as needed)
    Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $RconPort ""$RconPassword"" ""#shutdown"""
	$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
	# Clear the log file
    Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
$configFilePath = "$($MainFolder)\Restart_Config.json"
Set-Content $configFilePath -Value ""
# Wait for the job to finish
Wait-Job -Job $job
# Clean up the job
Remove-Job -Job $job
Write-Host "Server restart process completed."