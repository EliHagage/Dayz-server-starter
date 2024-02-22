<?php

require_once __DIR__ . "/assets/session.php";
require_once __DIR__ . "/assets/config.php";


require_once 'middlewares/GlobalAuthenticationMiddleware.php';
require_once 'middlewares/AuthenticationMiddleware.php';

require_once 'Router.php';
require_once 'controllers/NotFoundController.php';
require_once 'controllers/LoginController.php';
require_once 'controllers/LogoutController.php';
require_once 'controllers/RootController.php';
require_once 'controllers/SettingsController.php';
require_once 'controllers/ModinfosController.php';
require_once 'controllers/EditfilesController.php';

require_once 'controllers/api/ApiController.php';

header("Cache-Control: no-cache, must-revalidate");
header("Expires: Sat, 26 Jul 1997 05:00:00 GMT");

$_SESSION['root'] = "/server";
# $_SESSION['root'] = null;

$router = new Router();
$router->addRoute('GET', $_SESSION['root'].'/404', 'NotFoundController', 'notFoundMethod');
$router->addRoute('GET', $_SESSION['root'].'/login', 'LoginController', 'loginMethod');
$router->addRoute('POST', $_SESSION['root'].'/login', 'LoginController', 'loginMethod');
$router->addRoute('GET', $_SESSION['root'].'/logout', 'LogoutController', 'logoutMethod');
$router->addRoute('GET', $_SESSION['root'].'/', 'RootController', 'rootMethod', ['AuthenticationMiddleware']);
$router->addRoute('GET', $_SESSION['root'].'/settings', 'SettingsController', 'settingsMethod', ['AuthenticationMiddleware']);
$router->addRoute('POST', $_SESSION['root'].'/settings', 'SettingsController', 'settingsMethod', ['AuthenticationMiddleware']);
$router->addRoute('GET', $_SESSION['root'].'/modinfos', 'ModinfosController', 'modinfosMethod', ['AuthenticationMiddleware']);
$router->addRoute('POST', $_SESSION['root'].'/modinfos', 'ModinfosController', 'modinfosMethod', ['AuthenticationMiddleware']);
$router->addRoute('GET', $_SESSION['root'].'/editfiles', 'EditfilesController', 'editfilesMethod', ['AuthenticationMiddleware']);
$router->addRoute('POST', $_SESSION['root'].'/editfiles', 'EditfilesController', 'editfilesMethod', ['AuthenticationMiddleware']);

$router->addRoute('GET', $_SESSION['root'].'/api', 'ApiController', 'postMethod', ['AuthenticationMiddleware']);
$router->addRoute('POST', $_SESSION['root'].'/api', 'ApiController', 'postMethod', ['AuthenticationMiddleware']);

$globalAuthMiddleware = new GlobalAuthenticationMiddleware();
$globalAuthMiddleware->handle(null, function() use ($router) {
    $router->dispatch();
});
