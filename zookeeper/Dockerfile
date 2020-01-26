FROM ubuntu:18.04
MAINTAINER tonny.gieselaar@hccnet.nl

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt -y upgrade  
RUN apt install -y supervisor \
        net-tools nano apt-utils wget rsyslog

RUN apt -y install default-jdk
RUN mkdir /usr/local/kafka && cd /usr/local/kafka 
RUN wget http://apache.hippo.nl/kafka/2.4.0/kafka_2.13-2.4.0.tgz && ls && \
    tar xzf kafka_2.13-2.4.0.tgz && mv kafka_2.13-2.4.0 kafka && mv kafka/ /usr/local/

ADD config/supervisord.conf /etc/supervisor/conf.d/supervisor.conf
ADD config/zookeeper.properties /usr/local/kafka/config/zookeeper.properties
ADD scripts/init.sh /init.sh
RUN chmod +x /init.sh

RUN apt-get clean

ARG ZOOKEEPERPORT
ARG ZOOKEEPERADMINPORT

EXPOSE $ZOOKEEPERPORT $ZOOKEEPERADMINPORT
ENTRYPOINT ["/init.sh"]
CMD ["app:start"]
