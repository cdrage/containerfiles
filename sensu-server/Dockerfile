# 
# Todo: Convert to a Docker-compose with multiple separate services

FROM centos:centos6

MAINTAINER Charlie Drage <charlie@charliedrage.com>

#! Basic packages
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN yum install -y passwd sudo git wget openssl openssh openssh-server openssh-clients which tar

#! Create the sensu user
RUN useradd sensu
RUN echo "sensu" | passwd sensu --stdin
RUN sed -ri 's/UsePAM yes/#!UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#!UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN echo "sensu ALL=(ALL) ALL" >> /etc/sudoers.d/sensu

#! Install ruby
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN /bin/bash -l -c "curl -L get.rvm.io | bash -s stable"
RUN /bin/bash -l -c "rvm install 2.1"
RUN /bin/bash -l -c "echo 'gem: --no-ri --no-rdoc' > ~/.gemrc"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

#! Redis
RUN yum install -y redis

#! SSL key generation
RUN git clone git://github.com/joemiller/joemiller.me-intro-to-sensu.git
RUN cd joemiller.me-intro-to-sensu/; ./ssl_certs.sh clean && ./ssl_certs.sh generate

#! RabbitMQ
RUN yum install -y erlang
RUN rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
RUN rpm -Uvh http://www.rabbitmq.com/releases/rabbitmq-server/v3.1.4/rabbitmq-server-3.1.4-1.noarch.rpm
RUN mkdir /etc/rabbitmq/ssl
RUN cp /joemiller.me-intro-to-sensu/server_cert.pem /etc/rabbitmq/ssl/cert.pem
RUN cp /joemiller.me-intro-to-sensu/server_key.pem /etc/rabbitmq/ssl/key.pem
RUN cp /joemiller.me-intro-to-sensu/testca/cacert.pem /etc/rabbitmq/ssl/
ADD ./files/rabbitmq.config /etc/rabbitmq/
RUN rabbitmq-plugins enable rabbitmq_management

#! Sensu server
ADD ./files/sensu.repo /etc/yum.repos.d/
RUN yum install -y sensu
ADD ./files/config.json /etc/sensu/
ADD ./files/checks.json /etc/sensu/conf.d/
RUN mkdir -p /etc/sensu/handlers
ADD ./files/handlers /etc/sensu/handlers/
RUN mkdir -p /etc/sensu/ssl
RUN cp /joemiller.me-intro-to-sensu/client_cert.pem /etc/sensu/ssl/cert.pem
RUN cp /joemiller.me-intro-to-sensu/client_key.pem /etc/sensu/ssl/key.pem

#! Sensu dependancies / plugins
RUN /bin/bash -l -c "/opt/sensu/embedded/bin/gem install sensu-plugin pony"

#! Uchiwa sensu control panel
RUN yum install -y uchiwa
ADD ./files/uchiwa.json /etc/sensu/

#! Supervisord
RUN wget http://peak.telecommunity.com/dist/ez_setup.py;python ez_setup.py
RUN easy_install supervisor
ADD files/supervisord.conf /etc/supervisord.conf

#! Flap SSH to enable connectivity
RUN /etc/init.d/sshd start
RUN /etc/init.d/sshd stop

#! Sensu, uchiwa, RabbitMQ ports + 80/8080/443 for mail/slacker communication
EXPOSE 22 587 3000 4567 5671 15672 2003 80 8080 443

CMD ["/usr/bin/supervisord"]
