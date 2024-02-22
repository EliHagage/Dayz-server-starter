<?php
$maxLifeTime = 60 * 10;

$maxLifeTime = $maxLifeTime * 6;

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (isset($_SESSION['last_activity']) && (time() - $_SESSION['last_activity'] > $maxLifeTime)) {

    session_unset();
    session_destroy();
    setcookie(session_name(), "", time() - 42000, "/");
    session_start();
}

$_SESSION['last_activity'] = time();

if (!isset($_SESSION['created'])) {
    $_SESSION['created'] = time();
} else if (time() - $_SESSION['created'] > $maxLifeTime) {

    session_regenerate_id(true);
    $_SESSION['created'] = time();
}

if (!isset($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}
?>
