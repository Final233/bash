#My Dockerfile
#centos 7.6 nginx

From harbor.final.com/final/centos_base:v7.6_20210226
MAINTAINER Final 438803792@qq.com

ADD nginx-1.16.1.tar.gz /usr/local/src/ 
RUN cd /usr/local/src/nginx-1.16.1 && ./configure --prefix=/apps/nginx --with-http_sub_module && make -j $(nproc) && make install
ADD nginx.conf /apps/nginx/conf/
RUN useradd nginx -s /sbin/nologin -M && chown nginx.nginx /apps/nginx -R && echo PATH=\$PATH:/apps/nginx/sbin > /etc/profile.d/nginx.sh 

ENV name final 
RUN echo "this is nginx test page.              by $name" > /apps/nginx/html/index.html
ENV PATH PATH=$PATH:/apps/nginx/sbin/

EXPOSE 80 443
CMD [ "/apps/nginx/sbin/nginx" ]
