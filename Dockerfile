FROM alpine:3.8
MAINTAINER litianshi lts8989@163.com
COPY ["swoole-4.2.9.tgz","/installScript/"]
COPY ["composer.phar","/usr/local/bin/composer"]
COPY ["inotify-2.0.0.tgz","/installScript/"]

ENV PHPIZE_DEPS autoconf file g++ gcc libc-dev make pkgconf re2c php7-dev php7-pear yaml-dev tzdata
ENV TIMEZONE            Asia/Shanghai

RUN	VERSION="7.2" \
    && NEED_APK="php7>$VERSION php7-fpm>$VERSION" \
    && apk --update add $NEED_APK php7-mysqli php7-pdo_mysql php7-mbstring php7-json php7-zlib \
	php7-gd php7-intl php7-session php7-fpm php7-phar php7-simplexml bash vim \
	libressl-dev openssl nghttp2 nghttp2-dev php7-sockets php7-redis php7-bcmath php7-posix && \
	apk add --virtual .phpize-deps \
    $PHPIZE_DEPS \
	&& sed -i 's/^exec $PHP -C -n/exec $PHP -C/g' $(which pecl) && \
	pecl install /installScript/inotify-2.0.0.tgz && \
	tar zxvf /installScript/swoole-4.2.9.tgz -C /installScript/ && \
	cd /installScript/swoole-4.2.9 && phpize && \
	./configure \
	--enable-sockets \
	--enable-debug \
	--enable-mysqlnd \
	--enable-swoole \
	--enable-http2 \
	--enable-openssl \
	--enable-sockets \
	--enable-debug-log \
	--enable-trace-log && \
	make clean && make && make install && \
	rm -rf /usr/share/php7 \
    && rm -rf /tmp/* \
    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
	&& echo "${TIMEZONE}" > /etc/timezone \
    && apk del .phpize-deps	\
    && rm -rf /var/cache/apk/* \
    && chmod 777 /usr/local/bin/composer && \
    composer config -g repo.packagist composer https://packagist.phpcomposer.com && adduser -D www

COPY ["swoole.ini","/etc/php7/conf.d/swoole.ini"]

VOLUME ["/var/www/lemon"]
ENV PS1 '[\u@\h \W]\$ '
CMD /bin/bash    

#FROM alpine:latest
#MAINTAINER litianshi lts8989@163.com
#COPY ["swoole-4.3.1.tgz","/installScript/"]
#COPY ["composer.phar","/usr/local/bin/composer"]
#ADD ["php-7.2.2.tar.gz","/"]
#
#
#ENV PHPIZE_DEPS autoconf file g++ gcc libc-dev make pkgconf re2c yaml-dev tzdata
#ENV TIMEZONE            Asia/Shanghai
#
#RUN set -xe \
#	&& echo -e "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.7/main\n\
#https://mirror.tuna.tsinghua.edu.cn/alpine/v3.7/community" > /etc/apk/repositories && \
#	apk --update add bash vim
#
#RUN apk add --virtual .phpize-deps \
#    $PHPIZE_DEPS 
#
#RUN apk add libxml2
#
#RUN cd php-7.2.2 && ./configure --prefix=/usr/local/php72/ --enable-mbstring --with-curl #--with-gd --enable-fpm --enable-mysqlnd  --with-pdo-mysql=mysqlnd --with-config-file-path=/usr/#local/php72/etc/ --with-mysqli=mysqlnd --with-apsx2=/usr/sbin/apxs --with-openssl #--with-zlib=/usr && \
#	make && make install && \
# 	cp /php-7.2.2/php.ini-production /usr/local/php72/etc/php.ini 
#
##RUN pecl install /installScript/swoole-4.3.1.tgz
#
#
#
#
##	php7 php7-mysqli php7-pdo_mysql php7-mbstring php7-json php7-zlib \
##	php7-gd php7-intl php7-session php7-xdebug php7-fpm php7-phar php7-simplexml bash vim && \
##	apk add --virtual .phpize-deps \
##    $PHPIZE_DEPS \
##	&& sed -i 's/^exec $PHP -C -n/exec $PHP -C/g' $(which pecl) \
##	&& pecl install /installScript/swoole-4.3.1.tgz \
##	&& rm -rf /usr/share/php7 \
##    && rm -rf /tmp/* \
##    && cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
##	&& echo "${TIMEZONE}" > /etc/timezone \
##    && apk del .phpize-deps	\
##    && rm -rf /var/cache/apk/* \
##    && chmod 777 /usr/local/bin/composer
#
#COPY ["swoole.ini","/etc/php7/conf.d/swoole.ini"]
#
#RUN composer config -g repo.packagist composer https://packagist.phpcomposer.com && adduser -D #www
#
#VOLUME ["/var/www/lemon"]
#ENV PS1 '[\u@\h \W]\$ '
#CMD /bin/bash    