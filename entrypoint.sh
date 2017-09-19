#!/bin/bash
set -e

cp -f /nginx.conf /nginx/conf.d/default.conf;

if [ "$(ls -A vendor)" ]; then
    yes | composer update && yes | php yii migrate up;
else
    yes | composer install && yes | php yii migrate up;
fi

exec "$@"
