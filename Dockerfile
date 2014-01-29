FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Prevent daemon start during install
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -s /bin/true /sbin/initctl

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat

#Piwik Requirements http://piwik.org/docs/requirements/
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-client mysql-server apache2 libapache2-mod-php5 php5-mysql php-apc php5-gd php5-curl php5-memcache memcached php-pear mc varnish

#GeoIP
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y php5-geoip php5-dev libgeoip-dev

#Piwki
RUN cd /tmp && \
    wget http://builds.piwik.org/latest.zip && \
    unzip latest.zip && \
    rm -rf /var/www/ && \
    mv piwik /var/www
RUN chown -R www-data:www-data /var/www && \
    chmod -R 0755 /var/www/tmp

ADD supervisord-ssh.conf /etc/supervisor/conf.d/
ADD supervisord-piwik.conf /etc/supervisor/conf.d/

ADD mysql.ddl /
RUN mysqld_safe & mysqladmin --wait=5 ping && \
    mysql < /mysql.ddl && \
    mysqladmin shutdown

EXPOSE 22 80
