<?php

require_once __DIR__ . '/../interfaces/MiddlewareInterface.php';

class AuthenticationMiddleware implements MiddlewareInterface
{
    public function handle($request, Closure $next)
    {
        if (!isset($_SESSION['loggedin']) || $_SESSION['loggedin'] !== true) {
            header("Location: ".$_SESSION['root']."/login");
            exit;
        }
        return $next($request);
    }
}