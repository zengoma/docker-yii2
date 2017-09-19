# Yii2 application container (with memcached support)
This is a generic Yii2 container. Simply clone your yii2 repo into the mounted
/var/www/html volume.

## How to use this container:

First clone your repo into volumes/app (relative to your docker-compose file). It is
important to do this before you start the containers. You could also fork this project and clone your
app into the /var/www/html folder by modifying entrypoint.sh script accordingly. By doing this you
can now create a dedicated image for your specific project.

The project comes with a basic nginx configuration. To use it mount /nginx/conf.d/default.conf.
Then mount this into your nginx container (see example below).

## Docker compose example

A minimal docker-compose.yml:

```yaml
version: '3.1'
services:  
  nginx:
    image: nginx
    links:
      - app:app
    ports:
      - "80:80"
    volumes:
      - ./app:/var/www/html
      - ./app/nginx/conf.d:/etc/nginx/conf.d

  app:
    image: zengoma/yii2-app:latest
    volumes:
      - ./volumes/app:/var/www/html
      - ./volumes/nginx/app/conf.d:/nginx/conf.d
    links:
      - db:db
      - memcached:memcached
    environment:
      # Your project specific variables

  db:
    image: mysql
    volumes:
      - ./volumes/database:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}

  memcached:
    image: memcached:alpine

```

now:

```bash
 docker-compose up -d
```

Visit "localhost" on your machine.

## Updating your repo.

* Pull your most recent changes from the git repo
* Restart the container ("composer update" and "php yii migrate up") commands are run at start-up.

## Production

I recommend proxying the nginx container in the docker-compose example with https://github.com/jwilder/nginx-proxy , you can even use the letsencrypt companion to easily setup https. An example to follow soon. Alternatively proxy through cloudflare with a free shared ssl certificate.

I like to place all the backend containers on a backend network and nginx on a frontend network. The app should be placed on both networks.
