# Source: https://github.com/ivanfilippov/PowerDNS-Admin/blob/docker/Dockerfile
FROM ubuntu
MAINTAINER PowerDNS-Admin Team
RUN apt-get update

ENV PDNSADMIN_PORT 9393
ENV PDNSADMIN_APIURL http://127.0.0.1:8081/
ENV PDNSADMIN_APIKEY admin
ENV PDNSADMIN_DBUSER admin
ENV PDNSADMIN_DBPASS admin
ENV PDNSADMIN_DBHOST 127.0.0.1
ENV PDNSADMIN_DBNAME powerdnsadmin

ENV PDNSADMIN_DIR /opt/PowerDNS-Admin

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get install -y git python-pip python-dev libmysqlclient-dev libsasl2-dev libldap2-dev libssl-dev

RUN mkdir -p $PDNSADMIN_DIR

RUN git clone https://github.com/ngoduykhanh/PowerDNS-Admin.git $PDNSADMIN_DIR

RUN cd /opt/PowerDNS-Admin && \
        pip install virtualenv && \
        virtualenv flask && \
        source ./flask/bin/activate && \
        pip install -r requirements.txt && \
        cp config_template.py config.py && \
        sed "s,BIND_ADDRESS = '127.0.0.1',BIND_ADDRESS = '0.0.0.0',g" -i $PDNSADMIN_DIR/config.py && \
        sed "s,PDNS_STATS_URL = 'http://172.16.214.131:8081/',PDNS_STATS_URL = '$PDNSADMIN_APIURL',g" -i $PDNSADMIN_DIR/config.py && \
        sed "s,PDNS_API_KEY = 'you never know',PDNS_API_KEY = '$PDNSADMIN_APIKEY',g" -i $PDNSADMIN_DIR/config.py && \
        sed "s,SQLALCHEMY_DATABASE_URI = 'mysql://root:123456@192.168.59.103/pdns',SQLALCHEMY_DATABASE_URI = 'mysql://$PDNSADMIN_DBUSER:$PDNSADMIN_DBPASS@$PDNSADMIN_DBHOST/$PDNSADMIN_DBNAME',g" -i $PDNSADMIN_DIR/config.py && \
        sed "s,PORT = 9393,PORT = $PDNSADMIN_PORT,g" -i $PDNSADMIN_DIR/config.py

VOLUME /opt/PowerDNS-Admin
WORKDIR /opt/PowerDNS-Admin
EXPOSE $PDNSADMIN_PORT

ENTRYPOINT /opt/PowerDNS-Admin/run.py
