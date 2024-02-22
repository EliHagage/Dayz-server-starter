<?php
class EditfilesController
{
    public function editfilesMethod()
    {

        $username = $_SESSION['username'];
        global $system_path_settings, $system_path_adminlist, $system_path_jokes, $system_path_servermsg, $system_path_messagematches;

        $errormessages = $_SESSION['errormessages'] ?? [];

        if ($_SERVER['REQUEST_METHOD'] == 'GET') {

            $settings = null;
            $adminlist = null;
            $jokes = null;
            $servermsg = null;
            $messagematches = null;

            if (file_exists($system_path_settings)) {
                $jsonContent = file_get_contents($system_path_settings);
                $settings = json_decode($jsonContent, true);
                if ($settings === null && json_last_error() !== JSON_ERROR_NONE) {
                    $errormessages[] = "Error reading the settings: Invalid JSON.";
                }
            } else {
                $errormessages[] = "The settings file does not exist.";
            }

            if (file_exists($system_path_adminlist)) {
                $adminlist = file_get_contents($system_path_adminlist);
            } else {
                $errormessages[] = "The admin list file does not exist.";
            }

            if (file_exists($system_path_jokes)) {
                $jokes = file_get_contents($system_path_jokes);
            } else {
                $errormessages[] = "The jokes file does not exist.";
            }

            if (file_exists($system_path_servermsg)) {
                $servermsg = file_get_contents($system_path_servermsg);
            } else {
                $errormessages[] = "The server message file does not exist.";
            }

            if (file_exists($system_path_messagematches)) {
                $messagematches = file_get_contents($system_path_messagematches);
            } else {
                $errormessages[] = "The message matches file does not exist.";
            }
            
            $_SESSION['errormessages'] = $errormessages;

            include 'views/editFilesView.php';
            exit;

        } 

        elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {
            if (!isset($_POST['csrf_token']) || $_POST['csrf_token'] !== $_SESSION['csrf_token']) {
                die('CSRF token validation failed.');
            }

            $needToSaveSettings = false;

            if (isset($_POST['settingsContent'])) {
                $decodedSettings = json_decode($_POST['settingsContent'], true);
                if (is_null($decodedSettings) && json_last_error() !== JSON_ERROR_NONE) {
                    $errormessages[] = "Invalid JSON data submitted for settings.";
                } else {
                    $settings = $decodedSettings; 
                    $needToSaveSettings = true; 
                }
            }

            $fileMappings = [
                'adminlistContent' => $system_path_adminlist,
                'jokesContent' => $system_path_jokes,
                'servermsgContent' => $system_path_servermsg,
                'messagematchesContent' => $system_path_messagematches,
            ];

            foreach ($fileMappings as $postKey => $filePath) {
                if (isset($_POST[$postKey])) {
                    file_put_contents($filePath, $_POST[$postKey]);
                }
            }

            if ($needToSaveSettings) {
                file_put_contents($system_path_settings, json_encode($settings, JSON_PRETTY_PRINT));
            }

            if (!empty($errormessages)) {
                $_SESSION['errormessages'] = $errormessages;
            } else {
                $_SESSION['errormessages'][] = "Updates saved successfully.";
            }

            header('Location: ' . $_SESSION['root'] . '/editfiles?t=' . time());
            exit();
        }

    }
}
