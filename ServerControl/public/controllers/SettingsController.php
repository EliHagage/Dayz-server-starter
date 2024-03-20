<?php
class SettingsController
{
    public function settingsMethod()
    {

        $username = $_SESSION['username'];
        global $system_path_settings, $system_path_dayzserver;

        $errormessages = $_SESSION['errormessages'] ?? [];

        if ($_SERVER['REQUEST_METHOD'] == 'GET') {
            $settings = null;

            if (file_exists($system_path_settings)) {
                $jsonContent = file_get_contents($system_path_settings);
                $settings = json_decode($jsonContent, true);

                if ($settings === null && json_last_error() !== JSON_ERROR_NONE) {
                    $errormessages[] = "Error reading the settings: Invalid JSON.";
                } 
            } else {
                $errormessages[] = "The settings file does not exist.";
            }
            
            $_SESSION['errormessages'] = $errormessages;

            include 'views/settingsView.php';
            exit;

        } elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {
            if (!isset($_POST['csrf_token']) || $_POST['csrf_token'] !== $_SESSION['csrf_token']) {
                die('CSRF token validation failed.');
            }

            $settings = json_decode(file_get_contents($system_path_settings), true) ?: [];

            // Hanlde ScriptConfiguration Delete
            if (isset($_POST['action']) && $_POST['action'] === 'deleteServerConfigurations' && isset($_POST['serverIndex'])) {
                $serverIndex = $_POST['serverIndex'];

                unset($settings['ServerConfigurations'][$serverIndex]);
                unset($_GET['serverIndex']);

                if (isset($settings['ModInfo']) && is_array($settings['ModInfo'])) {
                    foreach ($settings['ModInfo'] as $modKey => $modValue) {
                        if (isset($modValue['activeServers']) && is_array($modValue['activeServers'])) {

                            $indexToRemove = array_search($serverIndex, $modValue['activeServers']);
                            if ($indexToRemove !== false) {
                                unset($settings['ModInfo'][$modKey]['activeServers'][$indexToRemove]);
                                $settings['ModInfo'][$modKey]['activeServers'] = array_values($settings['ModInfo'][$modKey]['activeServers']);
                            }
                        }
                    }
                }
                file_put_contents($system_path_settings, json_encode($settings, JSON_PRETTY_PRINT));
                header('Location: ' . $_SESSION['root'] . '/settings?t=' . time());
                exit();
            }

            // Hanle ScriptConfiguration add Server
            if (isset($_POST['action']) && $_POST['action'] === 'addNewServer') {

                $newRow = [
                    "Startserver" => false,
                    "Name" => "PLEASE_SET_A_NAME",
                    "Mapfolder" => "dayzOffline.chernarusplus",
                    "Serverip" => "127.0.0.1",
                    "rconport" => "2308",
                    "steamQueryPort" => "27016",
                    "rconpassword" => "12345678",
                    "Server_restart" => "240",
                    "GamePort" => "2302",
                    "serverCPU" => "10",
                    "Args" => [
                        "-PriorityClass Realtime",
                        "-config=chernarusDZ.cfg",
                        "-profiles=chernarusPro",
                        "-port=2302",
                        "-cpuCount=10",
                        "-adminlog",
                        "hostname = Your Host Name",
                        "password = ",
                        "passwordAdmin = *******",
                        "enableWhitelist = 0",
                        "disableBanlist = false",
                        "disablePrioritylist = false",
                        "maxPlayers = 60", 
                        "verifySignatures = 2",
                        "forceSameBuild = 1",
                        "disableVoN = 0",
                        "vonCodecQuality = 10",
                        "disable3rdPerson = 0",
                        "disableCrosshair = 0",
                        "serverTime = SystemTime",
                        "serverTimeAcceleration = 2",
                        "serverNightTimeAcceleration = 6",
                        "serverTimePersistent = 1",
                        "guaranteedUpdates = 1",
                        "loginQueueConcurrentPlayers = 5",
                        "loginQueueMaxPlayers = 500",
                        "instanceId = 1",
                        "storageAutoFix = 1",
                        "respawnTime = 5",
						"timeStampFormat = Short",
                        "logAverageFps = 600",
                        "logMemory = 1",
                        "logPlayers = 1",
						"logFile = serverconsole.log",
                        "adminLogPlayerHitsOnly = 1",
                        "adminLogPlacement = 1",
                        "adminLogBuildActions = 1",
                        "adminLogPlayerList = 1",
                        "disableMultiAccountMitigation = false",
                        "enableDebugMonitor = 0",
                        "allowFilePatching = 1",
                        "simulatedPlayersBatch = 20",
                        "multithreadedReplication = 1",
                        "speedhackDetection = 1",
                        "networkRangeClose = 20",
                        "networkRangeNear = 150",
                        "networkRangeFar = 1000",
                        "networkRangeDistantEffect = 4000",
                        "networkObjectBatchSend = 10",
                        "networkObjectBatchCompute = 1000",
                        "defaultVisibility = 1375",
                        "defaultObjectViewDistance = 1375",
                        "lightingConfig = 1",
                        "disablePersonalLight = 1",
                        "disableBaseDamage = 0",
                        "disableContainerDamage = 0",
                        "disableRespawnDialog = 0",
                        "pingWarning = 350",
                        "pingCritical = 450",
                        "MaxPing = 550",
                        "serverFpsWarning = 15",
                        "shotValidation = 15",
                        "enableCfgGameplayFile = 1",
                        "storeHouseStateDisabled = 1",
                        "EnableDeathMarkers = 1",
                        "TombstoneLifetime = 21600000",
                        "-ServerMod=",
                        "-mod="
                    ]
                ]; 

                if (!isset($settings['ServerConfigurations'])) {
                    $settings['ServerConfigurations'] = [];
                }
                $settings['ServerConfigurations'][] = $newRow;

                file_put_contents($system_path_settings, json_encode($settings, JSON_PRETTY_PRINT));

                header('Location: ' . $_SESSION['root'] . '/settings?t=' . time());
                exit();
            }



            // Handle ScriptConfig Update
            if (isset($_POST['action'], $_POST['config_index']) && $_POST['action'] == 'updateServerConfig' && isset($_POST['config'])) {
                $index = $_POST['config_index'];
                $newConfig = $_POST['config'];

                if (isset($settings['ScriptConfig'][$index])) {
                    $settings['ScriptConfig'][$index] = array_merge($settings['ScriptConfig'][$index], $newConfig);
                    $errormessages[] = "Scrip Config updated successfully.";
                } else {
                    $errormessages[] = "The requested ScriptConfig entry does not exist for index {$index}.";
                }
            }

            // Handle ServerConfigurations Update
            elseif (isset($_POST['action'], $_POST['serverIndex']) && $_POST['action'] == 'updateServerConfigurations') {
                $serverIndex = $_POST['serverIndex'];
                $newConfig = [
                    'Name' => $_POST['Name'] ?? '',
                    'Mapfolder' => $_POST['Mapfolder'] ?? '',
                    'Serverip' => $_POST['Serverip'] ?? '',
                    'rconport' => $_POST['rconport'] ?? '',
                    'steamQueryPort' => $_POST['steamQueryPort'] ?? '',
                    'rconpassword' => $_POST['rconpassword'] ?? '',
                    'Server_restart' => $_POST['Server_restart'] ?? '',
                    'GamePort' => $_POST['GamePort'] ?? '',
                    'serverCPU' => $_POST['serverCPU'] ?? '',

                    'Startserver' => isset($_POST['Startserver']) && $_POST['Startserver'] === 'true' ? true : false,
                    'Args' => $_POST['Args'] ?? []
                ];

                $updatedArgs = $newConfig['Args'];

                $portFound = false;
                foreach ($updatedArgs as $index => $arg) {
                    if (strpos($arg, '-port=') === 0) {
                        $updatedArgs[$index] = "-port=" . $newConfig['GamePort'];
                        $portFound = true;
                        break;
                    }
                }

                $passwordAdminFound = false;
                foreach ($updatedArgs as $index => $arg) {
                    if (preg_match("/^passwordAdmin\s*=\s*.*/", $arg)) {
                        $updatedArgs[$index] = "passwordAdmin = " . $newConfig['rconpassword'];
                        $passwordAdminFound = true;
                        break;
                    }
                }

                if (!$passwordAdminFound) {
                    $updatedArgs[] = "passwordAdmin = " . $newConfig['rconpassword'];
                }

                if (!$portFound) {
                    $updatedArgs[] = "-port=" . $newConfig['GamePort'];
                }
                $newConfig['Args'] = $updatedArgs;



                $profilesValue = '';
                $configValue = '';
                $battleyeValue = 'BattlEye';
                $battleyeConfigValue = 'BEServer_x64.cfg';
                $rconPasswordValue = $newConfig['rconpassword'] ?? '';
                $rconPortValue = $newConfig['rconport'] ?? '';
                $instanceIdValue = '';
                $mpmissionValue = "Mpmissions";
                $mapfolderValue = $newConfig['Mapfolder'];



                foreach ($newConfig['Args'] as $arg) {
                    if (strpos($arg, '-profiles=') === 0) {
                        $profilesValue = substr($arg, strlen('-profiles='));
                    } 

                    elseif (strpos($arg, '-config=') === 0) {
                        $configValue = substr($arg, strlen('-config='));
                    }

                    elseif (preg_match("/^instanceId\s*=\s*(\d+)$/", $arg, $matches)) {
                        $instanceIdValue = $matches[1];
                    }
                }

                if ($profilesValue !== '' && $configValue !== '') {
                    if (!file_exists($system_path_dayzserver)) {
                        mkdir($system_path_dayzserver, 0755, true);
                    }

                    $mpmissionsPath = $system_path_dayzserver . '/' . $mpmissionValue;
                    if (!file_exists($mpmissionsPath)) {
                        mkdir($mpmissionsPath, 0755, true);
                    }

                    $mapfolderPath = $mpmissionsPath . '/' . $mapfolderValue;
                    if (!file_exists($mapfolderPath)) {
                        mkdir($mapfolderPath, 0755, true);
                    }

                    $profilesPath = $system_path_dayzserver . '/' . $profilesValue;
                    if (!file_exists($profilesPath)) {
                        mkdir($profilesPath, 0755, true);
                    }

                    if ($instanceIdValue !== '') {
                        $storagePath = $mapfolderPath . '/storage_' . $instanceIdValue;
                        if (!file_exists($storagePath)) {
                            mkdir($storagePath, 0755, true);
                        }
                    }

                    $battleyePath = $profilesPath . '/' . $battleyeValue;
                    if (!file_exists($battleyePath)) {
                        mkdir($battleyePath, 0755, true);
                    }

                    $battleyeConfigFilePath = $battleyePath . '/' . $battleyeConfigValue;
                    $battleyeConfigContent = "RConPassword " . ($rconPasswordValue ?: '0') . "\n";
                    $battleyeConfigContent .= "RestrictRCon 0\n"; 
                    $battleyeConfigContent .= "RConPort " . ($rconPortValue ?: '0') . "\n";
                    file_put_contents($battleyeConfigFilePath, $battleyeConfigContent);


                    $configFilePath = $system_path_dayzserver . '/' . $configValue;
                    if (!file_exists($configFilePath)) {
                        file_put_contents($configFilePath, ''); 
                    }

                    $keysOrder = [
                        'hostname',
                        'password',
                        'passwordAdmin',
                        'enableWhitelist',
                        'disableBanlist',
                        'disablePrioritylist',
                        'maxPlayers',
                        'verifySignatures',
                        'forceSameBuild',
                        'disableVoN',
                        'vonCodecQuality',
                        'disable3rdPerson',
                        'disableCrosshair',
                        'serverTime',
                        'serverTimeAcceleration',
                        'serverNightTimeAcceleration',
                        'serverTimePersistent',
                        'guaranteedUpdates',
                        'loginQueueConcurrentPlayers',
                        'loginQueueMaxPlayers',
                        'instanceId',
                        'storageAutoFix',
                        'Missions',
                        'respawnTime',
                        'timeStampFormat',
                        'logAverageFps',
                        'logMemory',
                        'logPlayers',
                        'logFile',
                        'adminLogPlayerHitsOnly',
                        'adminLogPlacement',
                        'adminLogBuildActions',
                        'adminLogPlayerList',
                        'disableMultiAccountMitigation',
                        'enableDebugMonitor',
                        'allowFilePatching',
                        'steamQueryPort', 
                        'simulatedPlayersBatch',
                        'multithreadedReplication', 
                        'speedhackDetection',
                        'networkRangeClose',
                        'networkRangeNear',
                        'networkRangeFar',
                        'networkRangeDistantEffect',
                        'networkObjectBatchSend',
                        'networkObjectBatchCompute',
                        'defaultVisibility',
                        'defaultObjectViewDistance',
                        'lightingConfig',
                        'disablePersonalLight',
                        'disableBaseDamage',
                        'disableContainerDamage',
                        'disableRespawnDialog',
                        'pingWarning',
                        'pingCritical',
                        'MaxPing',
                        'serverFpsWarning',
                        'shotValidation',
                        'enableCfgGameplayFile',
                        'storeHouseStateDisabled',
                        'EnableDeathMarkers',
                        'TombstoneLifetime'
                    ];

                    $configContent = "";

                    foreach ($keysOrder as $key) {
                        if ($key === 'steamQueryPort') {
                            $configContent .= "steamQueryPort = " . ($newConfig['steamQueryPort'] ?? '0') . ";\n";
                            continue;
                        }
                        if ($key === 'Missions') {
                            $configContent .= "class Missions\n{\n\tclass DayZ\n\t{\n\t\ttemplate=\"" . ($newConfig['Mapfolder'] ?? 'dayzOffline.chernarusplus') . "\";\n\t};\n};\n";
                            continue;
                        }
                        foreach ($newConfig['Args'] as $arg) {
                            if (preg_match("/^$key\s*=\s*(.*)$/", $arg, $matches)) {
                                $configContent .= "$key = $matches[1];\n";
                                break;
                            }
                        }
                    }

                    if (!file_exists($configFilePath)) {
                        file_put_contents($configFilePath, $configContent);
                    } else {
                        $existingContent = file_get_contents($configFilePath);
                        if ($existingContent !== $configContent) {
                            file_put_contents($configFilePath, $configContent);
                        }
                    }
                }

                if (isset($settings['ServerConfigurations'][$serverIndex])) {
                    $settings['ServerConfigurations'][$serverIndex] = array_merge($settings['ServerConfigurations'][$serverIndex], $newConfig);
                    $errormessages[] = "Server configuration updated successfully.";
                } else {
                    $errormessages[] = "The selected server configuration does not exist.";
                }
            }


            // Handle ModInfo Update
            elseif (isset($_POST['action'], $_POST['config_index'], $_POST['serverIndex']) && $_POST['action'] == 'updateModInfo') {
                $selectedServerIndex = $_POST['serverIndex'];
                $index = $_POST['config_index'];

                if (isset($settings['ModInfo'][$index])) {

                    $activeServers = $settings['ModInfo'][$index]['activeServers'] ?? [];
                    $isActive = isset($_POST['modInfo']) && isset($_POST['modInfo']['activeServers']) && in_array($selectedServerIndex, $_POST['modInfo']['activeServers']);

                    if ($isActive) {
                        if (!in_array($selectedServerIndex, $activeServers)) {
                            $activeServers[] = $selectedServerIndex;
                        }
                    } else {
                        if (($key = array_search($selectedServerIndex, $activeServers)) !== false) {
                            unset($activeServers[$key]);
                        }
                    }
                    $settings['ModInfo'][$index]['activeServers'] = array_values($activeServers);
                    
                    $activeMods = [];
                    foreach ($settings['ModInfo'] as $modInfo) {
                        if (in_array($selectedServerIndex, $modInfo['activeServers'] ?? [])) {
                            $activeMods[] = "@" . $modInfo['Mod_Name'];
                        }
                    }
                    $activeModsString = implode(";", $activeMods) . ";"; 
                    
                    if (isset($settings['ServerConfigurations'][$selectedServerIndex])) {
                        $serverConfig = &$settings['ServerConfigurations'][$selectedServerIndex];
                        $foundModArg = false;
                        foreach ($serverConfig['Args'] as &$arg) {
                            if (strpos($arg, "-mod=") === 0) { 
                                $arg = "-mod=" . $activeModsString; 
                                $foundModArg = true;
                                break;
                            }
                        }
                        if (!$foundModArg) {
                            $serverConfig['Args'][] = "-mod=" . $activeModsString;
                        }
                    }

                    $errormessages[] = "Mod Info updated successfully.";
                } else {
                    $errormessages[] = "The requested ModInfo entry does not exist for index {$index}.";
                }
            }


            if (!empty($errormessages)) {
                $_SESSION['errormessages'] = $errormessages;
            }

            file_put_contents($system_path_settings, json_encode($settings, JSON_PRETTY_PRINT));
            
            if (isset($_GET['serverIndex']) && $_GET['serverIndex'] !== '') {
                header('Location: ' . $_SESSION['root'] . '/settings?serverIndex=' . urlencode($_GET['serverIndex']) . '&t=' . time());
            } elseif (isset($_POST['serverIndex']) && $_POST['serverIndex'] !== '') {
                header('Location: ' . $_SESSION['root'] . '/settings?serverIndex=' . urlencode($_POST['serverIndex']) . '&t=' . time());
            } else {
                header('Location: ' . $_SESSION['root'] . '/settings?t=' . time());
            }
            
            exit();
        }
    }
}
