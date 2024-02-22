<?php

class Router
{
    private $routes = [];

    public function addRoute($method, $path, $controller, $action, $middlewares = [])
    {
        $this->routes[] = [
            'method' => $method,
            'path' => $path,
            'controller' => $controller,
            'action' => $action,
            'middlewares' => $middlewares
        ];
    }

    public function dispatch()
    {
        $requestMethod = $_SERVER['REQUEST_METHOD'];
        $requestUri = $_SERVER['REQUEST_URI'];

        $path = explode('?', $requestUri)[0];

        foreach ($this->routes as $route) {

            $pattern = preg_replace('/\{[^\/]+\}/', '([^\/]+)', $route['path']);
            $pattern = rtrim($pattern, '/') . '/?';
            $pattern = '@^' . $pattern . '$@';

            if ($route['method'] == $requestMethod && preg_match($pattern, $path)) {
                $middlewares = array_map(function($middlewareClass) {
                    return new $middlewareClass();
                }, $route['middlewares']);

                $controller = new $route['controller']();
                $action = $route['action'];

                $middlewareResponse = $this->processMiddlewares($middlewares, function() use ($controller, $action) {
                    call_user_func([$controller, $action]);
                });

                if ($middlewareResponse) {
                    echo $middlewareResponse;
                    return;
                }

                return;
            }
        }

        header("HTTP/1.0 404 Not Found");
        header("Location: ".$_SESSION['root']."/404");
        exit;
    }

    private function processMiddlewares(array $middlewares, Closure $coreAction)
    {
        $middlewareRunner = function($request) use (&$middlewareRunner, &$middlewares, $coreAction) {
            if ($middleware = array_shift($middlewares)) {
                return $middleware->handle($request, $middlewareRunner);
            } else {
                return $coreAction();
            }
        };

        return $middlewareRunner(null);
    }

}
