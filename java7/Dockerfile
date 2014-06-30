FROM debian:wheezy

MAINTAINER rangalo "hard.mehta@gmail.com"

RUN apt-get update
RUN apt-get install -y  wget

RUN mkdir -p /opt/oracle 
RUN wget -q --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk7-downloads-1880260.html; oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u60-b19/jdk-7u60-linux-x64.tar.gz
RUN mv -v  jdk-7u60-linux-x64.tar.gz /opt/oracle
RUN cd /opt/oracle && tar zxf jdk-7u60-linux-x64.tar.gz
RUN cd /opt/oracle/ && rm -vf jdk-7u60-linux-x64.tar.gz
RUN ln -svnf /opt/oracle/jdk1.7.0_60 /opt/oracle/jdk

RUN echo "JAVA_HOME=/opt/oracle/jdk" >> /etc/environment
ENV JAVA_HOME /opt/oracle/jdk
RUN ln -sv /opt/oracle/jdk/bin/java /usr/bin/java
