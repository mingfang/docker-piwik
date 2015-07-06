##docker-piwik

A quick easy setup for running Piwik inside Docker. 

##Prerequisites

Ubuntu 14.04

##Building docker-piwik

Clone the https://github.com/mingfang/docker-piwik.git to your target machine.  Change to the directory in which you cloned the git and run the build script.

    ./build

The build script will install various software including:

- latest version of piwik
- runit
- openssh
- vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common
- mysql
- php5-geoip php5 libgeoip-dev

Once the build is complete mysql will be running and ready for action

## Running docker-piwik

You have a couple different ways to start your new docker-piwik.  Either run it with the obvious run script or shell script.  Once the docker-piwik is running open a browser your_ip_address:8080 to start the installation of piwik inside your docker.

Follow the [Piwik Installation][0] intructions on how to setup your installation

MySQL user is: piwik 
No Password
Piwik DB Name: Piwik

[0]:http://piwik.org/docs/
