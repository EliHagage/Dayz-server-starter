param (
    [string]$argumentList
)
$argumentList = "$argumentList"
$argumentList = $argumentList.Trim("{ ")
$argumentList = $argumentList.Trim("}")

$argumentList
$aaaa=@()
$bbbb=@()
$cccc=@()

$folderNameDZ = ""
$folderNameBE = ""
#Startserver :false, Name : Chernarus , Mapfolder : dayzOffline.chernarusplus , Serverip : 192.168.0.48 , rconport : 2308 , steamQueryPort : 27016 , rconpassword : TESTPASS , Server_restart : 480 , GamePort : 2302 , serverCPU : 10 , Args :[ -PriorityClass Realtime , -config=chernarusDZ.cfg , -profiles=chernarusPro , -cpuCount= , -adminlog , serverTimeAcceleration = 2 , instanceId = 1 , maxPlayers = 3 , adminLogBuildActions = 0 , logAverageFps = 3 , adminLogPlayerList = 1 , serverNightTimeAcceleration = 6 , forceSameBuild = 1 , disableCrosshair = 0 , multithreadedReplication = 1 , hostname = Your Host Name , serverTime = SystemTime , passwordAdmin = dfsdfsdfsdfsdfsd , enableCfgGameplayFile = 1 , vonCodecQuality = 10 , loginQueueMaxPlayers = 500 , storageAutoFix = 1 , disable3rdPerson = 0 , loginQueueConcurrentPlayers = 5 , password =  , enableWhitelist = 0 , adminLogPlacement = 1 , verifySignatures = 1 , storeHouseStateDisabled = 0 , serverTimePersistent = 1 , enableDebugMonitor = 0 , EnableDeathMarkers = 1 , guaranteedUpdates = 1 , disablePersonalLight = 1 , TombstoneLifetime = 21600000 , -ServerMod= , -mod=@CF;@VPPAdminTools; ]}
#.\updatefiles.ps1 'Startserver :true, Name : Chernarus , Mapfolder : dayzOffline.chernarusplus , Serverip : 192.168.0.48 , rconport : 2308 , steamQueryPort : 27016 , rconpassword : 213 , Server_restart : 480 , GamePort : 2302 , serverCPU : 10 , Args :[ -PriorityClass Realtime ,       -config=chernarusDZ.cfg , -profiles=chernarusPro , -cpuCount= , -adminlog , serverTimeAcceleration = 110 , instanceId = 210 , maxPlayers = 013 , adminLogBuildActions = 001 , logAverageFps = 600 , adminLogPlayerList = 1 , serverNightTimeAcceleration = 6 , forceSameBuild = 1 , disableCrosshair = 0 , multithreadedReplication = 1 , hostname = Your Host Name , serverTime = SystemTime , passwordAdmin = dfsdfsdfsdfsdfsd , enableCfgGameplayFile = 1 , vonCodecQuality = 10 , loginQueueMaxPlayers = 500 , storageAutoFix = 1 , disable3rdPerson = 0 , loginQueueConcurrentPlayers = 5 , password =  , enableWhitelist = 0 , adminLogPlacement = 1 , verifySignatures = 1 , storeHouseStateDisabled = 0 , serverTimePersistent = 1 , enableDebugMonitor = 0 , EnableDeathMarkers = 1 , guaranteedUpdates = 1 , disablePersonalLight = 1 , TombstoneLifetime = 21600000 , -ServerMod= , -mod=@CF;@VPPAdminTools; ]'

# Extract folder names from argument list
$arguments = $argumentList -split ","
#$folderNameDZ = $arguments | Where-Object { $_ -match "config=(\w+\.cfg)" } | ForEach-Object { $matches[1] }
"00000000000000000000000000000000000000000000"
$argumentList
"1111111111111111111111111111111111111111111111111"
$arguments
"22222222222222222222222222222222222222222222222222"

$folderNameBE = $argumentList | Where-Object {$_ -match "-profiles=(.*?) ,"} | ForEach-Object { $matches[1] }
$folderNameDZ = $argumentList | Where-Object {$_ -match "-config=(.*?) ,"} | ForEach-Object { $matches[1] }

# Get the directory where the script is located
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

# Define the file paths relative to the script directory
$beserverDirectory = Join-Path -Path $scriptDirectory -ChildPath "DayzServer\$folderNameBE\BattlEye"
Write-Host "BattlEye Directory: $beserverDirectory"
$beserverFilePath = Join-Path -Path $beserverDirectory -ChildPath "BEServer_x64.cfg"
Write-Host "BEServer file path: $beserverFilePath"
$dzFilePath = Join-Path -Path $scriptDirectory -ChildPath "DayzServer\$folderNameDZ"
Write-Host "$folderNameDZ Directory: $dzFilePath"
Write-Host "Folder Name DZ: $folderNameDZ"

# Initialize an empty hashtable for properties
$properties = @{}

# Define the list of properties and their corresponding values
foreach ($arg in $arguments) {
    if ($arg -match "(\w+)\s*[=|:]\s*(.*)") {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        $properties[$key] = $value
    }
}

# Log file initialization
$logFilePath = Join-Path -Path $scriptDirectory -ChildPath "update_log.txt"
Add-Content -Path $logFilePath -Value "Updating configuration files for folder: $folderNameBE"
Add-Content -Path $logFilePath -Value "New values:"
foreach ($key in $properties.Keys) {
    Add-Content -Path $logFilePath -Value "$key = $($properties[$key])"
}

# Update BEServer_x64.cfg
$gg = Get-Content $beserverFilePath
foreach ($line in $gg)
{
    $line = $line.Trim()
    if ($line -match '^\s*(\w+)\s* \s*(.*)$') {
        $key = $matches[1]
#        if($key -eq "RConPassword"){$key = "rconpassword"}
        if ($properties.ContainsKey($key)) {
            $oldValue = $matches[1].Trim()
            $newValue = $properties[$key]
            <#Add-Content -Path $logFilePath -Value#> "Updating $key from '$oldValue' to '$newValue'"
            $line = $line -replace "^\s*$key\s* .*$", "$key $newValue"
        }
    }
    $bbbb += $line
} Set-Content $beserverFilePath -Value $bbbb -Force

# Update DZ.cfg (similar to BEServer_x64.cfg)
$vv = Get-Content "$($dzFilePath)"
ForEach($zzaa in $vv)
{
    $ss=$zzaa
    $ss
    $zzaa = $zzaa.Trim()
    if ($zzaa -match '^\s*(\w+)\s*=\s*(.*)$') {
        $key = $matches[1]
        if ($properties.ContainsKey($key)) {
            $oldValue = $matches[1].Trim()
            $newValue = $properties[$key]
            <#Add-Content -Path $logFilePath -Value#> "Updating $key from '$oldValue' to '$newValue'"
            $zzaa = $ss -replace "$key\s*=.*$", "$key = $newValue"
            $zzaa = "$zzaa;"
        }
        else
        {
            $zzaa = $ss
        }
    }
    else
    {
        $zzaa= $ss
    }
    $aaaa +=$zzaa

} Set-Content "$($dzFilePath)" -Value $aaaa -Force
$aaaa
$cccc += $argumentList
$cccc += "Configuration files updated successfully."
$cccc
Add-Content -Path $logFilePath -Value $cccc
#Start-Sleep -Seconds 15