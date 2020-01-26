FROM ubuntu:18.04
MAINTAINER tonny.gieselaar@hccnet.nl

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt -y upgrade  
RUN apt install -y supervisor \
        net-tools nano apt-utils wget rsyslog pwgen

RUN apt -y install openjdk-8-jdk git zip
RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
WORKDIR /home
RUN git clone https://github.com/yahoo/CMAK 

ADD config/supervisord.conf /etc/supervisor/conf.d/supervisor.conf
ADD config/application.conf /home/
ADD scripts/init.sh /init.sh
RUN chmod +x /init.sh

RUN apt-get clean

ARG KAFKAMANAGERPORT

EXPOSE $KAFKAMANAGERPORT
ENTRYPOINT ["/init.sh"]
CMD ["app:start"]
