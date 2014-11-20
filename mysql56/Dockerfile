FROM rangalo/ubuntu:14.10

MAINTAINER rangalo "hard.mehta@gmail.com"

RUN apt-get update && \ 
    apt-get install -y mysql-server-5.6 && \
    rm -rf /var/lib/apt/lists/*

# remove pre-install database
RUN rm -rf /var/lib/mysql/*

ADD mysqld-charset.cnf /etc/mysql/conf.d/mysqld-charset.cnf
ADD mysqld-listen.cnf /etc/mysql/conf.d/mysqld-listen.cnf
ADD mysqld-skip-name-resolv.cnf /etc/mysql/conf.d/mysqld-skip-name-resolv.cnf

ADD run.sh /run.sh
RUN chmod 755 /*.sh

# Add VOLUMEs to allow backup of config and databases
VOLUME  ["/etc/mysql", "/var/lib/mysql"]

EXPOSE 3306

CMD ["/run.sh"]
