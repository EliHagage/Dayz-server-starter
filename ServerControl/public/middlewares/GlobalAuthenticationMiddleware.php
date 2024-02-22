<?php

require_once __DIR__ . '/../interfaces/MiddlewareInterface.php';

class GlobalAuthenticationMiddleware implements MiddlewareInterface
{
     public function handle($request, Closure $next)
    {
        if (!isset($_SESSION['loggedin']) || $_SESSION['loggedin'] !== true) {
            if ($_SERVER['REQUEST_URI'] !== $_SESSION['root'].'/login') {
                $_SESSION['/login'] = $_SESSION['root']."/login";
                header("Location: ".$_SESSION['root']."/login");
                exit;
            }
        }
        return $next($request);
    }
}
