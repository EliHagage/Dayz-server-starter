<?php
class LoginController
{
    public function loginMethod()
    {
        if ($_SERVER['REQUEST_METHOD'] == 'GET') {
            if (!isset($_SESSION['login_error'])) {
                $_SESSION['login_error'] = null;
            }
            include 'views/loginView.php';
        } elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {
            
            if (!isset($_POST['csrf_token']) || $_POST['csrf_token'] !== $_SESSION['csrf_token']) {
                die('CSRF-Token-Validation failed');
            }

            
            if (isset($_POST['action']) && $_POST['action'] == 'login') {
                $username = $_POST['username'];
                $password = $_POST['password'];

                global $system_user, $system_password;

                if ($username === $system_user && $password === $system_password) {
                    $_SESSION['loggedin'] = true;
                    $_SESSION['username'] = $username;
                    header("Location: ".$_SESSION["root"]."/");
                    exit;
                } else {
                    $_SESSION['login_error'] = "Incorrect user name or password!";
                    header("Location: ".$_SESSION["root"]."/");
                    exit;
                }
            } else {
                header("Location: ".$_SESSION["root"]."/");
                exit;
            }
        
        }

        
    }
}
