<?php

return [
    'debug' => false,
    'mode' => 'development',
    'save.handler' => 'mongodb',
    'db.host' => 'mongodb://127.0.0.1:27017/xhprof',
    'db.db' => 'xhprof',
    'templates.path' => dirname(__DIR__) . '/src/templates',
    'date.format' => 'M jS H:i:s',
    'detail.count' => 6,
    'page.limit' => 25,
    'profiler.enable' => function() {
        if (0 === strpos($_SERVER['HTTP_HOST'], 'profiler.move-elevator.dev')) {
            return true;
        }

        return false;
    },
    'profiler.simple_url' => function($url) {
        return preg_replace('/\=\d+/', '', $url);
    }
];