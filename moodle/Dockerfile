#  **Description:**
#
#  **Source:** https://github.com/playlyfe/docker-moodle
#
#  **Setup:**
#
#  First, grab moodle and extract.
#
#  ```sh
#  wget https://github.com/moodle/moodle/archive/v3.0.0.tar.gz
#  tar -xvf v3.0.0.tar.gz
#  mkdir /var/www
#  mv moodle-3.0.0 /var/www/html
#  ```
#  
#
#  TODO: SSL stuffs
#
#  **Running:**
#
# ```sh
#  docker run -d \
#   -p 80:80 \
#   -p 443:443 \
#   -p 3306:3306 \
#   -v /var/www/html:/var/www/html \
#   --name moodle \
#   moodle
# ```
#
#  **Setup after running:**
#
#  Setup permissions once running (with the moodle configuration inside):
#
#  Head over to localhost:80 and proceed through the installation (remember to create the config.php file too during install!)
#
#  ```sh
#  MySQL username: moodleuser
#  password: moodle
#  ```
#
#  All other values default :)
#
#  chmod -R 777 /var/www/html #yolo

FROM ubuntu:trusty
MAINTAINER Peter John <peter@playlyfe.com>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
apt-get -y install curl supervisor apache2 libapache2-mod-php5 mysql-server php5-mysql pwgen php-apc php5-mcrypt php5-gd php5-curl php5-xmlrpc php5-intl

ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

RUN rm -rf /var/lib/mysql/*

ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

ADD apache_default /etc/apache2/sites-available/000-default.conf
ADD ports_default /etc/apache2/ports.conf
RUN a2enmod rewrite

ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

VOLUME ["/etc/mysql", "/var/lib/mysql" ]

RUN locale-gen en_US en_US.UTF-8
RUN dpkg-reconfigure locales

RUN adduser --disabled-password --gecos moodle moodleuser

RUN mkdir /var/www/moodledata
RUN chmod 777 /var/www/moodledata

EXPOSE 80 443 3306
CMD ["/run.sh"]
