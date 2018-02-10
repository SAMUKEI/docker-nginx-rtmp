# docker-nginx-rtmp
A Dockerfile installing NGINX, nginx-rtmp-module and FFmpeg from source with
default settings for HLS live streaming. Built on Alpine Linux.

* Nginx 1.13.8 (compiled from source)
* nginx-rtmp-module 1.2.1 (compiled from source)
* ffmpeg 3.3.4 (compiled from source)
* Default HLS settings (See: [nginx.conf](nginx.conf))


## Usage

### Server
* Pull docker image and run:
```
docker pull samukei/docker-nginx-rtmp
docker run -p 1935:1935 -p 8080:80 -d samukei/docker-nginx-rtmp
```
or 

* Build and run container from source:
```
docker build -t nginx-rtmp .
docker run -p 1935:1935 -p 8080:80 -d nginx-rtmp
```

* Stream live content to:
```
rtmp://<server ip>:1935/live/$STREAM_NAME
```

### OBS Configuration
* Stream Type: `Custom Streaming Server`
* URL: `rtmp://localhost:1935/live`
* Stream Key: `hello`

### Watch Stream
* In Safari, VLC or any HLS player, open:
```
http://<server ip>:8080/hls/$STREAM_NAME.m3u8
```
* Example: `http://localhost:8080/hls/hello`


## Resources
* https://alpinelinux.org/
* http://nginx.org
* https://github.com/arut/nginx-rtmp-module
* https://www.ffmpeg.org
* https://obsproject.com
