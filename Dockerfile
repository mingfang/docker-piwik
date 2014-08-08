FROM ubuntu:14.04
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

#Runit
RUN apt-get install -y runit 
CMD /usr/sbin/runsvdir-start

#SSHD
RUN apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    echo 'root:root' |chpasswd
RUN sed -i "s/session.*required.*pam_loginuid.so/#session    required     pam_loginuid.so/" /etc/pam.d/sshd
RUN sed -i "s/PermitRootLogin without-password/#PermitRootLogin without-password/" /etc/ssh/sshd_config

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common
 
#Piwik Requirements http://piwik.org/docs/requirements/
RUN apt-get -y install mysql-client mysql-server apache2 libapache2-mod-php5 php5-mysql php-apc php5-gd

#GeoIP
RUN apt-get install -y php5-geoip php5 libgeoip-dev

#Piwki
RUN rm -fr /var/www/html && git clone --depth=1 https://github.com/piwik/piwik.git  /var/www/

RUN mv /var/www/piwik /var/www/html
    
RUN chown -R www-data:www-data /var/www && \
    chmod -R 0755 /var/www/html/tmp

#Add runit services
ADD sv /etc/service 

#Init database
RUN rm /etc/mysql/conf.d/mysqld_safe_syslog.cnf
ADD mysql.ddl /mysql.ddl
RUN mysqld_safe & mysqladmin --wait=5 ping && \
    mysql < /mysql.ddl && \
    mysqladmin shutdown
