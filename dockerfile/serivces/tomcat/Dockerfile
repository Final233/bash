#tomcat base 

From harbor.final.com/final/jdk_base:v8u181_20210226 
MAINTAINER Final 438803792@qq.com

ADD apache-tomcat-9.0.37.tar.gz /apps/
ADD tomcat_del_log.sh /root/
RUN ln -sv /apps/apache-tomcat-9.0.37 /apps/tomcat && useradd tomcat && echo "0 2 * * * /bin/bash /root/tomcat_del_log.sh &> /dev/null" >> /var/spool/cron/root

#env settinf
ENV TZ "Asia/Shanghai"
ENV LANG en_US.UTF-8
ENV TERM xterm
#ENV TOMCAT_MAJOR_VERSION 9
#ENV TOMCAT_MINOR_VERSION 9.0.37
#ENV CATALINA_HOME /apps/tomcat
#ENV APP_DIR ${CATALINA_HOME}/webapps

