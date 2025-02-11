<?php
declare(strict_types=1);

use Tqdev\PhpCrudApi\Api as CrudApi;
use Tqdev\PhpCrudApi\Config\Config as CrudConfig;
use Nyholm\Psr7\Factory\Psr17Factory;
use Tqdev\PhpCrudApi\ResponseUtils;

require __DIR__.'/vendor/autoload.php';
if (function_exists('opcache_reset')) {
    opcache_reset();
}
if (function_exists('apc_clear_cache')) {
    apc_clear_cache();
}
ini_set('memory_limit', '512M');
date_default_timezone_set(getenv('TZ'));

try{
    $apiConfig = new CrudConfig([
        'driver'      => 'mysql',
        'address'     => getenv('MYSQL_HOST'),
        'port'        =>(int) getenv('MYSQL_PORT'),
        'database'    => getenv('MYSQL_DATABASE'),
        'username'    => getenv('MYSQL_USER'),
        'password'    => getenv('MYSQL_PASSWORD'),
        'basePath'    => '/',
        'middlewares'  => 'cors,xml,json'
    ]);
    $api = new CrudApi($apiConfig);
    $queryString = $request->server['query_string'] ?? '';
    $baseUri = 'http://localhost:'.getenv('WEB_SERVER_PORT').$_SERVER['REQUEST_URI'];
    $queryString = $_SERVER['QUERY_STRING'] ?? '';
    if (!empty($queryString)) {
        // Cek apakah request_uri sudah mengandung query string
        if (strpos($baseUri, '?') === false) {
            $baseUri .= '?' . $queryString;
        }
    }
    $psr17Factory = new Psr17Factory();
    $request = $psr17Factory->createServerRequest($_SERVER['REQUEST_METHOD'], $baseUri);
    $response = $api->handle($request);
    ResponseUtils::output($response);
}catch(Throwable $ex){
    $errorString = "Internal Server Error: " . $ex->getMessage();
    echo $errorString;
    if (gc_enabled()) {
        gc_collect_cycles();
    }
}