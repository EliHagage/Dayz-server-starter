<?php
class ModinfosController
{
    public function modinfosMethod()
    {

        $username = $_SESSION['username'];
        global $system_path_settings;

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

            include 'views/modinfosView.php';
            exit;

        } elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {
            if (!isset($_POST['csrf_token']) || $_POST['csrf_token'] !== $_SESSION['csrf_token']) {
                die('CSRF token validation failed.');
            }

            $settings = json_decode(file_get_contents($system_path_settings), true) ?: [];

            // Handle Mod Infos Update
            if (isset($_POST['action'], $_POST['config_index']) && $_POST['action'] == 'updateModInfo') {
                $index = $_POST['config_index'];

                if (isset($settings['ModInfo'][$index])) {
                    $settings['ModInfo'][$index]['Mod_Name'] = $_POST['modName'] ?? $settings['ModInfo'][$index]['Mod_Name'];
                    $settings['ModInfo'][$index]['Mod_ID'] = $_POST['modId'] ?? $settings['ModInfo'][$index]['Mod_ID'];
                    $errormessages[] = "Mod information updated successfully.";
                } else {
                    $errormessages[] = "Mod not found.";
                }
            }

            // Handle Mod Infos Delete
            if (isset($_POST['action'], $_POST['config_index']) && $_POST['action'] == 'deleteModInfo') {
                $index = $_POST['config_index'];

                if (isset($settings['ModInfo'][$index])) {
                    unset($settings['ModInfo'][$index]);
                    
                    $settings['ModInfo'] = array_values($settings['ModInfo']);
                    $errormessages[] = "Mod deleted successfully.";
                } else {
                    $errormessages[] = "Mod not found.";
                }
            }

            // Handle Adding New Mod Info
            if (isset($_POST['action']) && $_POST['action'] == 'addModInfo') {

                $newMod = [
                    'Mod_Name' => 'Default Mod Name',
                    'Mod_ID' => '000000',
                ];

                $settings['ModInfo'][] = $newMod;

                $errormessages[] = "New mod added successfully with default values.";
            }



            if (!empty($errormessages)) {
                $_SESSION['errormessages'] = $errormessages;
            }

            file_put_contents($system_path_settings, json_encode($settings, JSON_PRETTY_PRINT));
            
            header('Location: ' . $_SESSION['root'] . '/modinfos?t=' . time());
            exit();
        }
    }
}
