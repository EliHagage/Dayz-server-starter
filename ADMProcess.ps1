$RestartmyPID = $PID
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
# Update Restart_Config.json with new parameters
# Determine the main script folder based on the current script location
$MainFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
# If the script is run from the website, adjust the main folder accordingly
if ($MainFolder -like "*\servercontrol\public\settings\") {
    $MainFolder = Split-Path -Parent (Split-Path -Parent $MainFolder)
}
$settingsFilePath = Join-Path -Path $MainFolder -ChildPath "settings.json"
# Read arguments from the configuration file
$configFilePath = "$MainFolder\ADM_Config.json"
$config = Get-Content $configFilePath | ConvertFrom-Json
# Ensure that the $timeToRestart is of type [int]
$timeToRestart = [int]$config.Serverrestart
$serverIP = $config.serverIP
$rconPort = $config.rconPort
$serverName = $config.serverName
$rconPassword = $config.rconPassword
$MainFolder = $config.ScriptFolder
$DayzFolder = $config.DayzFolder
$serverIP
$rconPort
$serverName
$rconPassword
$timeToRestart
$MainFolder
$DayzFolder
$configFilePath = "$($MainFolder)ADM_Config.json"
#Set-Content $configFilePath -Value ""
Set-Content "$($MainFolder)$($RconPort)ADMPID.txt" -Value $RestartmyPID
$myserver = @()
foreach ($me in $serverConfig)
{
	if($me.Name -eq $serverName)
	{
			$myserver = $me
	}
}
$startyear=0;
$startmonth=0;
$startday=0;
$starthour =0;
$startmin=0;
$Endtime = Get-Date
$killfeed = "$($DayzFolder)$($serverName)Pro\DayZServer_x64.ADM"
$playerlog = "$($DayzFolder)$($serverName)Pro\DayZServer_x64.ADM"
$global:killfeedlastline =0
$global:lastlineprocessed = 0    #the line we got to last time we processed
$global:KillfeedLinesToProcess=@()
$global:firstrun = $true
[Player[]]$global:allplayers=@()
$global:languages =@()
class Player
{
	[int]$Id = -2
    [string] $name
    [int]$messagecount
    [string]$receivelang="en"      # all languages of players on server
    [string]$sendlang="en"    # message from orig player
	[bool]$online =$false
	[int[]]$availableJokes=@(1..20)
}
function TranslateMessage($message,$sendlang)
{
    $global:languages.Clear()
    if($sendlang -eq "")
    {
        return
    }
	foreach ($transPlayer in $global:allplayers)
	{
		if($transPlayer.receivelang -ne $sendlang)
		{
            $reclang = $transPlayer.receivelang
			$global:languages +=$transPlayer.receivelang
        	Invoke-WebRequest -Uri "https://translate.google.com/translate_a/single?client=gtx&sl=$sendlang&tl=$reclang&dt=t&q=$message" -OutFile "$($MainFolder)bri.txt"
			$gg = Get-Content "$($MainFolder)bri.txt"
        	$gg | Where-Object {$_ -match "^\[\[\[""(.*?)"","}
        	$Matches[1]
			$TransID = $transPlayer.Id
            $rcon_command = "$($MainFolder)\ASRCon.ps1 ""$($serverIP)"" $rconPort ""$rconPassword"" ""Say $TransID $($Matches[1])"""
			Invoke-Expression $rcon_command
			# Clear the log file
			Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
			$Matches.Clear()
		}
	}
}
function GetSendLanguage($sender,$message)
{
    $sendlang=""
    foreach ($sendplayer in $global:allplayers)
    {
        if($sendplayer.name -eq $sender)
        {
            $sendplayer.sendlang
            $sendlang = $sendplayer.sendlang
        }
    }
    TranslateMessage "$message" "$sendlang"
}
function CheckPlayerStructure($sender,$message)
{
	$NotSetUpPlayers = @()
	if($($global:allplayers.name) -notcontains $sender)
	{
		$thisplayer = [player]::new()
		$thisplayer.name = $sender
		$global:allplayers +=$thisplayer
	}
	$NotSetUpPlayers = $global:allplayers | Where-Object {$_.Id -eq -2 }
	if($NotSetUpPlayers.Count -gt 0)
	{
	Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""players"""
	$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
	# Clear the log file
    Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
		foreach ($NSUP in $NotSetUpPlayers)
		{		
			for($bb=12;$bb -lt $($cc.Count-1);$bb++)
			{
				$messageplayer=$cc[$bb] | Where-Object {$_ -match "^(\d+)\s+.*\s+\d+\s+(.*)\(OK\)\s+(.*)"}
				$playerID =$Matches[1]
				$NameofPlayer =$Matches[3]
				if($NameofPlayer -match "$($NSUP.name)")
				{
					$NSUP.Id = $PlayerID
				}
			}
		}
	}
	GetSendLanguage "$sender" "$message"
}
function GetPlayers()
{
	class PlayerInfo
	{
		[string] $name
		[string] $id
	}
	[PlayerInfo[]] $allsendplayers = @()
	Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""players"""
	$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
	# Clear the log file
    Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
	for($bb=12;$bb -lt $($cc.Count-1);$bb++)
	{
		$messageplayer=$cc[$bb] | Where-Object {$_ -match "^(\d+)\s+.*\s+\d+\s+(.*)\(OK\)\s+(.*)"}
		$playerID =$Matches[1]
		$NameofPlayer =$Matches[3]
		$thisplayer = [PlayerInfo]::new()
		$thisplayer.name = $NameofPlayer
		$thisplayer.id = $playerID
		$allsendplayers += $thisplayer
		
		if ($NameofPlayer -eq $requestname) 
		{
			$important = $playerID
		}
	}
	foreach ($qqbbpp in $allsendplayers)
	{
		$saymsg = "$($qqbbpp.name) $($qqbbpp.id)"
		Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""say $important $saymsg"""
		# Clear the log file
		Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
	}
}
function ProcessLine($line)
{
	if ($line -match 'Player "(.+)" is connected') 
	{
		$currentplayer21 = [Player]::new()
        $currentplayer21.name = $Matches[1]
		$global:allplayers += $currentplayer21
		$playerName = $Matches[1]
		Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""Say -1 $playerName has logged in."""
		# Clear the log file
		Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
		$Matches.Clear()
	} 
	elseif ($line -match 'Player "(.+)"\(id=(.+)\) has been disconnected') 
	{
		$playerName = $Matches[1]
		$playerId = $Matches[2]
		$global:allplayers = $global:allplayers | Where-Object {$_.name -ne $playerName}
		Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""Say -1 $playerName has logged out."""
		# Clear the log file
		Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
		$Matches.Clear()
	}
			if($line | Where-Object {$_ -Match "Player ""(.*)"".*\|.*?Player ""(.*)"""})
			{}
			else
			{
				if($serverName.Contains("PVE"))
				{
					$message = ($line | Where-Object {$_ -Match "Player ""(.*)"".*Player ""(.*)"""}) #.*hit by Player ""(.*)"" into (.*)\("})
					if($message -and $Matches.Count -gt 1)
					{
						$matchname = $Matches[1]
						$perp = $Matches[2]
						$location = $Matches[3].split(' ').split('(')
	
						$message12 = "$matchname hit by $perp"
						if($currentplayer.messagecount -lt 3)
						{
							Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""Say -1 $message12"""
							Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""Say -1 $WARNING $perp This is a PVE server Only."""
							# Clear the log file
							Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
						}
					}
				}
			}
			if($serverName.Contains("PVE"))
			{
				$message = ($line | Where-Object {$_ -Match "Player ""(.*)"".*hit by (\b.*\b) into (\b.*\b)"})
				if($message -and $Matches.Count -gt 2)
				{
					$matchname = $Matches[1]
					$perp = $Matches[2]
					$location = $Matches[3].split(' ').split('(')
					$message12 = "$matchname hit by $perp into $($location[0])"
					$currentplayer = $global:allplayers | Where-Object {$_.name -eq $matchname}
					if($currentplayer -eq $null)
					{
						$currentplayer2 = [Player]::new()
						$currentplayer2.name = $matchname
						$currentplayer2.messagecount++
						$global:allplayers += $currentplayer2
					}
					else
					{
						$currentplayer.messagecount++
					}
					$Matches.Clear()
					if($currentplayer.messagecount -lt 3)
					{
						Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""Say -1 $message12"""
						# Clear the log file
						Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
					}
				}
			}
        $playerrequest = $line | Where-Object {$_ -Match "Chat\(""(.*)""\(id=(.*)\)\): (.*)"}
        if($playerrequest)
        {
			$requestname = $Matches[1]
			$conversationID = $Matches[2]
            $playerconversation =$Matches[3]
			if($playerconversation -match ('^!Restart (.*)'))
			{
				$adminlist = Get-Content "$($MainFolder)adminList.txt"
				$adminlist
				if($adminlist -Contains $conversationID)
				{
					$timeToRestart = $Matches[1]
					if($timeToRestart)
					{
						$RestartmyPID = Get-Content "$($MainFolder)$($RconPort)RestartPID.txt"
						kill $RestartmyPID
						$configFilePath = "$($MainFolder)Restart_Config.json"
						$newConfig = @{
							timeToRestart = $timeToRestart
							serverIP = $serverIP
							rconPort = $rconPort
							serverName = $serverName
							rconPassword = $rconPassword
							ScriptFolder = $MainFolder
						} | ConvertTo-Json
						
						$newConfig | Set-Content $configFilePath
						$zzqqww = Start-Process -FilePath "powershell.exe" -ArgumentList "-File", "$MainFolder\restartserver.ps1" -passthru
					}
				}
				$Matches.Clear()
			}
			if($playerconversation -match ('^!StopRestart'))
			{
				$adminlist = Get-Content "$($MainFolder)adminList.txt"
				if($adminlist -Contains $conversationID)
				{
					$v = ps $zzqqww.Id
					if($v)
					{
						kill $v
					}
				}
				$Matches.Clear()
			}
            if($playerconversation -match ('^!lang=(.*)'))
            {
				foreach($convplayer in $global:allplayers)
                {
					if($convplayer.name -eq $requestname)
                    {
						$convplayer.sendlang = $Matches[1]
						$convplayer.receivelang = $Matches[1]
						$Matches.Clear()
                    }    
                }
				$Matches.Clear()
            }
			if($playerconversation -match ('^!players$'))
			{
				$adminlist = Get-Content "$($MainFolder)adminList.txt"
				if($adminlist -Contains $conversationID)
				{
					GetPlayers
				}
			}
			if($playerconversation -match ('^!warn (\d+)'))
			{
				$adminlist = Get-Content "$($MainFolder)adminList.txt"
				if($adminlist -Contains $conversationID)
				{
					Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""Say $($Matches[1]) WARNING -You have been caught violating server rules"""
					# Clear the log file
					Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
				}
				$Matches.Clear()				
			}
			if($playerconversation -match ('^!event (.+)$'))
			{
				$eventinfo = Get-Content "$($MainFolder)\$($serverName)Eventfile.txt"
				$searchinfo = $Matches[1]
				
				Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""players"""
				$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
				# Clear the log file
				Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
				for($bb=12;$bb -lt $($cc.Count-1);$bb++)
				{
					$messageplayer=$cc[$bb] | Where-Object {$_ -match "^(\d+)\s+.*\s+\d+\s+(.*)\(OK\)\s+(.*)"}
					$playerID =$Matches[1]
					$NameofPlayer =$Matches[3]

					if ($NameofPlayer -eq $requestname)
					{
						foreach ($eventline in $eventinfo)
						{
							if($eventline -match $searchinfo)
							{
								Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""Say $playerID $eventline"""
								$Matches.Clear()
							}
						}
						break
					}
				}
			}
			
            if($playerconversation -match ('^!sendlang=(.*)'))
            {
				foreach($convplayer in $global:allplayers)
                {
					if($convplayer.name -eq $requestname)
                    {
						$convplayer.sendlang = $Matches[1]
						$Matches.Clear()
                    }    
                }
				$Matches.Clear()
            }
			if($playerconversation -match ('^!receivelang=(.*)'))
            {
				foreach($convplayer in $global:allplayers)
                {
					if($convplayer.name -eq $requestname)
                    {
						$convplayer.receivelang = $Matches[1]
						$Matches.Clear()
                    }    
                }
				$Matches.Clear()
            }
			if($playerconversation -match ('^!joke$'))	
            {
				foreach($convplayer in $global:allplayers)
                {
					if($convplayer.name -eq $requestname)
                    {
						$convplayer.receivelang = $Matches[1]
						$Matches.Clear()
					    Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""players"""
						$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
						# Clear the log file
						Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
					    for ($bb = 12; $bb -lt $($cc.Count - 1); $bb++) 
					    {
						    $messageplayer = $cc[$bb] | Where-Object { $_ -match "^(\d+)\s+.*\s+\d+\s+(.*)\(OK\)\s+(.*)" }
						    $playerID = $Matches[1]
						    $NameofPlayer = $Matches[3]
						    if ($NameofPlayer -eq $requestname) 
						    {
								$jokeinfoarray = @()
								$jokeinfoarray += "----------"
								$jokeinfoarray += "ServerIP=""$ServerIP"""
								$jokeinfoarray += "rconPort=""$rconPort"""
								$jokeinfoarray += "rconPassword=""$rconPassword"""
								$jokeinfoarray += "serverName=""$serverName"""
								$jokeinfoarray += "playerID=""$playerID"""
								$jokeinfoarray += "MainFolder=""$MainFolder"""
								$jokeinfoarray += "----------"
								Set-Content "$MainFolder\jokeinfo.txt" -Value $jokeinfoarray
								$jokeinfoarray
						    	Start-Process -FilePath "powershell.exe" -ArgumentList "-File", "$MainFolder\jokes.ps1"
							}
						}
					}
				}	
			}
			if($playerconversation -match ('^? (.*)'))
            {
				CheckPlayerStructure $requestname $Matches[1]
                $Matches.Clear()
            }
			$messageMatches = Get-Content "$($MainFolder)messagematches.config" | ForEach-Object {      # must be at end next to foreach
				$parts = $_ -split ","
				[PSCustomObject]@{
					Pattern = $parts[0].Trim()
					Response = $parts[1].Trim()
				}
			}
            if ($playerconversation -match '^(![^ ]+)') 
			{
				$command = $Matches[1]
				$matchedPattern = $messageMatches | Where-Object { $command -eq $_.Pattern }
				if ($matchedPattern) 
				{
					Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""players"""
					$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
					# Clear the log file
					Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
					for ($bb = 12; $bb -lt $($cc.Count - 1); $bb++) 
					{
						$messageplayer = $cc[$bb] | Where-Object { $_ -match "^(\d+)\s+.*\s+\d+\s+(.*)\(OK\)\s+(.*)" }
						$playerID = $Matches[1]
						$NameofPlayer = $Matches[3]
						if ($NameofPlayer -eq $requestname) 
						{
							$responseMessage = $matchedPattern.Response
							Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""Say $playerID $responseMessage"""
							# Clear the log file
							Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
						}
					}
				}
			}
		}
	}
function Readfile()
{
$TotalKillFeed = Get-Content $killfeed
    if($global:firstrun)
    {
		$global:lastline = $TotalKillFeed.Count
        $global:killfeedlastline=$lastline
        $global:lastlineprocessed = $lastline
        $global:firstrun = $false 
    }
    else
    {
		$global:lastline = $TotalKillFeed.Count
        $global:killfeedlastline=$lastline
        if($global:KillfeedLinesToProcess.Count -gt 0)
        {
            $global:KillfeedLinesToProcess = @()
        }
        for($i=$global:lastlineprocessed;$i -lt $global:killfeedlastline;$i++)  #was lt
        {
			$global:KillfeedLinesToProcess +=$TotalKillFeed[$i]
        }
        $global:lastlineprocessed = $global:killfeedlastline
    }
	foreach($killLine in $global:KillfeedLinesToProcess)
	{
		Processline $killLine
	}
}
$loop_count=0
while(1)
{
	Readfile
	Start-Sleep -Seconds 5
	$loop_count++
	if($loop_count -ge 12)
	{
		$players_count = $global:allplayers | Where-Object {$_.messagecount -gt 0}
		foreach ($player_count in $players_count)
		{
			$player_count.messagecount =0
		}
		$loop_count=0
	}
}
