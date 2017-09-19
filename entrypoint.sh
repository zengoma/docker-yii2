#!/bin/bash
set -e

if [ "$(ls -A vendor)" ]; then
     yes | composer install && yes | php yii migrate up;
     cp -f /nginx.conf /nginx/conf.d/default.conf;
else
    yes | composer update && yes | php yii migrate up;
fi

exec "$@"
