#tomcat app1

From harbor.final.com/final/tomcat_base:v9.0.37_20210226
MAINTAINER Final 438803792@qq.com

ADD app.tar.gz /apps/tomcat/webapps/
ADD tomcat_start.sh /apps/tomcat/bin
RUN chown tomcat.tomcat /apps/tomcat/ -R 

EXPOSE 8080 8443
CMD [ "/apps/tomcat/bin/tomcat_start.sh" ]
