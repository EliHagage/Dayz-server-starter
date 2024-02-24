try {
    # Attempt to set the execution policy to Unrestricted
    Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force
} catch {
    # If an error occurs (e.g., due to a policy override), ignore it
    Write-Host "Execution policy could not be set. Skipping..."
}

# Determine the main script folder based on the current script location
$MainFolder = Split-Path -Parent $MyInvocation.MyCommand.Path

# If the script is run from the website, adjust the main folder accordingly
if ($MainFolder -like "*\servercontrol\public\settings\") {
    $MainFolder = Split-Path -Parent (Split-Path -Parent $MainFolder)
}

#Set the path to the script folder
$scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Path

# Define the download folder path
$downloadFolder = Join-Path -Path $scriptFolder -ChildPath "Downloads"

# Set the path to the steamcmd.zip file
$steamCmdZipPath = Join-Path -Path $scriptFolder -ChildPath "steamcmd.zip"

# Function to download a file to the specified folder
function Download-File {
    param(
        [string]$url,
        [string]$outputFileName
    )

    # Set the output file path
    $outputFile = Join-Path -Path $downloadFolder -ChildPath $outputFileName

    Write-Host "Downloading $url to $outputFile..."

    $wc = New-Object System.Net.WebClient
    
    # Register the DownloadProgressChanged event handler
    $wc.add_DownloadProgressChanged({
        Write-Progress -Activity "Downloading" -Status "Progress: $($args[1].ProgressPercentage)%" -PercentComplete $args[1].ProgressPercentage
    })

    # Download the file
    $wc.DownloadFile($url, $outputFile)

    Write-Host "Download completed."
}

# Function to run a command silently
function Run-SilentCommand {
    param(
        [string]$command
    )

    Start-Process -FilePath $($MainFolder)\powershell.exe -ArgumentList "-Command `"$command`"" -Wait -NoNewWindow
}

# Function to install Node.js
function Install-NodeJS {
    $nodeInstallerPath = Join-Path -Path $downloadFolder -ChildPath "node-setup.msi"
    if (!(Test-Path $nodeInstallerPath)) {
        $nodeInstallerUrl = "https://nodejs.org/dist/v16.13.1/node-v16.13.1-x64.msi"
        Download-File -url $nodeInstallerUrl -outputFileName "node-setup.msi"
    }

     #Run Node.js installer with user interface
    Start-Process -FilePath msiexec.exe -ArgumentList "/i `"$nodeInstallerPath`"" -Wait

     #Add Node.js to the system PATH
    #$nodePath = Join-Path -Path $installDir -ChildPath "nodejs" -ErrorAction SilentlyContinue 2> $null
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
	$nodePath = "C:\Program Files\nodejs"  # Adjust this path according to the location of your PHP node folder
    if (-not ($currentPath -like "*$nodePath*")) {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$nodePath", "Machine")
    }
	Write-Host "Node installed and added to system PATH."
	
    # Add PHP directory to system PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $phpPath = "C:\php"  # Adjust this path according to the location of your PHP folder
    if (-not ($currentPath -like "*$phpPath*")) {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$phpPath", "Machine")
    }
    Write-Host "PHP installed and added to system PATH."

}

# Function to install VC_redist.x64
function Install-VCRedist {
    # Run VC_redist.x64 installer with GUI
    $vcRedistUrl = "https://aka.ms/vs/16/release/vc_redist.x64.exe"
    $vcRedistExePath = Join-Path -Path $downloadFolder -ChildPath "vc_redist.x64.exe"
    Download-File -url $vcRedistUrl -outputFileName "vc_redist.x64.exe"
    Start-Process -FilePath $vcRedistExePath -Wait
}

# Function to install DirectX Web Setup
function Install-DirectXWebSetup {
    # Set the path to the dxwebsetup file
    $dxWebSetupPath = Join-Path -Path $scriptFolder -ChildPath "dxwebsetup.exe"

    # Check if dxwebsetup file exists
    if (Test-Path $dxWebSetupPath) {
        # Run dxwebsetup and open a window, waiting for it to finish
        Start-Process -FilePath $dxWebSetupPath -Wait
    } else {
        Write-Host "dxwebsetup file not found."
    }
}

# Function to install PHP
function Install-PHP {
    $phpInstallerUrl = "https://windows.php.net/downloads/releases/archives/php-8.0.1-Win32-vs16-x64.zip"
    try {
        # Open the website for downloading PHP
        $websiteUrl = "https://windows.php.net/downloads/releases/archives/php-8.0.1-Win32-vs16-x64.zip"
        Start-Process $websiteUrl
        
        # Prompt the user to continue after downloading PHP
        Read-Host "after the download and unzip to C:\ rename the folder to C:\php. in the script folder you will need to copy php.ini to c:\ and to c:\php. Press Enter after you have finished."
    } catch {
        Write-Error "Failed to open website for downloading PHP: $_"
    }
}

# Function to install Node-PHP package
function Install-NodePHP {
    # Open a PowerShell session to install Node-PHP
    powershell.exe -NoProfile -Command "npm install -g node-php"
}

# Create the download folder if it doesn't exist
if (-not (Test-Path $downloadFolder -PathType Container)) {
    New-Item -Path $downloadFolder -ItemType Directory | Out-Null
}


# Set the path to the userpassword.config file
$userPasswordFile = Join-Path -Path $scriptFolder -ChildPath "servercontrol\userpasword.config"
$userPasswordFile2 = Join-Path -Path $scriptFolder -ChildPath "servercontrol\public\assets\config.php"

# Check if userpassword.config exists
if (Test-Path $userPasswordFile) {
    Write-Host "userpassword.config found. Skipping username and password input."
} else {
    # Prompt user for username and password
    $username = Read-Host "Enter Steam username"
    $password = Read-Host "Enter Steam password" -AsSecureString

    # Convert the secure string password to plain text
    $passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

    $configData = "${username}:${passwordText}"
    Set-Content -Path $userPasswordFile -Value $configData
    Write-Host "userpassword.config created/updated with username and password."

	# Set the path to the settings.json file
	$userPasswordFile1 = Join-Path -Path $scriptFolder -ChildPath "settings.json"
	
	# Check if settings.json exists
	if (Test-Path $userPasswordFile1) {
	    Write-Host "settings.json found. Updating username and password."
	    # Update settings.json file with Steam username and password
	    $settingsJson = Get-Content -Path $userPasswordFile1 | ConvertFrom-Json
	    $settingsJson.ScriptConfig[0].Steam_User_Name = $username
	    $settingsJson.ScriptConfig[0].SteamPassword = $passwordText
	    $settingsJson | ConvertTo-Json -Depth 10 | Set-Content -Path $userPasswordFile1 -Force
	} else {
	    Write-Host "settings.json not found."
	}
		
	# Convert the secure string password to plain text
	$passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
	
	# Update config.php file with Steam username and password
	$configPhpContent = Get-Content -Path $userPasswordFile2 -Raw
	$configPhpContent = $configPhpContent -replace '(?<=\$system_user = ")[^"]*', $username
	$configPhpContent = $configPhpContent -replace '(?<=\$system_password = ")[^"]*', $passwordText
	$configPhpContent | Set-Content -Path $userPasswordFile2 -Force
}

# Install DirectX Web Setup if SteamCMD folder exists
$steamFolder = Join-Path -Path $scriptFolder -ChildPath "steamcmd"
if (!(Test-Path $steamFolder -PathType Container)) {
    Install-DirectXWebSetup
}

# Install VC_redist.x64 if SteamCMD folder exists
if (!(Test-Path $steamFolder -PathType Container)) {
    Install-VCRedist
}

# Set the path to the steamcmd.exe file
$steamCmdExePath = Join-Path -Path $scriptFolder -ChildPath "steamcmd\steamcmd.exe"

# Set the path to the steam folder
$steamFolder = Join-Path -Path $scriptFolder -ChildPath "steamcmd"

# Check if steam folder exists
if (Test-Path $steamFolder -PathType Container) {
    Write-Host "Steam folder already exists. Skipping further installations."
} else {
    # Proceed with installation if Steam folder doesn't exist
    # Set the path to the DayzServer folder
    $dayzServerFolder = Join-Path -Path $scriptFolder -ChildPath "DayzServer"

    # Proceed with installation if DayzServer folder doesn't exist
    if (!(Test-Path $dayzServerFolder -PathType Container)) {
        # Download SteamCMD
        $steamCmdUrl = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
        $steamCmdZipPath = Join-Path -Path $downloadFolder -ChildPath "steamcmd.zip"
        $steamCmdExtractPath = "$scriptFolder\steamcmd"
        Download-File -url $steamCmdUrl -outputFileName "steamcmd.zip"

        # Extract SteamCMD
        Expand-Archive -Path $steamCmdZipPath -DestinationPath $steamCmdExtractPath

		# Read the username and password from the file
		$userPasswordFile = Join-Path -Path $scriptFolder -ChildPath "servercontrol\userpasword.config"
		$credentials = Get-Content $userPasswordFile
		
		# Split the credentials into username and password
		$username, $password = $credentials -split ":", 2
		
		# Format the username and password for the steamcmd.exe command
		$formattedUsername = "`"$username`""  
		$formattedPassword = "`"$password`""  
		
		# Run SteamCMD to install DayZ server
		$steamCmdArguments = "+login $formattedUsername $formattedPassword +force_install_dir $dayzServerFolder +app_update 223350 validate +quit"
		$steamCmdProcess = Start-Process -FilePath $steamCmdExePath -ArgumentList $steamCmdArguments -PassThru -Wait

        # Check the exit code of the SteamCMD process
        if ($steamCmdProcess.ExitCode -eq 7) {
            Write-Host "SteamCMD installation completed successfully."
        }

        ## Remove the steamapps folder if it exists
        #$steamAppFolder = Join-Path -Path $dayzServerFolder -ChildPath "steamapps"
        #if (Test-Path $steamAppFolder -PathType Container) {
        #    Remove-Item -Path $steamAppFolder -Recurse -Force
        #}

        # Install Node.js and add it to the system PATH
        Write-Host "Installing Node.js..."
        Install-NodeJS

        # Install PHP
        Write-Host "Installing PHP..."
        Install-PHP

        # Call the function to install Node-PHP
        Install-NodePHP
    }
}

# Start the web server using Node.js
$webServerPath = Join-Path -Path $scriptFolder -ChildPath "servercontrol\app.js"
Start-Process -FilePath node.exe -ArgumentList $webServerPath -NoNewWindow

# Copy php.ini from the main script folder to C:\php
$phpIniSource = Join-Path -Path $scriptFolder -ChildPath "servercontrol\php.ini"
$phpIniDestination = "C:\php\php.ini"
Copy-Item -Path $phpIniSource -Destination $phpIniDestination -Force

## Set the path to the DayzServer folder
#$dayzServerFolder = Join-Path -Path $scriptFolder -ChildPath "DayzServer"
#
## Step 1: If $dayzServerFolder doesn't exist, create it and copy all files from demoDayzServer
#if (-not (Test-Path $dayzServerFolder)) {
#    # Create the DayzServer directory
#    New-Item -Path $dayzServerFolder -ItemType Directory
#
#    # Copy all files and folders from demoDayzServer to DayzServer
#    Copy-Item -Path "$scriptFolder\demoDayzServer\*" -Destination $dayzServerFolder -Recurse -Force
#} else {
#    # Step 2: Check if specific files and folders exist in DayzServer, if any of them exist, skip copying
#    $filesToCopy = @(
#        "banovDZ.cfg",
#        "chernarusDZ.cfg",
#        "deerisleDZ.cfg",
#        "enochDZ.cfg",
#        "namalskDZ.cfg",
#        "banovPro",
#        "chernarusPro",
#        "DeerislePro",
#        "enochPro",
#        "namalskPro"
#    )
#
#    foreach ($fileToCopy in $filesToCopy) {
#        $destinationFilePath = Join-Path -Path $dayzServerFolder -ChildPath $fileToCopy
#        if (-not (Test-Path $destinationFilePath)) {
#            # If the file doesn't exist in DayzServer, copy it
#            $sourceFilePath = Join-Path -Path "$scriptFolder\demoDayzServer" -ChildPath $fileToCopy
#            Copy-Item -Path $sourceFilePath -Destination $destinationFilePath -Recurse -Force
#        } else {
#            Write-Host "File $fileToCopy already exists in DayzServer. Skipping copying."
#        }
#    }
#}
# Check if it's the first time installation
$firstTimeInstallFlag = "FirstTimeInstall.flag"
$firstTimeInstallFilePath = Join-Path -Path $scriptFolder -ChildPath $firstTimeInstallFlag

if (-not (Test-Path $firstTimeInstallFilePath)) {
    # Set the first-time install flag
    New-Item -Path $firstTimeInstallFilePath -ItemType File | Out-Null

    # Do not open the website during first-time installation
} else {
    # Open the desired web page after a delay
    Start-Sleep -Seconds 5
    Start-Process "http://127.0.0.1:7878/server"
}
