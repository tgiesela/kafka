#!/bin/bash

#set -e

info () {
    echo "[INFO] $@"
}

DOCKER_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d':' -f 2 | awk {'print $1'})
DOCKER_MASK=$(/sbin/ifconfig eth0 | grep 'Mask:' | cut -d: -f 4)
DOCKER_DOMAIN_NAME=$(dnsdomainname)
ZOOKEEPERPORT=${ZOOKEEPER_PORT:-2181}
ZOOKEEPERHOST=${ZOOKEEPER_HOST:-localhost}
ROOT_PASSWORD=${ROOT_PASSWORD:-$(pwgen -cny -c -n -1 12)}

appSetup () {

    info "Executing appSetup"

    cd /home/CMAK

    ./sbt clean dist
    unzip -o target/universal/kafka-manager*

    cd kafka-manager*
    cp -r bin/* /bin/
    cp -r lib/* /lib/
    mv /home/application.conf /config
#    cp -r conf/* /config/

    echo "root:${ROOT_PASSWORD}" | chpasswd
    sed -i "s/<<ZOOKEEPERPORT>>/${ZOOKEEPERPORT}/g" /config/application.conf
    sed -i "s/<<ZOOKEEPERHOST>>/${ZOOKEEPERHOST}/g" /config/application.conf

    touch /config/.kafkamanageralreadysetup

}

appStart () {
    info "Executing appStart"
    [ -f /config/.kafkamanageralreadysetup ] && echo "Skipping setup..." || appSetup

    # Start the services
    rm /RUNNING_PID
    /usr/bin/supervisord
}

appHelp () {
        echo "Available options:"
        echo " app:start          - Starts all services needed for tvheadend"
        echo " app:setup          - First time setup."
        echo " app:help           - Displays the help"
        echo " [command]          - Execute the specified linux command eg. /bin/bash."
}

case "$1" in
        app:start)
                appStart
                ;;
        app:setup)
                appSetup
                ;;
        app:help)
                appHelp
                ;;
        *)
                if [ -x $1 ]; then
                        $1
                else
                        prog=$(which $1)
                        if [ -n "${prog}" ] ; then
                                shift 1
                                $prog $@
                        else
                                appHelp
                        fi
                fi
                ;;
esac

exit 0


