FROM ubuntu:24.04

RUN apt update && apt install -y \
 git \
 wget \
 cmake \
 build-essential libpcre3-dev libssl-dev zlib1g-dev libgd-dev \
 nginx \
 cmark \
 libcmark-dev
WORKDIR /build
RUN git clone https://github.com/github/cmark-gfm.git /build/cmark-gfm
WORKDIR /build/cmark-gfm/build
RUN cmake .. && make -j8
RUN make install
RUN ldconfig
RUN echo '# test' | cmark-gfm
RUN ldd /build/cmark-gfm/build/src/cmark-gfm
RUN git clone https://github.com/ukarim/ngx_markdown_filter_module.git /build/ngx_markdown_filter_module
WORKDIR /build/ngx_markdown_filter_module
RUN mv config_gfm config
WORKDIR /build/
RUN wget http://nginx.org/download/nginx-1.18.0.tar.gz \
  && tar xvzf nginx-1.18.0.tar.gz
WORKDIR /build/nginx-1.18.0
RUN ./configure --prefix=/var/www/html \
  --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf \
  --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log \
   --with-pcre  --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid \
   --with-http_v2_module \
   --user=www-data --group=www-data \
   --build=cmark-gfm \
   --modules-path=/etc/nginx/modules-enabled \
   --add-module=/build/ngx_markdown_filter_module \
   --with-cc-opt=-DWITH_CMARK_GFM=1
RUN make -j8
RUN make install
RUN mkdir /var/www/markdown && cp /build/ngx_markdown_filter_module/template.html /var/www/markdown/
# deactivate ssl as we don't build it
RUN sed -i 's/ssl_/#ssl_/g' /etc/nginx/nginx.conf
COPY cmark-gfm.conf /etc/nginx/snippets/cmark-gfm.conf
RUN sed -i 's_# pass PHP scripts to FastCGI server_include snippets/cmark-gfm.conf;_g' /etc/nginx/sites-enabled/default 
RUN sed -i 's/index index.html index.htm index.nginx-debian.html;/index index.md index.html index.htm;/g' /etc/nginx/sites-enabled/default 
CMD nginx -c /etc/nginx/nginx.conf -g 'daemon off;'