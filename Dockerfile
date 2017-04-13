FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN echo "export > /etc/envvars" >> /root/.bashrc && \
    echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" | tee -a /root/.bashrc /etc/bash.bashrc && \
    echo "alias tcurrent='tail /var/log/*/current -f'" | tee -a /root/.bashrc /etc/bash.bashrc

RUN apt-get update
RUN apt-get install -y locales && locale-gen en_US en_US.UTF-8

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD export > /etc/envvars && /usr/sbin/runsvdir-start

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh rsync

#Piwik Requirements http://piwik.org/docs/requirements/
RUN apt-get install -y cron nginx php-fpm php-mysql php-gd php-xml php-mbstring mysql-client mysql-server

#GeoIP
RUN apt-get install -y php-geoip libgeoip-dev

#Piwki
RUN wget http://builds.piwik.org/latest.zip && \
    unzip latest.zip && \
    mv /piwik /var/www/html && \
    rm latest.zip && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 0755 /var/www/html/piwik/tmp

#Init database
RUN mkdir -p /var/log/mysql && chown -R mysql:mysql /var/log/mysql
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld
ADD mysql.ddl /mysql.ddl
RUN mysqld_safe & mysqladmin --wait=5 ping && \
    mysql < /mysql.ddl && \
    mysqladmin shutdown

COPY default /etc/nginx/sites-enabled/
# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO
