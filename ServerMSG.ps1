$MSGPID = $PID

$PSDefaultParameterValues['*:Encoding'] = 'utf8'
# Determine the main script folder based on the current script location
$MainFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
# If the script is run from the website, adjust the main folder accordingly
if ($MainFolder -like "*\servercontrol\public\settings\") {
    $MainFolder = Split-Path -Parent (Split-Path -Parent $MainFolder)
}
# Read arguments from the configuration file
$configFilePath = "$MainFolder\MSG_Config.json"
$config = Get-Content $configFilePath | ConvertFrom-Json

$serverIP = $config.serverIP
$rconPort = $config.rconPort
$serverName = $config.serverName
$rconPassword = $config.rconPassword
$MainFolder = $config.ScriptFolder
$allSerMSG =@()
$serverIP
$rconPort
$serverName
$rconPassword
$timeToRestart
$MainFolder
$DayzFolder

$SerMSGarray = Get-Content "$($MainFolder)ServerMSG.txt"
Set-Content "$($MainFolder)$($RconPort)MSGPID.txt" -Value $MSGPID
class SerMSG {
    [int] $SerMSGnumber
    [string[]] $linesofSerMSG
}

# Load existing SerMSGs
foreach ($line in $SerMSGarray) {
    if ($line -eq "Done") {
        "found Done"
        "completed SerMSG $($thisSerMSG.SerMSGnumber)"
        $allSerMSG += $thisSerMSG
        $insideSerMSG = $false
    }
    $thisline = $line.Where{$_ -match "^(\d*)$"}
    if ($Matches.Count -gt 1) {
        if($insideSerMSG) {
            $allSerMSG += $thisSerMSG
            $insideSerMSG = $false
        }
        $thisSerMSG = [SerMSG]::new()
        $thisSerMSG.SerMSGnumber = $Matches[1]
        $Matches.Clear()
        $insideSerMSG = $true
    }
    $thisline = $line.Where{$_ -match "^\s{1}""(.*)""\s*$"}
    if ($Matches.Count -gt 1) {
        $thisSerMSG.linesofSerMSG += $Matches[1]
        $Matches.Clear()
    }
}

$numarray = @(1..10)
while ($true)
	{
		$global:allplayers	
		if($numarray.Count -eq 0)
			{
				$numarray = @(1..10) # Create an array from 1 to 20 change 20 to add more SerMSGs!!!!
			}
		$configFilePath = "$($MainFolder)MSG_Config.json"
		Set-Content $configFilePath -Value ""
		$SerMSGnum = $numarray | Get-Random # Select a random SerMSG number from 1 to 20
		$nowSerMSG = $allSerMSG.Where{ $_.SerMSGnumber -eq $SerMSGnum }
		foreach ($line in $nowSerMSG.linesofSerMSG)
			{
				$zz = Invoke-Expression "$($MainFolder)\ASRCon.ps1 ""$serverIP"" $rconPort ""$rconPassword"" ""say -1 $line"""
				$cc = Get-Content "$MainFolder\servercontrol\public\settings\log.txt"
				# Clear the log file
				Clear-Content -Path "$($MainFolder)\servercontrol\public\settings\log.txt"
				Start-Sleep -Seconds 300
			}
		$numarray = $numarray | Where-Object {$_ -ne $SerMSGnum}
		Start-Sleep -Seconds 300
	}
