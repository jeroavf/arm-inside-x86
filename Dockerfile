FROM arm32v7/debian:stretch-slim

COPY qemu-arm-static /usr/bin

RUN apt-get update;\
    apt-get install -y nginx;\
    echo "\ndaemon off;" >> /etc/nginx/nginx.conf

CMD ["nginx"]
