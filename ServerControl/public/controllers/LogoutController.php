<?php
class LogoutController
{
    public function logoutMethod()
    {
        $root = $_SESSION['root'];
        $_SESSION = array();
        session_destroy();
        header("Location: ".$root."/login");
        exit;
    }
}
