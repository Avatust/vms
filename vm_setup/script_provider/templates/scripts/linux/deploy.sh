#!/bin/bash

machine={{ machine }}
set_number={{ set_number }}

function log {
    echo $1
    post="machine_os=$machine&set_number=$set_number&message=$1"
    if (which curl); then
        curl -d "$post" -X POST {{ logging_url }}
    elif (which wget); then
        wget --quiet --post-data "$post" {{ logging_url }}
    fi
}

case $machine in
    kali)
            HOST_NUM=$(( 5*$set_number - 4 ))
            ;;
    ubuntu)
            HOST_NUM=$(( 5*$set_number - 3 ))
            ;;
    *)
            log "bad machine"
            exit 1
            ;;
esac

log "beginning config, host $HOST_NUM"

ETHERNET_IFNAME=$(ip link show | sed -n -e "s/[0-9]: \(e[a-z0-9]*\):.*/\\1/p")

if [ -z "$ETHERNET_IFNAME" ] || [ $(echo "$ETHERNET_IFNAME" | wc -l) -ne 1 ]; then
    log "Unsure about interface name"
    echo "enter ethernet's name: "
    read ETHERNET_IFNAME
fi

log "Using interface $ETHERNET_IFNAME"

cat > /etc/network/interfaces <<EOM
{% include "scripts/linux/interfaces" %}
EOM

cat > /etc/resolv.conf <<EOM
{% include "scripts/nameservers" %}
EOM

log 'removing self'
rm $0

log 'done'
echo 'reboot in 2 minutes'

shutdown -r +2
