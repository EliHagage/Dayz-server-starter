<#
param(
	[Parameter(Position=0)]
	[string[]]$msg,

	[Parameter(Position=1)]
	[string[]]$modname,
	
	[Parameter(Position=2)]
	[int]$counter,

	[Parameter(Position=3)]
	[string[]]$hostname,

	[Parameter(Position=4)]
	[int[]]$rconport,

	[Parameter(Position=5)]
	[string[]]$rconpassword,

	[Parameter(Position=6)]
	[string[]]$modID,

	[Parameter(Position=7)]
	[string]$scriptfolder,
	
	[Parameter(Position=8)]
	[string[]]$serverPort
)
#>

# Determine the main script folder based on the current script location
# Define the base folder for the script
$MainFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
if ($MainFolder -like "*\servercontrol\public\settings\") {
    $MainFolder = Split-Path -Parent (Split-Path -Parent $MainFolder)
}
# Read the JSON configuration file
$configFilePath = "$MainFolder\Rwrappr_Config.json"
$config = Get-Content $configFilePath | ConvertFrom-Json
$msg = $config.msg
$modname = $config.modname
$counter = $config.counter
$hostname = $config.hostname
$rconport = $config.rconport
$rconpassword = $config.rconpassword
$modID = $config.modID
$MainFolder = $config.MainFolder
$serverPort = $config.serverPort
$msg
$modname
$counter
$hostname
$rconport
$rconpassword
$modID
$MainFolder
$serverPort
$settingsFilePath = Join-Path $MainFolder -ChildPath "settings.json"
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
$theselines = Get-Content "$($MainFolder)\settings.json"
$cmd_string = ""
$GAME_ID = $ScriptConfig1.SteamGameID
$BatchSize = $ScriptConfig1.ModCount
$Steam_User_Name = $ScriptConfig1.Steam_User_Name
$SteamPassword = $ScriptConfig1.SteamPassword
$Rcon = $ScriptConfig1.Rcon

$briadded = @()
$newhostname =@()
$newrconportlist =@()
$briadded +=$msg
$briadded +=$Specialmodname
$briadded +=$counter
$briadded +=$hostname
$briadded +=$rconport
$briadded +=$rconpassword

$lockFile = "$($MainFolder)\Rwrappr.lock"
New-Item -Path $lockFile -ItemType File -Force

$configFilePath = "$($MainFolder)\Rwrappr_Config.json"
Set-Content $configFilePath -Value ""

foreach ($s in $serverPort)
{
	$runningProcesses = Get-Process | Where-Object { $_.ProcessName -like "DayZServer_x64*" } |Select-Object {$_.MainWindowTitle}
}
# DayZ Console version (64bit)1.23.156951 : port 2612
            foreach ($process in $runningProcesses) {
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
#                            $newserverPortlist += $Matches[1]
                        }
                        $sharkycount++
                    }
                    

 				}
            }
#           $serverPort = $newserverPortlist
            $hostname = $newhostname
			$rconport = $newrconportlist
			
				$cnt = $counter; #3min
				
				$mycount = 0
				$cnt = $cnt - 40 #100
				foreach ($pp in $rconport)
				{	
				
					$rcon_command = "$($MainFolder)\ASRCon.ps1 ""$($hostname[$mycount])"" $pp ""$rconpassword"" ""say -1 [UPDATE MOD] - $($msg[$mycount]) - Restart In: 2min"""
					Invoke-Expression $rcon_command # $pp "$rconpassword" "say -1 [UPDATE MOD] - $($modname[$mycount]) - Restart In: 3min"
					$mycount++
					$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
					# Clear the log file
					Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
				}
				Start-Sleep -Seconds 40
				$cnt = 40
				while($cnt -gt 0)
				{
					$mycount = 0
					foreach ($pp in $rconport)
					{	
						$rcon_command = "$($MainFolder)\ASRCon.ps1 ""$($hostname[$mycount])"" $pp ""$rconpassword"" ""say -1 [UPDATE MOD] - $($msg[$mycount]) - Restart In: $cnt Seconds"""
						Invoke-Expression $rcon_command
						$cnt=$cnt-1
						$mycount++
						$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
						# Clear the log file
						Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
					}
					Start-Sleep -Seconds 1
				}
				
				$mycount = 0
				foreach ($pp in $rconport)
				{
					# lock server
					$rcon_command = "$($MainFolder)\ASRCon.ps1 ""$($hostname[$mycount])"" $pp  ""$rconpassword"" ""#lock"""
					Invoke-Expression $rcon_command
					$mycount++
					$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
					# Clear the log file
					Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
				}
				
				$mycount = 0
				
				foreach ($pp in $rconport)
				{
					# kick players
					$rcon_command = "$($MainFolder)\ASRCon.ps1 ""$($hostname[$mycount])"" $pp ""$rconpassword"" ""#kick -1"""
					Invoke-Expression $rcon_command
					$mycount++
					$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
					# Clear the log file
					Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
				
				}
					# last 60 Sec to save data beffor shutdown server
				$cnt =20
				while($cnt -gt 0)
				{
					$mycount = 0
					foreach ($pp in $rconport)
					{
						$rcon_command = "$($MainFolder)\ASRCon.ps1 ""$($hostname[$mycount])"" $pp ""$rconpassword"" ""say -1 [UPDATE MOD] - $($msg[$mycount]) - Restart In: $cnt"""
						Invoke-Expression $rcon_command
						$cnt=$cnt-1
						$mycount++
						$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
						# Clear the log file
						Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
					}
				}
				
				$mycount = 0
				foreach ($pp in $rconport)
				{
					Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$($hostname[$mycount])"" $pp ""$rconpassword"" ""#shutdown"""
					$mycount++
					$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
					# Clear the log file
					Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
				}
		sleep -Seconds 7
	$configFilePath = "$MainFolder\Rwrappr_Config.json"
	Set-Content $configFilePath -Value ""
if($modID.Count -gt 1)
{
	$modcount=0
	foreach ($meme in $modID)
	{
			rm "$($MainFolder)\$($DayzFolder)\@$($modname[$modcount])" -recurse -force
			md "$($MainFolder)\$($DayzFolder)\@$($modname[$modcount])"     # was modname
			$from = $($meme)
			$to = $($modname[$modcount]).trim(" ")    #was modname
			$from
			$to
			copy "$($MainFolder)\$($SteamCmdMods)\$from\*" "$($MainFolder)\$($DayzFolder)\@$to" -recurse -Force
			copy "$($MainFolder)\$($SteamCmdMods)\$from\*.*" "$($MainFolder)\$($DayzFolder)\@$to" -recurse -Force
			$modcount++
	}
	$configFilePath = "$MainFolderRestart_Config.json"
	Set-Content $configFilePath -Value ""

}
	$lockFile = "$MainFolder\Rwrappr.lock"
	Remove-Item -Path $lockFile -Force