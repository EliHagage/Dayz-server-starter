<?php

interface MiddlewareInterface
{
    public function handle($request, Closure $next);
}