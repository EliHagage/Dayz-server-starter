$RestartmyPID = $PID
# Determine the main script folder based on the current script location
$MainFolder = Split-Path -Parent $MyInvocation.MyCommand.Path

# If the script is run from the website, adjust the main folder accordingly
if ($MainFolder -like "*\Script\") {
    $MainFolder = Split-Path -Parent (Split-Path -Parent $MainFolder)
}
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$MainFolder
$configFilePath = "$MainFolder\PVP_Event_config.json"
$config = Get-Content $configFilePath | ConvertFrom-Json
$timeToRestart = [int]$config.Serverrestart
$serverIP = $config.serverIP
$rconPort = $config.rconPort
$serverName = $config.serverName
$rconPassword = $config.rconPassword
$MainFolder = $config.ScriptFolder
$DayzFolder = $config.DayzFolder
Set-Content "$MainFolder\$($RconPort)ProcessEventPID.txt" -Value $RestartmyPID
#Set-Content "$($MainFolder)\$($serverName)Eventfile.txt"  -Value ""
$ServerConsoleFile = "$($MainFolder)\$($DayzFolder)\$($serverName)Pro\serverconsole.log"
$FutureXLogFile = "$($MainFolder)\$($DayzFolder)\$($serverName)Pro\@Futurexlog\Futurex.log"
$nameOfFile
$firstrunFuture = $true
$firstrunSever = $true
$lastline = 0
$ScriptContentlastline = 0
$lastlineprocessed = 0
$preventRepeat = $false
[System.Collections.ArrayList]$SharkyEventArray =@()
$posarray =@()

$posfile = Get-Content "$($MainFolder)\$($ServerName)POS.txt"

class posinfo
{
	[string] $name
	[float] $x
	[float] $z
}
	
class SharkyEvent
{
	[string] $name
    [string] $currentID 
	[string] $x
	[string] $z
	[string] $message
}

class Console
{
	[int]$lastline=0
	[int]$ScriptContentlastline
	[int]$lastlineprocessed
    [bool]$firstrun = $true
    [string[]]$ScriptContentLinesToProcess = @()
	[int]$oldlastline = 0

}

class Futurex
{
	[int]$lastline
	[int]$ScriptContentlastline
	[int]$lastlineprocessed
    [bool]$firstrun = $true
    [string[]]$ScriptContentLinesToProcess = @()
}


foreach ($posline in $posfile)
{
"line = $posline"
	$posline -match """name"": ""(.*)"","
	if($Matches.Count -gt 1)
	{
		$singlepos=[posinfo]::new()
		$singlepos.name = $Matches[1]
		$Matches.Clear()

	}
	$posline -match "`t`t`t`t(.*),"
	if($Matches.Count -gt 1)
	{
		$singlepos.x = $Matches[1]
		$Matches.Clear()
	}
	$posline -match "`t`t`t`t(\d*\.\d*)$"
	if($Matches.Count -gt 1)
	{
		$singlepos.z = $Matches[1]
		$Matches.Clear()
        $posarray += $singlepos		
	}

}



	$Future1 = [Futurex]::new()
	$Console1 = [Console]::new()



function ServerProcessLine($line)
{
	$valid = $true
	$newmessage ="222"
    $care = $false
    # Add events
	
    if($line -match '\[FuturexEvents\] \[\+\] Processing Event: (.*), Position: .+ \{<(.+),.+,(.+)>\}')
    {
		$eventname = $matches[1]
		$tempx = $matches[2]
		$tempz = $matches[3]

		if(($tempx -eq 0) -and ($tempz -eq 0))
		{
			$valid = $false
		}
		
		if($eventname -eq "Wreck_Mi8_Crashed")
		{
            $care =$true
		}
		if($eventname -eq "Wreck_UH1Y")
		{
            $care =$true
		}
		if($eventname -eq "ContaminatedArea_Dynamic")
		{
            $care =$true
		}
#[+] Processing Event: StaticObj_Wreck_Train_742_Red_DE, Position: 0x000000000dc04920 {<11254.2,8.55,3290.32>}
		if($eventname -match "StaticObj_Wreck_Train_742.*_DE")
		{
            $care =$true
#            $tempname= $Matches[1]
#            $tempx = $Matches[2]
#            $tempz = $Matches[3]
			$matches.Clear()
		}
#StaticObj_Misc_SupplyBox2_DE, Position: 0x000000000dc04920 {<4426.06,339.909,10242.8>}
		if($eventname -match "Land_Wreck_C130J_Cargo")
		{
            $care =$true
#           $tempname= $Matches[1]
#           $tempx = $Matches[2]
#           $tempz = $Matches[3]
			$matches.Clear()
		}
#Land_Wreck_sed01_aban1_police_DE, Position: 0x000000000dc04920 {<6582.4,283.796,7508.01>}
		if($eventname -match "Land_Wreck_sed01_aban._police_DE")
		{
            $care =$true
			$matches.Clear()

		}
		if($eventname -eq "Land_Wreck_V3S_DE")
		{
            $care =$true
		}	
		# '\[FuturexEvents\] \[+\] Processing Event: (.*), Position: .+ \{<(.+),.+,(.+)>\}'
if($care -and $valid)
{
        $posname="zzzzzz"
		$se = [SharkyEvent]::new()
        
        $se.name = $eventname # $matches[1]
#        if($se.name -eq "") {$se.name = $tempname}
        
        $se.x = $tempx  #$matches[2]
		#if($se.x -eq "") {$se.x = $tempx}
		

        $se.z = $tempz  #$matches[3]
	#	if($se.z -eq "") {$se.z = $tempz}

        $closest = 32000
        $se

        foreach ($pos1 in $posarray)
        {
            $posx = $pos1.x - $se.x    
            $posz = $pos1.z - $se.z

            if($posx -lt 0)
            {
                $posx = $posx * -1
            }
            if($posz -lt 0)
            {
                $posz = $posz * -1
            }
			"$($pos1.name) $posx $posz`n`n"

            $first = [math]::Pow($posx,2)
            $second = [math]::Pow($posz,2)

            $result1 = $first + $second

            $result = [math]::Sqrt($result1)

            if($result -lt $closest)
            {
                $closest = $result
                $closestx = $posx
                $closestz = $posz                
                "Closest location = $($pos1.name)"
                $posname = $pos1.name
                "$closestx  $closestz"
            }
        }
        "Closest (official) : $closestx $closestz $($posname)`n`n"

		if($eventname -eq "Wreck_Mi8_Crashed")
		{
			$newmessage = "Blackhawk down at $($se.x) $($se.z) ($posname)"
		}
		if($eventname -eq "Wreck_UH1Y")
		{
			$newmessage = "Blackhawk down at $($se.x) $($se.z) ($posname)"
		}
		if($eventname -eq "ContaminatedArea_Dynamic")
		{
			$newmessage = "Toxic Gas at $($se.x) $($se.z) ($posname)"
		}
		if($eventname -match "StaticObj_Wreck_Train_742")
		{
			$newmessage = "Train crash at $($se.x) $($se.z) ($posname)"
			$matches.Clear()
		}
		if($eventname -match "Land_Wreck_C130J_Cargo")
		{
			$newmessage = "Airplane convoy crash at $($se.x) $($se.z) ($posname)"
			$matches.Clear()
		}
		if($eventname -match "Land_Wreck_sed01_aban._police_DE")
		{
			$newmessage = "Police Roadblock at $($se.x) $($se.z) ($posname)"
			$matches.Clear()
		}
#		if($eventname -eq "Land_Wreck_sed01_aban2_police_DE")
#		{
#			$newmessage = "Police Roadblock at $($se.x) $($se.z) ($posname)"
#		}
		if($eventname -eq "Land_Wreck_V3S_DE")
		{
			$newmessage = "Military supply crash at $($se.x) $($se.z) ($posname)"
		}	
		# '\[FuturexEvents\] \[+\] Processing Event: (.*), Position: .+ \{<(.+),.+,(.+)>\}'





        $rcon_command = "$($MainFolder)\ASRCon.ps1 ""$($serverIP)"" $rconPort ""$rconPassword"" ""Say -1 $newmessage"""
		Invoke-Expression $rcon_command
			
        "Add Event $($se.name) $($se.x) $($se.z)"

        $se.message = $newmessage
		$SharkyEventArray.Add($se)
#		$global:SharkyEventArray.Add($se)

		$($SharkyEventArray.message) | Set-Content "$($MainFolder)\$($serverName)Eventfile.txt"
        Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
        }
    }			
        $matches.Clear()
}
	

function FutureProcessLine($line)
{
    #Processing Event: Land_Wreck_sed01_aban2_black_DE, Position: 0x00000000ba5b0660 {<6458.39,6.75332,2544.69>}
    #subtract
    if($line -match '\[FuturexEvents\] \[-\] Processing Event: (.*), Position: .+ \{<(.+),.+,(.+)>\}')
    {
        $thisname = $Matches[1]
        $thisx = $Matches[2]

        $thisz = $Matches[3]

#		Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""Say -1 Found something"""
#		Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
#		"Found something"
		$throwaway = $thisx -match "(\d+)\."
		$thatx = $Matches[1]
		"SharkEventX = $($SharkyEventArray.x)"
		"ThatX = $thatx"
		$Matches.Clear()
         if($($SharkyEventArray.x) -match $thatx)
         {
			$throwaway = $thisz -match "(\d+)\."
			$thatz = $Matches[1]
			"SharkEventZ = $($SharkyEventArray.z)"
			"Thatz = $thatz"

			$Matches.Clear() 
            if(($SharkyEventArray.z) -match $thatz)
            {
#  was           $thisevent = $SharkyEventArray | Where-Object {$_.x -match $thatx -and $_.z -match $thatz}
                $thisevent = $SharkyEventArray|Where-Object{($_.x -match $thatx) -and ($_.z -match $thatz)}
                foreach ($singleevent in $thisevent)
                {
                    Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""Say -1 Event expired - $($singleevent.message)"""
                }
	    	}
            Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
            $Matches.Clear()
			
            "delete  $thisx  $thisz"
			$llp =$SharkyEventArray|Where-Object{($_.x -match $thatx) -and ($_.z -match $thatz)}
            foreach ($zz in $llp)
            {
                $SharkyEventArray.Remove($zz)
            }
            $($SharkyEventArray.message)
			$($SharkyEventArray.message) | Set-Content "$($MainFolder)\$($serverName)Eventfile.txt"
#				Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
                $Matches.Clear()
			}
         }
<#
         if(($($SharkyEventArray.x) -Contains $thisx) -and
          ($($SharkyEventArray.z) -Contains $thisz))
        {
            "Deleting"
        }
#>
    }

function ProcessLine($line)
{
	if($playerconversation -match ('^? (.*)'))
          {
		CheckPlayerStructure $requestname $Matches[1]
              $Matches.Clear()
          }
	$messageMatches = Get-Content "$($MainFolder)\$($serverName)Eventfile.txt" | ForEach-Object {      # must be at end next to foreach
		$parts = $_ -split "line"
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

function AddStuff()   #Readserverconsole()
{
	$ScriptContent = Get-Content $FutureXLogFile
    if($Console1.firstrun)
    {
#		$Console1.lastline = $ScriptContent.Count
        $Console1.ScriptContentlastline=$Console1.lastline
        $Console1.lastlineprocessed = $Console1.lastline
        $Console1.firstrun = $false 
    }
    else
    {

		$Console1.lastline = $ScriptContent.Count
		#if($Console1.lastline -lt $Console1.oldlastline)
		#{
		#	"server reset"
		#	#Set-Content "Server"
		#	$global.SharkyEventArray=@()
		#}
		$Console1.oldlastline = $console1.lastline
		
        $Console1.ScriptContentlastline=$Console1.lastline
        if($Console1.ScriptContentLinesToProcess.Count -gt 0)
        {
            $Console1.ScriptContentLinesToProcess = @()
        }
        for($i=$Console1.lastlineprocessed;$i -lt $Console1.ScriptContentlastline;$i++)  #was lt
        {
			$Console1.ScriptContentLinesToProcess +=$ScriptContent[$i]
        }
        $Console1.lastlineprocessed = $Console1.ScriptContentlastline
    }
	foreach($ScriptLine in $Console1.ScriptContentLinesToProcess)
	{
		ServerProcessline $ScriptLine
	}
}


function RemoveStuff()   #Readfuturexlog()
{
	$ScriptContent = Get-Content $FutureXLogFile
    if($Future1.firstrun)
    {
#		$Future1.lastline = $ScriptContent.Count
        $Future1.ScriptContentlastline=$Future1.lastline
        $Future1.lastlineprocessed = $Future1.lastline
        $Future1.firstrun = $false 
    }
    else
    {
		$Future1.lastline = $ScriptContent.Count
        $Future1.ScriptContentlastline=$Future1.lastline
        if($Future1.ScriptContentLinesToProcess.Count -gt 0)
        {
            $Future1.ScriptContentLinesToProcess = @()
        }
        for($i=$Future1.lastlineprocessed;$i -lt $Future1.ScriptContentlastline;$i++)  #was lt
        {
			$Future1.ScriptContentLinesToProcess +=$ScriptContent[$i]
        }
        $Future1.lastlineprocessed = $Future1.ScriptContentlastline
    }
	foreach($ScriptLine in $Future1.ScriptContentLinesToProcess)
	{
		FutureProcessline $ScriptLine
	}
}

$loop_count=0
while(1)
{
    AddStuff

    RemoveStuff
	
#	Add-Content "$($MainFolder)\$($serverName)Eventfile.txt"  -Value $newmessage
#	"$($global:SharkyEventArray.message)" | Set-Content "$($MainFolder)\$($serverName)Eventfile.txt"
#	Readfuturexlog
	
#	Start-Sleep -Seconds 5
#	$loop_count++
}
