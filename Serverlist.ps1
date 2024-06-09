$ErrorActionPreference = "Stop"
#$myServerlistPID = $PID
# Read the JSON configuration file
# Determine the main script folder based on the current script location
# Define the base folder for the script
$Mainfolder = Split-Path -Parent $MyInvocation.MyCommand.Path

# Read the JSON configuration file
$settingsFilePath = Join-Path -Path $MainFolder -ChildPath "settings.json"
$jsonsettingsContent = Get-Content $settingsFilePath | ConvertFrom-Json
$serverConfig1 = $jsonsettingsContent.ScriptConfig
$serverConfigs = $jsonsettingsContent.ServerConfigurations


$settingsFilePath = "$MainFolder\settings.json"
$jsonsettingsContent = Get-Content $settingsFilePath  | ConvertFrom-Json
$Mod_Info = $jsonsettingsContent.ModInfo

	$settingsFilePath = "$MainFolder\settings.json"
    $jsonsettingsContent = Get-Content -Path $settingsFilePath | ConvertFrom-Json
    $serverConfigs = $jsonsettingsContent.ServerConfigurations
    $serverConfig1 = $jsonsettingsContent.ScriptConfig
    foreach ($serverConfig in $serverConfigs) {
        $serverName = $serverConfig.Name
        $serverPort = $serverConfig.GamePort
        $serverMap = $serverConfig.Mapfolder
        $serverIP = $serverConfig.Serverip
        $rconPort = $serverConfig.rconport
        $rconPassword = $serverConfig.rconpassword
        $Serverrestart = $serverConfig.Server_restart
        $modlist = $serverConfig.Args[15]  # TEST
	}
	
class myserverinfo
{
	[string]$name
	[string]$port
	[int] $adminfo
	[int] $restartinfo
	[int] $Msginfo
}

$myserverinfoarray=@()
# Define constants and variables
$SteamCmdRoot = $serverConfig1.SteamCmdRoot
$Steamlog = $serverConfig1.Steamlog
$ScriptFolder = $serverConfig1.ScriptFolder
$SteamAPPFolder = $serverConfig1.SteamAPPFolder
$SteamCmdMods = $serverConfig1.SteamCmdMods
$DayzFolder = $($serverConfig1.DayzFolder)
$cmd_string = ""
$GAME_ID = $serverConfig1.SteamGameID
$BatchSize = $serverConfig1.ModCount
$Steam_User_Name = $serverConfig1.Steam_User_Name
$SteamPassword = $serverConfig1.SteamPassword
#$Rcon = $($ScriptFolder)\ASRCon.ps1
$DiscordUrl = $serverConfig1.DiscordUrl
#Set-Content "$MainFolder\ServerListPID.txt" -Value $myServerlistPID

$logFilePath = Join-Path -Path $Steamlog -ChildPath "workshop_log.txt"
$timestamp1 = Get-Date -Format "dd-MM-yy HH:mm"


function ShowStatus($message) {
    Write-Host "Status: $message"
}
foreach ($modEntry in $Mod_Info) {
    $modName = $modEntry.Mod_Name
	$modId = $modEntry.Mod_ID
}

function CheckModFoldersExist {
	#$lockFile1 = New-Item "$($MainFolder)\ServerList.lock" -ItemType File -Force
    foreach ($modInfo in $Mod_Info) {
        $modName = $modInfo.Mod_Name
        $modId = $modInfo.Mod_ID
        $modFolderPath = Join-Path $MainFolder\$($DayzFolder) -ChildPath "@$modName"
        $modSourcePath = Join-Path $MainFolder\$($SteamCmdMods) -ChildPath $modId

        if (!(Test-Path $modFolderPath -PathType Container)) {
            $lockFile1 = "$MainFolder\ServerList.lock"
            New-Item $lockFile1 -ItemType File -Force
            ShowStatus "Mod folder for $modName ($modId) does not exist. Creating it..."
            Copy-Item $modSourcePath $modFolderPath -Recurse -Force
            Copy-Item "$modSourcePath\Key*\*.*" "$MainFolder\$DayzFolder\Keys\" -Force
            Remove-Item $lockFile1 -Force
        }
    }
    ShowStatus "Completed Step Check Mod Folders"
	
}

# Loop through each server configuration in the serverConfigs array
foreach ($serverConfig in $configFile.serverConfigs) {
    $startServer = $serverConfig.Startserver
    $serverName = $serverConfig.Name
    $serverPort = $serverConfig.GamePort
    $serverMap = $serverConfig.Mapfolder
    $serverIP = $serverConfig.Serverip
    $rconPort = $serverConfig.rconport
    $rconPassword = $serverConfig.rconpassword
    $Serverrestart = $serverConfig.Server_restart
}

# Define the lock file path
$lockFile = Join-Path -Path $ScriptFolder -ChildPath "$($MainFolder)\copying.lock"

# Check if the lock file exists
while (Test-Path $lockFile) {
    Write-Host "Mod copying job is in progress. Pausing..."
    Start-Sleep -Seconds 15  # Sleep for 20 seconds before checking again
}
function hewzywhatits {
    param (
        [string]$modlist,
        [string]$DayzFolder,
        [string]$mapfolder
    )

    $found = $false
    $newfile = @()
    $mods = @()
    $alreadyfound = $false

    $economycore = Get-Content -Path "$($MainFolder)\$DayzFolder\mpmissions\$mapfolder\cfgeconomycore.xml"
    $modarray = $modlist.Trim("-mod=").Split(";")
    
    foreach ($thismod in $modarray) {
        if ($thismod.Length -gt 0) {
            $thismod1 = $thismod.trim("@")
            $foldertosearch = $DayzFolder

            if (Test-Path "$foldertosearch\$thismod") {
                $modxml = Get-ChildItem "$foldertosearch\$thismod\*.xml" -Recurse
                if ($modxml.Count -gt 0) {
                    $mods += "$thismod.xml"
                }
            }
        }
    }

    foreach ($ec in $economycore) {
        if ($found -eq $false) {
            $aa = $ec | Where-Object {$_ -match "\s*<ce folder=""(db)"""}

            if ($Matches.Count -gt 1) {
                $found = $true
                $Matches.Clear()
            }

            if ($alreadyfound -eq $false) {
                $newfile += $ec
            }

            $aa = $ec | Where-Object {$_ -match "\s*</(ce)>"}

            if ($Matches.Count -gt 1) {
                $newfile += $ec
                $alreadyfound = $false
                $Matches.Clear()
            }
        }
        else {
            foreach ($m in $mods) {
                $mystuff = $m.Trim("@")
                $newfile += "`t`t<file name=""$mystuff"" type=""types"" />"
            }
            $found = $false
            $alreadyfound =$true
        }
    }
    $newfile
}

while ($true) {
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
        $serverPort = $serverConfig.GamePort
        $serverMap = $serverConfig.Mapfolder
        $serverIP = $serverConfig.Serverip
        $rconPort = $serverConfig.rconport
        $rconPassword = $serverConfig.rconpassword
        $Serverrestart = $serverConfig.Server_restart
        $modlist = $serverConfig.Args[15]  # TEST

        # hewzywhatits $modlist $DayzFolder $serverMap

        $runningProcesses = Get-Process | Where-Object { $_.ProcessName -like "DayZServer_x64*" }
        foreach ($process in $runningProcesses) 
		{
            $process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::RealTime
        }
        $existingProcess = $runningProcesses | Where-Object { $_.MainWindowTitle -like "*$serverPort*" }
        if ($serverConfig.Startserver) 
		{
            if (-not $existingProcess) 
			{
#				"aaaaaaaaaaaaaaaaaaaaaaa"
#				if($myserverinfoarray)
#				{
#					foreach ($ser in $myserverinfoarray)
#					{
#						$mycontent = @{
#							name = $myserverinfoarray.name
#							port = $myserverinfoarray.port
#							adminfo = $myserverinfoarray.adminfo
#							restartinfo = $myserverinfoarray.restartinfo
#							Msginfo = $myserverinfoarray.Msginfo
#							}|ConvertTo-Json
#					$mycontent | Add-Content -Path "serverprocess.json"
#				}
#				"bbbbbbbbbbbbbbbbbbbbbb"
                #$processToKill = $myserverinfoarray | Where-Object {$_.name -eq $serverName -and $_.port -eq $serverPort }
                #if($processToKill.Count -gt 0)
                #{
                #    $processToKill
				#	try
				#	{
                #    Stop-Process $($processToKill.adminfo)
                #    Stop-Process $($processToKill.restartinfo)
                #    Stop-Process $($processToKill.Msginfo)
				#	}
				#	catch
				#	{}
                #}
				
				try
				{
				# Read the PID from the file
				$pidFilePath = "$MainFolder\$($RconPort)RestartPID.txt"
				$pid1 = Get-Content $pidFilePath
				# Stop the process with the PID
				kill $pid1
				}
				catch {"pid1 Cant kill it its not there"}
				try
				{
				# Read the PID from the file
				$pidFilePath = "$MainFolder\$($RconPort)ADMPID.txt"
				$pid2 = Get-Content $pidFilePath
				# Stop the process with the PID 
				kill $pid2
				}
				catch {"pid2 Cant kill it its not there"}
				try
				{
				# Read the PID from the file
				$pidFilePath = "$MainFolder\$($RconPort)MSGPID.txt"
				$pid3 = Get-Content $pidFilePath
				# Stop the process with the PID
				kill $pid3
				}
				catch {"pid3 Cant kill it its not there"}
				try
				{
				# Read the PID from the file
				$pidFilePath = "$MainFolder\$($RconPort)JokePID.txt"
				$pid4 = Get-Content $pidFilePath
				# Stop the process with the PID
				kill $pid4
				}
				catch {"pid4 Cant kill it its not there"}
                "$serverName is down...$timestamp"
				Start-Sleep -Seconds 15

                $backupFolder = New-Item -ItemType Directory -Path "$($MainFolder)\$($DayzFolder)\backups\$($serverName)\$(Get-Date -Format yyMMddHHmmss)"
                $logFolder = New-Item -ItemType Directory -Path "$($MainFolder)\$($DayzFolder)\logs\$($serverName)\$(Get-Date -Format yyMMddHHmmss)"
				try
				{
                Move-Item -Path "$MainFolder\$DayzFolder\$($serverName)Pro\*.log" -Destination $logFolder
                Move-Item -Path "$MainFolder\$DayzFolder\$($serverName)Pro\*.RPT" -Destination $logFolder
                Move-Item -Path "$MainFolder\$DayzFolder\$($serverName)Pro\*.ADM" -Destination $logFolder
                Move-Item -Path "$MainFolder\$DayzFolder\$($serverName)Pro\*.mdmp" -Destination $logFolder
                Copy-Item -Path "$MainFolder\$DayzFolder\mpmissions\$serverMap\storage_1\*" -Destination $backupFolder -Recurse
				}
				catch {"didnt copy properly.. continuing"}
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                CheckModFoldersExist
                "Restarting $serverName at $timestamp"
                Start-Process -FilePath "$MainFolder\$($DayzFolder)\DayZServer_x64.exe" -WorkingDirectory $MainFolder\$DayzFolder -ArgumentList @($serverConfig.Args)
                #Start-Sleep -Seconds 145
				$waitcount = 0
				while($true)
				{
					# wait till correct port # is present
					$runningProcesses = Get-Process | Where-Object { $_.ProcessName -like "DayZServer_x64*" }
					$existingProcess = $runningProcesses | Where-Object { $_.MainWindowTitle -like "*$serverPort*" }
					if($existingProcess)
					{
						$waitcount = 0
						# Update Restart_Config.json with new parameters
						$configFilePath0 = "$($MainFolder)\ADM_Config.json"
						$newConfig = @{
							timeToRestart = $Serverrestart
							ServerIP = $serverIP
							RconPort = $rconPort
							serverName = $serverName
							rconPassword = $rconPassword
							ScriptFolder = "$($MainFolder)\"
							DayzFolder = "$($MainFolder)\$($DayzFolder)\"
						} | ConvertTo-Json
		
						$newConfig | Set-Content $configFilePath0
						$thisinfo = [myserverinfo]::new()
						$thisinfo.name = $serverName
						$thisinfo.port = $serverPort #-WindowStyle Hidden
						$qq = Start-Process -FilePath "powershell.exe" -ArgumentList "-File", "$($MainFolder)\ADMProcess.ps1" -WindowStyle Hidden -passthru 
						$thisinfo.adminfo = $qq.Id
						$configFilePath1 = "$($MainFolder)\Restart_Config.json"
						$newConfig = @{
							timeToRestart = $Serverrestart
							ServerIP = $serverIP
							RconPort = $rconPort
							serverName = $serverName
							rconPassword = $rconPassword
							ScriptFolder = "$($MainFolder)\"
						} | ConvertTo-Json
						
						$newConfig | Set-Content $configFilePath1
						$qq =  Start-Process -FilePath "powershell.exe" -ArgumentList "-File", "$($MainFolder)\restartserver.ps1" -WindowStyle Hidden -passthru
						$thisinfo.restartinfo = $qq.Id
		
						#$throwaway = Start-Job -Name "$($serverName)_$($serverPort)" "$($ScriptFolder)ServerMSG.ps1" -ArgumentList "$serverIP", $rconPort, "$rconPassword", $serverName, $ScriptFolder
						$configFilePath2 = "$($MainFolder)\MSG_Config.json"
						$newConfig = @{
							timeToRestart = $Serverrestart
							ServerIP = $serverIP
							RconPort = $rconPort
							serverName = $serverName
							rconPassword = $rconPassword
							ScriptFolder = "$($MainFolder)\"
						} | ConvertTo-Json
						
						$newConfig | Set-Content $configFilePath2
						$qq =  Start-Process -FilePath "powershell.exe" -ArgumentList "-File", "$($MainFolder)\ServerMSG.ps1" -WindowStyle Hidden -passthru
						$qq
						$thisinfo.Msginfo = $qq.Id
						$thisinfo.Msginfo
						$thisinfo.adminfo
						$thisinfo.restartinfo
						$myserverinfoarray += $thisinfo
						break
					}
					Start-Sleep -Seconds 1
					$waitcount++
                    $waitcount
					
					# Abort Code if over 150 seconds
					if($waitcount -ge 150)
					{
						$runningProcesses = Get-Process | Where-Object { $_.ProcessName -like "DayZServer_x64*" }
						$existingProcess = $runningProcesses | Where-Object { $_.MainWindowTitle -notlike "*port*" }
						if($existingProcess)
                        {
                            Stop-Process $($existingProcess.Id)
                        }
						$waitcount = 0
						break
					}
				}                
            }
        }
        else
        { 
            $existingProcess = $runningProcesses | Where-Object { $_.MainWindowTitle -like "*$serverPort*" }
            if ($existingProcess)
		   {
				$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
				"$serverName is down...$timestamp"
				Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""#shutdown"""
				# Clear the log file
				Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
                $temp = $myserverinfoarray | Where-Object {$_.port -eq $serverPort}
                #Stop-Process $($temp.Msginfo)
                #Stop-Process $($temp.adminfo)
                #Stop-Process $($temp.restartinfo)
				try
				{
				# Read the PID from the file
				$pidFilePath = "$MainFolder\$($RconPort)RestartPID.txt"
				$pid1 = Get-Content $pidFilePath
				# Stop the process with the PID
				kill $pid1
				}
				catch {"pid1 Cant kill it its not there"}
				try
				{
				# Read the PID from the file
				$pidFilePath = "$MainFolder\$($RconPort)ADMPID.txt"
				$pid2 = Get-Content $pidFilePath
				# Stop the process with the PID 
				kill $pid2
				}
				catch {"pid2 Cant kill it its not there"}
				try
				{
				# Read the PID from the file
				$pidFilePath = "$MainFolder\$($RconPort)MSGPID.txt"
				$pid3 = Get-Content $pidFilePath
				# Stop the process with the PID
				kill $pid3
				}
				catch {"pid3 Cant kill it its not there"}
				try
				{
				# Read the PID from the file
				$pidFilePath = "$MainFolder\$($RconPort)JokePID.txt"
				$pid4 = Get-Content $pidFilePath
				# Stop the process with the PID
				kill $pid4
				}
				catch {"pid4 Cant kill it its not there"}
                "$serverName is down...$timestamp"
				Start-Sleep -Seconds 15
				
            }
        }
    }
    Start-Sleep -Seconds 15
    #############################################################
    #puse list for copy lockFile
    $lockFile = "$MainFolder\copying.lock"
    while (Test-Path $lockFile) {
        Write-Host "Mod copying job is in progress. Pausing..."
        Start-Sleep -Seconds 10  # Sleep for 10 seconds before checking again
    }
}
