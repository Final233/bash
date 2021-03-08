#jdk base 

From harbor.final.com/final/centos_base:v7.6_20210226
MAINTAINER Final 438803792@qq.com

ADD jdk-8u181-linux-x64.tar.gz /usr/local/src
RUN ln -sv /usr/local/src/jdk1.8.0_181 /usr/local/jdk && echo "JAVA_HOME=/usr/local/jdk/bin" > /etc/profile.d/jdk.sh && echo "PATH=\$PATH:\$JAVA_HOME" >> /etc/profile.d/jdk.sh

ENV JAVA_HOME /usr/local/jdk
ENV JRE_HOME $JAVA_HOME/jre
ENV CLASSPATH $JAVA_HOME/lib/:$JRE_HOME/lib/
ENV PATH $PATH:$JAVA_HOME/bin
