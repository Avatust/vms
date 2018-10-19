#!/bin/bash

machine={{ machine }}
set_number={{ set_number }}

function log {
    echo $1
    post="machine_os=$machine&set_number=$set_number&message=$1"
    if (which curl > /dev/null); then
        curl -d "$post" -X POST {{ logging_url }}
    elif (which wget > /dev/null); then
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

dhclient -r

log "resetting /etc/network/interfaces"
cat > /etc/network/interfaces <<EOM
{% spaceless %}

{% if machine == "kali" %}
    {% include "scripts/linux/kali_interfaces" %}
{% else %}
    {% include "scripts/linux/ubuntu_interfaces" %}
{% endif %}

{% endspaceless %}
EOM

if [ "$(ls -A /etc/NetworkManager/system-connections)" ]; then
    log "remove existing connections"
    rm /etc/NetworkManager/system-connections/*
fi

log "insert network profile"
cat > /etc/NetworkManager/system-connections/eth0 <<EOM
{% include "scripts/linux/nm_profile" %}
EOM

chmod 600 /etc/NetworkManager/system-connections/eth0

log 'removing self'
rm $0

log 'done'
echo 'reboot in 1 minutes'
shutdown -r +1 &

# remove history too
cat /dev/null > $HOME/.bash_history
history -c
