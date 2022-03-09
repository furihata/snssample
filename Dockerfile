FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
   tzdata \
   apache2 \
   php7.4 \
   php7.4-mysql \
   php7.4-mbstring \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* \
&& rm -rf /var/www/html/*
COPY server/bootapache.sh /root/
COPY server/php.ini /etc/php/7.4/apache2/
COPY server/php /var/www/html
EXPOSE 80
CMD ["bash","/root/bootapache.sh"]

