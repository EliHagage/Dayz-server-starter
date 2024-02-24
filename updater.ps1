# Updater.ps1

# Read the JSON configuration file
# Determine the main script folder based on the current script location
# Define the base folder for the script
$Mainfolder = Split-Path -Parent $MyInvocation.MyCommand.Path

# Read the JSON configuration file
$settingsFilePath = Join-Path -Path $MainFolder -ChildPath "\settings.json"
$theselines = Get-Content "$MainFolder\settings.json"
$jsonsettingsContent = Get-Content -Path $settingsFilePath  | ConvertFrom-Json
$Mod_Info = $jsonsettingsContent.ModInfo
$ServerConfigs = $jsonsettingsContent.ServerConfigurations 
$ScriptConfig1 = $jsonsettingsContent.ScriptConfig

# Define constants and variables
$SteamCmdRoot = $ScriptConfig1.SteamCmdRoot
$ScriptFolder = $ScriptConfig1.ScriptFolder
$Steamlog = $ScriptConfig1.Steamlog
$SteamAPPFolder = $ScriptConfig1.SteamAPPFolder
$SteamCmdMods = $ScriptConfig1.SteamCmdMods
$DayzFolder = $ScriptConfig1.DayzFolder
$logFilePath = "$($MainFolder)\$($Steamlog)\workshop_log.txt"

$cmd_string = ""
$GAME_ID = $ScriptConfig1.SteamGameID
$BatchSize = $ScriptConfig1.ModCount
$Steam_User_Name = $ScriptConfig1.Steam_User_Name
$SteamPassword = $ScriptConfig1.SteamPassword
$Rcon = $ScriptConfig1.Rcon
$DiscordUrl = $ScriptConfig1.DiscordUrl
$alldone = $false
$num = 0
$current_mod = 0
$first_entry = $false
$lockFile = "$($MainFolder)\copying.lock"

$newrconportlist = @()
$newhostname = @() 
# Loop through each server configuration in the serverConfigs array
foreach ($serverConfig in $configFile.serverConfigs) {
    $startServer = $serverConfig.Startserver
    $serverName = $serverConfig.Name
    $serverPort = $serverConfig.serverPort
    $serverMap = $serverConfig.Mapfolder
    $serverIP = $serverConfig.serverIP
    $rconserverPort = $serverConfig.rconserverPort
    $rconPassword = $serverConfig.rconPassword
    $Serverrestart = $serverConfig.Serverrestart
}

foreach ($modEntry in $Mod_Info) {
    $modName = $modEntry.Mod_Name
	$modSteamWorkshopID = $modEntry.Mod_ID
    # Do whatever you need to do with each mod (e.g., update or install)
#    Write-Host "Mod Name: $modName"
#    Write-Host "Steam Workshop ID: $modSteamWorkshopID"
    # Add your mod update/install logic here
}


# Define a function to display a status message
function ShowStatus($message) {
    Write-Host "Status: $message"
}

function CheckModFoldersExist 
{
	$lockFile = "$MainFolder\copying.lock"
	New-Item $lockFile -ItemType File -Force
    foreach ($modInfo in $Mod_Info) {
		$modInfo
        $modName = $modInfo.Mod_Name
        $modId = $modInfo.Mod_ID
        $modFolderPath = Join-Path $MainFolder\$($DayzFolder) -ChildPath "@$modName"
        $modSourcePath = Join-Path $MainFolder\$($SteamCmdMods) -ChildPath $modId
        $destinationModFolder = "$modFolderPath"

        if (!(Test-Path -Path $destinationModFolder -PathType Container)) {
            ShowStatus "Mod folder for $modName not exist. Creating it..."
            cp $($modSourcePath) $destinationModFolder -Recurse -Force
            cp "$modSourcePath\Key*\*.*" "$MainFolder\$DayzFolder\Keys\"
        }
    }
		ShowStatus "Completed Step 5"
}
	
# Function to check if all mod folders exist, create them if missing, and copy mod files
# Define custom classes
class UpdateStructure {
    [string]$mod_name
    [string]$mod_id
    [string[]]$servers
}

class MapMods {
    [string]$map
    [string[]]$mods
    [string]$serverPort
    [string]$Startserver
    [string]$serverIP
    [string]$rconserverPort
    [string]$Serverrestart
    [string]$rconPassword
}

function DoAppUpdate($all_maps)
{
    $lockFile = "$MainFolder\copying.lock"
    New-Item $lockFile -ItemType File -Force

    if (-not(Test-Path "$MainFolder\$DayzFolder\DayZServer_x64.exe")) {
        # Copy the contents from another directory
        Copy-Item "$MainFolder\$SteamAPPFolder\*" -Destination "$MainFolder\$DayzFolder\" -Recurse -Force
        return
		# Jump to the end of the function
    }
	
#    foreach ($s in $serverPort)
 #   {
        $runningProcesses = Get-Process | Where-Object { $_.ProcessName -like "DayZServer_x64*" } | Select-Object {$_.MainWindowTitle}
 #   }
    # Check if DayZServer_x64.exe exists

    foreach ($process in $runningProcesses)
    {
        $thisprocess = $process | Where-Object { $_ -Match ".+: port (\d+)"}
        $sharkycount = 0
        if($thisprocess)
        {
            foreach($sharyserver in $serverPort)
            {
                if($sharyserver -eq $($Matches[1]))
                {
                    $newrconportlist += $rconport[$sharkycount]
                    $newhostname += $hostname[$sharkycount] 
                }
                $sharkycount++
            }
        }
    }
    $hostname = $newhostname
    $rconport = $newrconportlist

    foreach ($thismap in $all_maps)
    {
        "Start = $($map.Startserver)"
        if($($thismap.Startserver))
        {
            $cnt = $counter; #3min
            $cnt = 2 #$cnt -1 #100
                                        
            Invoke-Expression "$MainFolder\ASRCon.ps1  ""$($thismap.serverIP)"" $($thismap.rconserverPort) ""$($thismap.rconPassword)"" ""say -1 Server Dayz Update Not mod Restart In: $cnt min"""
            $cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
            # Clear the log file
            Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
        }
    }

    Start-Sleep -Seconds 60

    $cnt = 60 #$cnt -60 #60
    while($cnt -gt 0)
    {
        foreach ($thismap in $all_maps)
        {
            if($($thismap.Startserver))
            {
                Invoke-Expression "$MainFolder\ASRCon.ps1  ""$($thismap.serverIP)"" $($thismap.rconserverPort) ""$($thismap.rconPassword)"" ""say -1 Server Dayz Update Not mod Restart In: $cnt Seconds"""
                $cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
                # Clear the log file
                Clear-Content -Path "$MainFolder\servercontrol\public\settings\log.txt"
            }
        }
        Start-Sleep -Seconds 1
        $cnt-=1
    }
    Start-Sleep -Seconds 1
    "start job Update Dayz Server"
    foreach ($thismap in $all_maps)
    {
        if($($thismap.Startserver))
        {
            "shutting down $($thismap.map) at rconserverPort $($thismap.rconserverPort)"
            Invoke-Expression "$($MainFolder)\ASRCon.ps1  ""$($thismap.serverIP)"" $($thismap.rconserverPort) ""$($thismap.rconPassword)"" ""#shutdown"""
            $cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
            # Clear the log file
            Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
        }
    }
        Start-Sleep -Seconds 7

    "removing files"
    rd "$($MainFolder)\$($DayzFolder)\addons" -recurse -force
    rd "$($MainFolder)\$($DayzFolder)\battleye" -recurse -force
    rd "$($MainFolder)\$($DayzFolder)\bliss" -recurse -force
    rd "$($MainFolder)\$($DayzFolder)\docs" -recurse -force
    rd "$($MainFolder)\$($DayzFolder)\dta" -recurse -force
    "copying Files"
    cp "$($MainFolder)\$($SteamAPPFolder)\addons" "$($MainFolder)\$DayzFolder\" -recurse -force 
    cp "$($MainFolder)\$($SteamAPPFolder)\battleye" "$($MainFolder)\$DayzFolder\" -recurse -force
    cp "$($MainFolder)\$($SteamAPPFolder)\bliss" "$($MainFolder)\$DayzFolder\" -recurse -force
    cp "$($MainFolder)\$($SteamAPPFolder)\docs" "$($MainFolder)\$DayzFolder\" -recurse -force
    cp "$($MainFolder)\$($SteamAPPFolder)\dta" "$($MainFolder)\$DayzFolder\" -recurse -force
    cp "$($MainFolder)\$($SteamAPPFolder)\keys\*.*" "$($MainFolder)\$($DayzFolder)\Keys\" -recurse -force
    cp "$($MainFolder)\$($SteamAPPFolder)\dayz.gproj" "$($MainFolder)\$DayzFolder\" -force
    cp "$($MainFolder)\$($SteamAPPFolder)\DayZServer_x64.exe" "$($MainFolder)\$DayzFolder\" -force 
    cp "$($MainFolder)\$($SteamAPPFolder)\steam_api64.dll" "$($MainFolder)\$DayzFolder\" -force
    cp "$($MainFolder)\$($SteamAPPFolder)\steamclient64.dll" "$($MainFolder)\$DayzFolder\" -force
    cp "$($MainFolder)\$($SteamAPPFolder)\tier0_s64.dll" "$($MainFolder)\$DayzFolder\" -force
    cp "$($MainFolder)\$($SteamAPPFolder)\vstdlib_s64.dll" "$($MainFolder)\$DayzFolder\" -force
    Set-Content -Path "$($MainFolder)\$($Steamlog)\content_log.txt" -Value ""
    "Done copying Dayz Job"


    function EndOfFunction {
        ShowStatus "Done Update Dayz Job done"
    }
}

function detect_App_update($all_maps)
{
        $Matches.Clear()	
		$updaterLog =Get-Content "$($MainFolder)\$($Steamlog)\content_log.txt"
	    foreach ($logline in $updaterLog) {
        $throwaway = $logline | Where-Object {$_ -Match "AppID 223350 starting commit" }
        
		if ($Matches.Count -gt 0) {
            $Mod_to_Update = $Matches[1]
            $Matches.Clear()
			"update occured to DayZ Server"
			DoAppUpdate $all_maps
			$Matches.Clear()
		}
	}
}

function BaseModUpdate {
    $all_mods = @()
    while ($num -lt $BatchSize -and $current_mod -lt $Mod_Info.Count) {
        $mod = $Mod_Info[$current_mod]
        $thismod = [UpdateStructure]::new()
        $thismod.mod_name = $mod.Mod_Name
        $thismod.mod_id = $mod.Mod_ID
        $all_mods += $thismod
        $cmd_string += " +workshop_download_item $GAME_ID $($thismod.mod_id)"
        $num += 1
        $current_mod += 1
    }
    # Execute SteamCMD command if there are mods to update
    if ($cmd_string -ne "") {
        Start-Process -NoNewWindow "$MainFolder\$SteamCmdRoot\steamcmd" -ArgumentList ('+login', "$Steam_User_Name $SteamPassword", $cmd_string, "+app_update 223350",'validate','+quit') -Wait
        $num = 0
        $cmd_string = "+login $Steam_User_Name $SteamPassword"
    }
	ShowStatus "Completed Step 1"
	CheckModFoldersExist
    FindMapMods $all_mods
}

function FindMapMods($all_mods)
{
    $all_maps = @()
    $inside = $false
    $currentMap = $null
    $serverPort = $null
    $rconserverPort = $null
    $rconPassword = $null
    $nextserver = ""

    foreach ($line in $theselines) {
        if ($inside -eq $false) {
								# Search for the Name
            $throwaway = $line | Where-Object { $_ -match """Name"":\s*""(.*)""" }
            if ($Matches.Count -gt 1) {
                $currentMap = [MapMods]::new()
                $currentMap.map = $Matches[1]

                if($nextserver -ne "")
                {
                    $currentMap.Startserver = $nextserver
                    $nextserver = ""
				}

                $inside = $true
                $Matches.Clear()
            }
        }
        #			"Startserver": true,
        $throwaway = $line | Where-Object { $_ -match "^\s*""Startserver"":\s*(.*)," }
        if ($Matches.Count -gt 1) {
            $nextserver = $Matches[1]
            $Matches.Clear()
        }


								# Search for the Mod
        if ($inside -eq $true) {
            $throwaway = $line | Where-Object { $_ -match "^\s*""-mod=(.*)""" }
            if ($Matches.Count -gt 1) {
                $modsplit = $Matches[1].split(";")

                foreach ($mod in $modsplit) {
                    $qq = $mod.Trim(" ")
                    if ($qq.length -gt 0) {
                        $currentMap.mods += $qq.trim("@")
                    }
                }
                $Matches.Clear()
            }
								# Search for the serverMod
            $throwaway = $line | Where-Object { $_ -match "^\s*""-ServerMod=(.*)""" }
            if ($Matches.Count -gt 1) {
                $modsplit = $Matches[1].split(";")

                foreach ($mod in $modsplit) {
                    $qq = $mod.Trim(" ")
                    if ($qq.length -gt 0) {
                        $currentMap.mods += $qq.trim('@')
                    }
                }
                $Matches.Clear()
            }
								# Search for the serverPort
            $throwaway = $line | Where-Object { $_ -match "^\s*""Port"":\s*""(\d+)""" }
            if ($Matches.Count -gt 1) {
                $currentMap.serverPort = $Matches[1] 
                $Matches.Clear() 
            }
								# Search for the rconserverPort
            $throwaway = $line | Where-Object { $_ -match "^\s*""rconport"":\s*""(\d+)""" }
            if ($Matches.Count -gt 1) {
                $currentMap.rconserverPort = $Matches[1]
                $Matches.Clear() 
            }
								# Search for the Serverrestart
            $throwaway = $line | Where-Object { $_ -match "^\s*""Server_restart"":\s*""(\d+)""" }
            if ($Matches.Count -gt 1) {
                $currentMap.Serverrestart = $Matches[1]
                $Matches.Clear() 
            }


            # Search for the Rcon password
            $throwaway = $line | Where-Object { $_ -match "^\s*""rconpassword"":\s*""(.*)"""}
            if ($Matches.Count -gt 1) {
                $currentMap.rconPassword = $Matches[1]
                $Matches.Clear() 
            }
            # Search for the 	serverIP = $($thismap.serverIP)
            $throwaway = $line | Where-Object { $_ -match "^\s*""Serverip"":\s*""(.*)"""}
            if ($Matches.Count -gt 1) {
                $currentMap.serverIP = $Matches[1]
                $Matches.Clear() 
            }
            $throwaway = $line | Where-Object { $_ -match "^\s*(])"}
            if ($Matches.Count -gt 1)
            {
				$inside = $false
                if($currentMap.Startserver -eq "true")
                {
                    $all_maps += $currentMap
                }
                $Matches.Clear() 
            }
        }
    }  #moved
	    ShowStatus "Completed Step 2"
	    detect_App_update $all_maps
	    ReadModList $all_maps
}

# Function to read mod list
function ReadModList($allmaps ) 
{
    $thismodlist = @()
    foreach ($m in $Mod_Info) {
        $bob = [UpdateStructure]::new()
        $bob.mod_name = $m.Mod_Name
        $bob.mod_id = $m.Mod_ID
        $thismodlist += $bob
    }
	ShowStatus "Completed Step 3"
    FindUpdatedMod $thismodlist $allmaps
}

# Function to find updated mods
function FindUpdatedMod([UpdateStructure[]]$all_mods, [MapMods[]]$all_maps) 
{
	$hostname=@()
	$serverPort=@()
	$rconserverPort=@()
    $foundmap = $false
    $idarray=@()
	$modlist1 = @()
    $modlist2 = @()
    $waitarray = @()
    $msg = @()
    $Mod_to_Update = ""
	$settingsFilePath = "$MainFolder"
    $updaterLog = Get-Content "$($MainFolder)\$($Steamlog)\workshop_log.txt"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFilePath -Value "Mod update check completed at $timestamp"
    foreach ($logline in $updaterLog) 
	{
        $throwaway = $logline | Where-Object { $_ -match "changed cached item (.*), new manifest" }
        if ($Matches.Count -gt 1) 
		{
			$idarray +=$Matches[1]
			$Matches.Clear()
		}
	}
	
     $lockFile = "$($MainFolder)\copying.lock"
     New-Item $lockFile -ItemType File -Force
	#"11111 $($Steamlog)workshop_log.txt $Script_folder"
	if($idarray.Count -gt 0)
	{
		foreach ($id in $idarray)
		{
			$Mod_to_Update = $id
			$Matches.Clear()
	
			$modupdated = $all_mods | Where-Object { $_.mod_id -eq $Mod_to_Update }
			if ($modupdated -ne $null) # Propose @() rather than null. cannot guarentee null without setting it
			{   
				foreach ($map in $all_maps)
				{
					if ($map.mods -contains $modupdated.mod_name)
					{
                        $foundmap = $true
						# Call the Rcon_wrapper.ps1 script
						$serverPort += $($map.serverPort)
						$hostname += $($map.serverIP)  
						$rconserverPort += $map.rconserverPort
						$map = $map.map
						$rconPassword = "$($all_maps.rconPassword)"
						$mod = $($modupdated.mod_name)
						$modlist1 += $($modupdated.mod_name)
						$modlist2 += $($modupdated.mod_id)
						$msg += "Server $map got an update for $($modupdated.mod_name) ($($modupdated.mod_id))"
						$discordMessage = "Server $map got an update for $($modupdated.mod_name) ($($modupdated.mod_id)).$timestamp .https://steamcommunity.com/sharedfiles/filedetails/?id=$($modupdated.mod_id)"
						SendDiscordMessage $discordMessage
						$counter = 160
						Stop-Job "$($map.map)*"
						Remove-Job "$($map.map)*"
					}	
				}
			}
		}
        if($foundmap)
        {
            # pause serverlist 1
						$configFilePath = "$($MainFolder)\Rwrappr_Config.json"
						$newConfig = @{
							msg = $msg
							modname = $modlist1
							counter = $counter
							hostname = $hostname
							rconport = $rconserverPort
							rconpassword = $rconPassword
							modID = $modlist2
							MainFolder = $MainFolder
							serverPort = $serverPort
						} | ConvertTo-Json
						
						$newConfig | Set-Content $configFilePath
						Start-Process -FilePath "powershell.exe"  -ArgumentList "-File", "$MainFolder\rcon_wrapper.ps1" -passthru
						Start-Sleep -Seconds 10
						$lockFile1 = "$($MainFolder)\Rwrappr.lock"
						while (Test-Path $lockFile1) 
						{
						Write-Host "Rwrappr Mod update copying job is in progress. Pausing..."
						Start-Sleep -Seconds 10  # Sleep for 5 seconds before checking again
						}
       	   # "Print me  $($MainFolder)\rcon_wrapper.ps1 -ArgumentList $msg, $modlist1, $counter, $hostname, $rconserverPort, $rconPassword, $modlist2, $ScriptFolder, $serverPort"
       	   # $jobinfo = Start-Job "$($MainFolder)\rcon_wrapper.ps1" -ArgumentList $msg, $modlist1, $counter, $hostname, $rconserverPort, $rconPassword, $modlist2, $ScriptFolder, $serverPort
       	    #Invoke-Expression "$($ScriptFolder)rcon_wrapper.ps1 ""$($msg[$mycounter])"" ""$m"" ""$counter"" ""$($hostname[$mycounter])"" $($rconserverPort[$mycounter]) ""$rconPassword"" ""$($modlist2[$mycounter])"" ""$ScriptFolder"""
       	    #Wait-Job $jobinfo
       	    #Stop-Job $jobinfo
       	    #Remove-Job $jobinfo
		    foreach ($myupdatedmod in $modlist1)
		    {
		        if(($($DayzFolder) -ne "") -and ($($myupdatedmod -ne "")))
		    	{
		    	    rd "$($MainFolder)\$($DayzFolder)\@$myupdatedmod" -Recurse -Force
		    	}
                "$($MainFolder)\$($DayzFolder)\@$myupdatedmod"
		    }
        }
	    $modlist1.Clear()
   	    $modlist2.Clear()
        $foundmap = $false
	    ShowStatus "Completed Step 4"
	    CheckModFoldersExist  # Check if all mod folders exist
    }
}
# Discord Integration
function SendDiscordMessage($message) 
{
    $WebhookUrl = $DiscordUrl
    $Payload = @{
        content = $message
    }
    $Headers = @{
        'Content-Type' = 'application/json'
    }
    $Body = $Payload | ConvertTo-Json
    Invoke-RestMethod -Uri $WebhookUrl -Method POST -Headers $Headers -Body $Body
	ShowStatus "Completed Step 6"
}

# Main script loop
while ($true) 
{
	$lockFile1 = "$($MainFolder)\ServerList.lock"
	while (Test-Path $lockFile1) {
	Write-Host "Server list Mod copying job is in progress. Pausing..."
	Start-Sleep -Seconds 20  # Sleep for 10 seconds before checking again
	}
		BaseModUpdate
		Set-Content -Path "$($MainFolder)\$($Steamlog)\workshop_log.txt" -Value ""
		$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
		Add-Content -Path $logFilePath -Value "Iteration completed at $timestamp"
		$lockFile = "$($MainFolder)\copying.lock"
		Remove-Item $lockFile -Force
		$remainingTime = 900
		ShowStatus "Script is still running Seconds $remainingTime $timestamp"
		# Reduce the remaining time in subsequent iterations
		for ($i = 840; $i -ge 60; $i -= 60) 
		{
			foreach ($server in $servers) 
			{
				$address = $server.Address
				$serverPort = $server.serverPort
				$command = $server.Command
			}
			$remainingTime -= 60
			ShowStatus "Script is still running Seconds $remainingTime $timestamp"
			Start-Sleep -Seconds 60
		}
}

