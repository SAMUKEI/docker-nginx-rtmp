FROM alpine:3.4

ENV NGINX_VERSION 1.13.8
ENV NGINX_RTMP_VERSION 1.2.1
ENV FFMPEG_VERSION 3.3.4

RUN mkdir -p /opt/data && mkdir /www \
  && apk update \
  && apk add --no-cache \
    git gcc binutils-libs binutils build-base libgcc make pkgconf pkgconfig \
    openssl openssl-dev ca-certificates pcre \
    musl-dev libc-dev pcre-dev zlib-dev gettext \
  # Get nginx source.
  && cd /tmp && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar zxf nginx-${NGINX_VERSION}.tar.gz \
  && rm nginx-${NGINX_VERSION}.tar.gz \
  # Get nginx-rtmp module.
  && cd /tmp && wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_VERSION}.tar.gz \
  && tar zxf v${NGINX_RTMP_VERSION}.tar.gz && rm v${NGINX_RTMP_VERSION}.tar.gz \
  && git clone https://github.com/samizdatco/nginx-http-auth-digest.git \
  # Compile nginx with nginx-rtmp module.
  && cd /tmp/nginx-${NGINX_VERSION} \
  && ./configure \
    --prefix=/opt/nginx \
    --add-module=/tmp/nginx-rtmp-module-${NGINX_RTMP_VERSION} \
    --add-module=/tmp/nginx-http-auth-digest \
    --conf-path=/opt/nginx/nginx.conf \
    --error-log-path=/opt/nginx/logs/error.log \
    --http-log-path=/opt/nginx/logs/access.log \
    --with-debug \
  && cd /tmp/nginx-${NGINX_VERSION} && make && make install \
  && cp /tmp/nginx-http-auth-digest/htdigest.py /usr/local/bin/ \
  # ffmpeg dependencies.
  && apk add --no-cache --update \
    nasm yasm-dev lame-dev libogg-dev x264-dev libvpx-dev libvorbis-dev \
    x265-dev freetype-dev libass-dev libwebp-dev rtmpdump-dev libtheora-dev opus-dev \
  && echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
  && apk add  --no-cache --update fdk-aac-dev \
  # Get ffmpeg source.
  && cd /tmp/ && wget http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz \
  && tar zxf ffmpeg-${FFMPEG_VERSION}.tar.gz && rm ffmpeg-${FFMPEG_VERSION}.tar.gz \
  # Compile ffmpeg.
  && cd /tmp/ffmpeg-${FFMPEG_VERSION} && \
    ./configure \
    --enable-version3 \
    --enable-gpl \
    --enable-nonfree \
    --enable-small \
    --enable-libmp3lame \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libvpx \
    --enable-libtheora \
    --enable-libvorbis \
    --enable-libopus \
    --enable-libfdk-aac \
    --enable-libass \
    --enable-libwebp \
    --enable-librtmp \
    --enable-postproc \
    --enable-avresample \
    --enable-libfreetype \
    --enable-openssl \
    --disable-debug \
  && make && make install && make distclean \
  # Cleanup.
  && rm -rf /var/cache/* /tmp/*

ADD nginx.conf /opt/nginx/nginx.conf
ADD static /www/static

EXPOSE 1935
EXPOSE 80

CMD ["/opt/nginx/sbin/nginx"]
