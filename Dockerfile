FROM alpine:3.4

ENV NGINX_VERSION 1.10.2
ENV NGINX_RTMP_VERSION 1.1.10
ENV FFMPEG_VERSION 3.1.5

RUN mkdir -p /opt/data && mkdir /www

# Install prerequisites and update certificates
RUN apk --update --no-cache add ca-certificates build-base pcre-dev openssl openssl-dev && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/*

# Get nginx source.
RUN cd /tmp && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar zxf nginx-${NGINX_VERSION}.tar.gz \
  && rm nginx-${NGINX_VERSION}.tar.gz

# Get nginx-rtmp module.
RUN cd /tmp && wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_VERSION}.tar.gz \
  && tar zxf v${NGINX_RTMP_VERSION}.tar.gz && rm v${NGINX_RTMP_VERSION}.tar.gz

# Compile nginx with nginx-rtmp module.
RUN cd /tmp/nginx-${NGINX_VERSION} \
  && ./configure \
  --prefix=/opt/nginx \
  --add-module=/tmp/nginx-rtmp-module-${NGINX_RTMP_VERSION} \
  --conf-path=/opt/nginx/nginx.conf --error-log-path=/opt/nginx/logs/error.log --http-log-path=/opt/nginx/logs/access.log \
  --with-debug
RUN cd /tmp/nginx-${NGINX_VERSION} && make && make install

# Cleanup.
RUN rm -rf /var/cache/* /tmp/*

ADD nginx.conf /opt/nginx/nginx.conf
ADD static /www/static

EXPOSE 1935
EXPOSE 80

CMD ["/opt/nginx/sbin/nginx"]
