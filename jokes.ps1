$JokePID = $PID
# Determine the main script folder based on the current script location
$MainFolder = Split-Path -Parent $MyInvocation.MyCommand.Path

# If the script is run from the website, adjust the main folder accordingly
if ($MainFolder -like "*\servercontrol\public\settings\") {
    $MainFolder = Split-Path -Parent (Split-Path -Parent $MainFolder)
}
$settingsFilePath = "$($MainFolder)\settings.json"
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$alljoke=@()
$insidejoke = $false
$userData = Get-Content "$($MainFolder)\Jokeinfo.txt"
$linecount=0
while($linecount -lt $userData.length-1)
{
	if($userData[$linecount] -match "----------")	# 10 dashes  - start of data packet
	{
		$linecount++
		$matches.Clear()
		while($userData[$linecount] -notmatch "----------")
		{
			if($userData[$linecount] -match "ServerIP=""(.+)""")   #ServerIP="192.168.0.1"
			{
				$serverIP = $matches[1]
				$matches.Clear()
				$linecount++
				if($userData[$linecount] -match "rconPort=""(.+)""")   #rconPort="2263"
				{
					$rconPort = $matches[1]
					$matches.Clear()
					$linecount++
					if($userData[$linecount] -match "rconPassword=""(.+)""")   #rconPassword="kfd9834k"
					{
						$rconPassword = $matches[1]
						$matches.Clear()
						$linecount++

						if($userData[$linecount] -match "serverName=""(.+)""")   #serverName="flaksville"
						{
							$serverName = $matches[1]
							$matches.Clear()
							$linecount++
							
							if($userData[$linecount] -match "playerID=""(.+)""")   #PlayerID="QWRDFSFAF="
							{
								$playerID = $matches[1]
								$matches.Clear()
								$linecount++
							
								if($userData[$linecount] -match "MainFolder=""(.+)""")   #ScriptFolder="QWRDFSFAF="
								{
									$MainFolder = $matches[1]
									$matches.Clear()
									$linecount++
								}
								"serverIP = $serverIP" 
								"rconPort = $rconPort"
								"rconPassword = $rconPassword"
								"serverName = $serverName"
								"playerID = $playerID"
								"MainFolder = $MainFolder"
							}
						}
					}
				}
			}
		}
	}
}
Set-Content "$($MainFolder)\$($RconPort)JokePID.txt" -Value $JokePID
$jokearray = Get-Content "$($MainFolder)\jokes.txt"
class joke {
    [int] $jokenumber
    [string[]] $linesofjoke
}
# Load existing jokes
foreach ($line in $jokearray) {
    if ($line -eq "Done") {
        "found Done"
        "completed joke $($thisjoke.jokenumber)"
        $alljoke += $thisjoke
        $insidejoke = $false
    }
    $thisline = $line.Where{$_ -match "^(\d*)$"}
    if ($Matches.Count -gt 1) {
        if($insidejoke) {
            $alljoke += $thisjoke
            $insidejoke = $false
        }
        $thisjoke = [joke]::new()
        $thisjoke.jokenumber = $Matches[1]
        $Matches.Clear()
        $insidejoke = $true
    }
    $thisline = $line.Where{$_ -match "^\s{1}""(.*)""\s*$"}
    if ($Matches.Count -gt 1) {
        $thisjoke.linesofjoke += $Matches[1]
        $Matches.Clear()
    }
}
$numarray = @(1..20)
                        if($numarray.Count -eq 0)
                        {
                                $numarray = @(1..20) # Create an array from 1 to 20 change 20 to add more jokes!!!!
                        }
                        # Continuous loop
                        $numarray
            $jokenum = $numarray | Get-Random # Select a random joke number from 1 to 20
                        sleep -Seconds 2
                        $nowjoke = $alljoke.Where{ $_.jokenumber -eq $jokenum }
                foreach ($line in $nowjoke.linesofjoke)
                                {
                    Write-Output "$line"
                                        $zz = Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""say $playerID $line"""
										$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
										# Clear the log file
										Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
										Start-Sleep -Seconds 8
                }
            $jokescounter = 0
            $numarray = $numarray | Where-Object {$_ -ne $jokenum}
Set-Content "$MainFolder\jokeinfo.txt" -Value ""
