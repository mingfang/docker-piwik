FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN locale-gen en_US en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /etc/bash.bashrc
RUN apt-get update

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh

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
ADD mysql.ddl /mysql.ddl
RUN mysqld_safe & mysqladmin --wait=5 ping && \
    mysql < /mysql.ddl && \
    mysqladmin shutdown

COPY default /etc/nginx/sites-enabled/
# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO
