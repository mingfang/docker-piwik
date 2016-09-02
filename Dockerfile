FROM ubuntu:14.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN locale-gen en_US en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc
RUN apt-get update

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute

#Piwik Requirements http://piwik.org/docs/requirements/
RUN apt-get -y install mysql-client mysql-server apache2 libapache2-mod-php5 php5-mysql php-apc php5-gd

#GeoIP
RUN apt-get install -y php5-geoip php5 libgeoip-dev

#Piwki
RUN wget http://builds.piwik.org/latest.zip && \
    unzip latest.zip && \
    rm latest.zip
RUN rm -rf /var/www/html && \
    mv piwik /var/www/html
RUN chown -R www-data:www-data /var/www && \
    chmod -R 0755 /var/www/html/tmp

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO

#Init database
RUN rm /etc/mysql/conf.d/mysqld_safe_syslog.cnf
ADD mysql.ddl /mysql.ddl
RUN mysqld_safe & mysqladmin --wait=5 ping && \
    mysql < /mysql.ddl && \
    mysqladmin shutdown
