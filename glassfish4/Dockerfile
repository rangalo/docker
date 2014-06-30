FROM rangalo/java7

MAINTAINER rangalo "hard.mehta@gmail.com"

RUN wget -q  --no-cookies --no-check http://download.java.net/glassfish/4.0/release/glassfish-4.0.zip

RUN mv -v glassfish-4.0.zip /opt/oracle/
RUN cd /opt/oracle && unzip -q glassfish-4.0.zip
RUN ln -svn /opt/oracle/glassfish4 /opt/oracle/glassfish

RUN echo "GLASSFISH_HOME=/opt/oracle/glassfish"
ENV GLASSFISH_HOME /opt/oracle/glassfish

ENV PATH $GLASSFISH_HOME/bin:$PATH

ADD run.sh /run.sh
RUN chmod +x run.sh

# 4848 (administration), 8080 (HTTP listener), 8181 (HTTPS listener)
EXPOSE 4848 8080 8181

# CMD ["/run.sh"]
