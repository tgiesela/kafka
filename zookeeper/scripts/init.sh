#!/bin/bash

#set -e

info () {
    echo "[INFO] $@"
}

DOCKER_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d':' -f 2 | awk {'print $1'})
DOCKER_MASK=$(/sbin/ifconfig eth0 | grep 'Mask:' | cut -d: -f 4)
DOCKER_DOMAIN_NAME=$(dnsdomainname)
ZOOKEEPERPORT=${ZOOKEEPER_PORT:-2181}
ZOOKEEPERADMINPORT=${ZOOKEEPERADMIN_PORT:-8080}
ROOT_PASSWORD=${ROOT_PASSWORD:-$(pwgen -cny -c -n -1 12)}

appSetup () {

    info "Executing appSetup"
    
    echo "root:${ROOT_PASSWORD}" | chpasswd
    sed -i "s/<<ZOOKEEPERPORT>>/${ZOOKEEPERPORT}/g" /usr/local/kafka/config/zookeeper.properties
    sed -i "s/<<ZOOKEEPERADMINPORT>>/${ZOOKEEPERADMINPORT}/g" /usr/local/kafka/config/zookeeper.properties


    touch /config/.kafkaalreadysetup

}

appStart () {
    info "Executing appStart"
    [ -f /config/.kafkaalreadysetup ] && echo "Skipping setup..." || appSetup

    # Start the services
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


