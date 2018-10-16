import os

from django.conf import settings
from django.http import HttpResponse

with open(os.path.join(settings.SCRIPTS_DIR, 'linux', 'interfaces')) as file:
    INTERFACES = file.read()

with open(os.path.join(settings.SCRIPTS_DIR, 'nameservers')) as file:
    NAMESERVERS = file.read()

deployment_script = """\
#!/bin/bash

ETHERNET_IFNAME=$(ip link show | sed -n -e "s/[0-9]: \(e[a-z0-9]*\):.*/\\1/p")

if [ -z "$ETHERNET_IFNAME" ] || [ $(echo "$ETHERNET_IFNAME" | wc -l) -ne 1 ]; then
    echo "Unsure about interface name, enter ethernet's name: "
    read ETHERNET_IFNAME
fi

echo "Using interface $ETHERNET_IFNAME"

cat > /etc/network/interfaces <<EOM
{INTERFACES}
EOM

cat > /etc/resolv.conf <<EOM
{NAMESERVERS}
EOM

echo 'done, reboot in 2 minutes'

shutdown -r +2

""".format(INTERFACES=INTERFACES, NAMESERVERS=NAMESERVERS)

def generate_script(name, vm_set, host):

    response = HttpResponse(content_type='application/force-download')
    response['Content-Disposition'] = f'attachment; filename={name}-{vm_set}-deploy.sh'

    response.write(deployment_script.format(HOST_NUM=host))

    return response

def ubuntu(request, vm_set):
    return generate_script('ubuntu', vm_set, 5*vm_set - 3)

def kali(request, vm_set):
    return generate_script('kali', vm_set, 5*vm_set - 4)
