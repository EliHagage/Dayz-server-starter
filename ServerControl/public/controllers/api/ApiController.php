<?php
class ApiController
{
    private function runPowerShellScript($scriptPath, $args = null, $hidden = false) {
        $cmd = "powershell.exe";
        if ($hidden) {
            $cmd .= " -WindowStyle Hidden";
        }
        $cmd .= " -File " . escapeshellarg($scriptPath);
        if ($args !== null) {
            $argString = escapeshellarg(json_encode($args));
            $cmd .= " " . $argString;
        }
        if ($hidden) {
            pclose(popen("start /B " . $cmd, "r"));
        } else {
            pclose(popen("start " . $cmd, "r"));
        }
    }


    public function postMethod()
    {

        global $system_path_startserver, $system_path_updateserver, $system_user, $system_password, $system_path_config;

        if ($_SERVER['REQUEST_METHOD'] == 'GET') {

            if (isset($_GET['action'])) {
                $redirectUrl = $_SESSION["root"] . "/";
                
                $hidden = isset($_GET['hidden']) && $_GET['hidden'] == 'true';

                if ($_GET['action'] == 'start-server') {
                    $this->runPowerShellScript($system_path_startserver, null, $hidden);
                    if ($hidden) {
                        $redirectUrl .= "?hidden=true";
                    }
                }
                elseif ($_GET['action'] == 'update-server') {
                    $this->runPowerShellScript($system_path_updateserver, null, $hidden);
                    if ($hidden) {
                        $redirectUrl .= "?hidden=true";
                    }
                }

                header("Location: " . $redirectUrl);
                exit;
            }

            $data = [];
            $accepted = true;
            $statuscode = 200;

            $response = [
                'uri' => $_SERVER['REQUEST_URI'] ?? null,
                'params' => $_GET ?? null,
                'method' => $_SERVER['REQUEST_METHOD'] ?? null,
                'request' => $_GET['request'] ?? null,
                'status' => [
                    'accepted' => $accepted,
                    'statusCode' => $statuscode
                ],
                'data' => $data
            ];

            header('Content-Type: application/json');
            echo json_encode($response);
            exit;

        } elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {

            if (!isset($_POST['csrf_token']) || $_POST['csrf_token'] !== $_SESSION['csrf_token']) {

                $response = [
                    'uri' => $_SERVER['REQUEST_URI'] ?? null,
                    'params' => $_GET ?? null,
                    'method' => $_SERVER['REQUEST_METHOD'] ?? null,
                    'request' => $_GET['request'] ?? null,
                    'status' => [
                        'accepted' => false,
                        'statusCode' => 400,
                        'detail' => 'CSRF-Token-Validation Error',
                        'time' => date("Y-m-d H:i:s")
                    ]
                ];

                header('Content-Type: application/json');
                echo json_encode($response);
                exit;
            }

            if (isset($_POST['action']) && $_POST['action'] == 'changePassword' && isset($_POST['setPassword'], $_POST['confirmPassword'], $_POST['setUsername'])) {
                if ($_POST['setPassword'] === $_POST['confirmPassword']) {
                    $newPassword = $_POST['setPassword'];
                    $newUsername = $_POST['setUsername'];

                    $configContent = file_get_contents($system_path_config);
                    $newConfigContent = preg_replace("/(\\\$system_password\s*=\s*)\".*\";/", "$1\"$newPassword\";", $configContent);
                    $newConfigContent = preg_replace("/(\\\$system_user\s*=\s*)\".*\";/", "$1\"$newUsername\";", $newConfigContent);

                    if ($newConfigContent && $newConfigContent !== $configContent) {
                        file_put_contents($system_path_config, $newConfigContent);

                        header("Location: ".$_SESSION["root"]."/logout");
                        exit;
                    }
                }
            }

            if (isset($_POST['action']) && $_POST['action'] == 'changePassword') {
                if (isset($_POST['setPassword'], $_POST['confirmPassword'], $_POST['setUsername'])) {
                    if ($_POST['setPassword'] === $_POST['confirmPassword']) {
                        $newPassword = $_POST['setPassword'];
                        $newUsername = $_POST['setUsername'];

                        $configContent = file_get_contents($system_path_config);
                        $newConfigContent = preg_replace("/(\\\$system_password\s*=\s*)\".*\";/", "$1\"$newPassword\";", $configContent);
                        $newConfigContent = preg_replace("/(\\\$system_user\s*=\s*)\".*\";/", "$1\"$newUsername\";", $newConfigContent);

                        if ($newConfigContent && $newConfigContent !== $configContent) {
                            file_put_contents($system_path_config, $newConfigContent);
                            $_SESSION['messages'][] = 'Your password/username has been successfully changed.';
                            header("Location: ".$_SESSION["root"]."/logout");
                            exit;
                        } else {
                            if (preg_match("/\\\$system_password\s*=\s*\"$newPassword\";/", $configContent) &&
                                preg_match("/\\\$system_user\s*=\s*\"$newUsername\";/", $configContent)) {
                                $_SESSION['messages'][] = 'The new password/username is the same as the current one.';
                            } else {
                                $_SESSION['messages'][] = 'Password and confirm password do not match.';
                            }
                            header("Location: ".$_SESSION["root"]."/");
                            exit;
                        }


                    } else {
                        $_SESSION['messages'][] = 'Password and confirm password do not match.';
                        header("Location: ".$_SESSION["root"]."/");
                        exit;
                    }
                }
            } 



            if (isset($_POST['action']) && $_POST['action'] == 'test') {

                $_SESSION['messages'] = [];

                if (empty($_SESSION['messages'])) {
                    $_SESSION['messages'][] = 'No Errors.';
                }

                header("Location: ".$_SESSION["root"]."/");
                exit;
            }
        }
    }
}
