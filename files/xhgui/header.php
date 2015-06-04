<?php

if (!extension_loaded('xhprof')) {
    error_log('xhgui - extension xhprof not loaded');
    return;
}

$dir = dirname(__DIR__);
require_once $dir . '/src/Xhgui/Config.php';
Xhgui_Config::load($dir . '/config/config.default.php');

if (file_exists($dir . '/config/config.php')) {
    Xhgui_Config::load($dir . '/config/config.php');
}

unset($root);

if (!extension_loaded('mongo') && Xhgui_Config::read('save.handler') === 'mongodb') {
    error_log('xhgui - extension mongo not loaded');
    return;
}

if (!Xhgui_Config::shouldRun()) {
    return;
}

if (!isset($_SERVER['REQUEST_TIME_FLOAT'])) {
    $_SERVER['REQUEST_TIME_FLOAT'] = microtime(true);
}

xhprof_enable(XHPROF_FLAGS_CPU | XHPROF_FLAGS_MEMORY | XHPROF_FLAGS_NO_BUILTINS,
    [
        'ignored_functions'	=> [

        ],
    ]
);

register_shutdown_function(
    function () {
        $data['profile'] = xhprof_disable();

        // ignore_user_abort(true) allows your PHP script to continue executing, even if the user has terminated their request.
        // Further Reading: http://blog.preinheimer.com/index.php?/archives/248-When-does-a-user-abort.html
        // flush() asks PHP to send any data remaining in the output buffers. This is normally done when the script completes, but
        // since we're delaying that a bit by dealing with the xhprof stuff, we'll do it now to avoid making the user wait.
        ignore_user_abort(true);
        flush();

        if (!defined('XHGUI_ROOT_DIR')) {
            require dirname(dirname(__FILE__)) . '/src/bootstrap.php';
        }

        $uri = array_key_exists('REQUEST_URI', $_SERVER)
            ? $_SERVER['REQUEST_URI']
            : null;
        if (empty($uri) && isset($_SERVER['argv'])) {
            $cmd = basename($_SERVER['argv'][0]);
            $uri = $cmd . ' ' . implode(' ', array_slice($_SERVER['argv'], 1));
        }

        $time = array_key_exists('REQUEST_TIME', $_SERVER)
            ? $_SERVER['REQUEST_TIME']
            : time();
        $requestTimeFloat = explode('.', $_SERVER['REQUEST_TIME_FLOAT']);
        if (!isset($requestTimeFloat[1])) {
            $requestTimeFloat[1] = 0;
        }

        $requestTs = new MongoDate($time);
        $requestTsMicro = new MongoDate($requestTimeFloat[0], $requestTimeFloat[1]);

        $data['meta'] = array(
            'url' => $uri,
            'SERVER' => $_SERVER,
            'get' => $_GET,
            'env' => $_ENV,
            'simple_url' => Xhgui_Util::simpleUrl($uri),
            'request_ts' => $requestTs,
            'request_ts_micro' => $requestTsMicro,
            'request_date' => date('Y-m-d', $time),
        );

        try {
            $container = Xhgui_ServiceContainer::instance();
            $container['saver']->save($data);
        } catch (Exception $e) {
            error_log('xhgui - ' . $e->getMessage());
        }
    }
);
