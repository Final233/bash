#jdk base 

From harbor.final.com/final/centos_base:v7.6_20210226
MAINTAINER Final 438803792@qq.com

ADD haproxy-2.2.8-Compilation_complete.tar.gz /usr/local/
RUN mkdir /etc/haproxy
ADD haproxy.cfg /etc/haproxy
ADD haproxy_start.sh /usr/local/haproxy/sbin
RUN useradd haproxy -s /sbin/nologin -M && chown haproxy.haproxy -R /etc/haproxy /usr/local/haproxy

ENV PATH $PATH:/usr/local/haproxy/sbin

EXPOSE 80 8888
CMD [ "/usr/local/haproxy/sbin/haproxy_start.sh" ]
