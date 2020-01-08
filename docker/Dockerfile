FROM nginx:latest

WORKDIR /

ADD ./opt/nginx/conf.d/service.conf /etc/nginx/conf.d/default.conf
ADD ./opt/nginx/www/status.json /usr/share/nginx/html/status/

EXPOSE 80