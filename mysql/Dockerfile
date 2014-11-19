FROM rangalo/ubuntu:14.10

MAINTAINER rangalo "hard.mehta@gmail.com"
ENV http_proxy http://zaae3:ldap$nase9746@172.20.30.201:8080
ENV https_proxy http://zaae3:ldap$nase9746@172.20.30.203:8080
RUN apt-get update
RUN apt-get install -y mysql-server &&\
    rm -vf /var/lib/apt/lists/*
