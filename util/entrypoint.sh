#!/bin/bash

set -e

/app/util/instantiate_templates.sh DHCP_ /dhcp/template.dhcpd.conf /dhcp/dhcpd.conf

init="/usr/local/bin/dumb-init"

# Single argument to command line is interface name
if [ $# -eq 1 -a -n "$1" ]; then
    # skip wait-for-interface behavior if found in path
    if ! which "$1" >/dev/null; then
        # loop until interface is found, or we give up
        NEXT_WAIT_TIME=1
        until [ -e "/sys/class/net/$1" ] || [ $NEXT_WAIT_TIME -eq 4 ]; do
            sleep $(( NEXT_WAIT_TIME++ ))
            echo "Waiting for interface '$1' to become available... ${NEXT_WAIT_TIME}"
        done
        if [ -e "/sys/class/net/$1" ]; then
            IFACE="$1"
        fi
    fi
fi

# No arguments mean all interfaces
if [ -z "$1" ]; then
    IFACE=" "
fi

if [ -n "$IFACE" ]; then
    # Run dhcpd for specified interface or all interfaces

    dhcp_dir="/dhcp"
    if [ ! -d "$dhcp_dir" ]; then
        echo "Please ensure '$dhcp_dir' folder is available."
        echo 'If you just want to keep your configuration in "dhcp/", add -v "$(pwd)/dhcp:/dhcp" to the docker run command line.'
        exit 1
    fi

    dhcpd_conf="$dhcp_dir/dhcpd.conf"
    if [ ! -r "$dhcpd_conf" ]; then
        echo "Please ensure '$dhcpd_conf' exists and is readable."
        echo "Run the container with arguments 'man dhcpd.conf' if you need help with creating the configuration."
        exit 1
    fi

    uid=$(stat -c%u "$dhcp_dir")
    gid=$(stat -c%g "$dhcp_dir")
    if [ $gid -ne 0 ]; then
        groupmod -g $gid dhcpd
    fi
    if [ $uid -ne 0 ]; then
        usermod -u $uid dhcpd
    fi

    [ -e "$dhcp_dir/dhcpd.leases" ] || touch "$dhcp_dir/dhcpd.leases"
    chown dhcpd:dhcpd "$dhcp_dir/dhcpd.leases"
    if [ -e "$dhcp_dir/dhcpd.leases~" ]; then
        chown dhcpd:dhcpd "$dhcp_dir/dhcpd.leases~"
    fi

    container_id=$(grep docker /proc/self/cgroup | sort -n | head -n 1 | cut -d: -f3 | cut -d/ -f3)
    if perl -e '($id,$name)=@ARGV;$short=substr $id,0,length $name;exit 1 if $name ne $short;exit 0' $container_id $HOSTNAME; then
        echo "You must add the 'docker run' option '--net=host' if you want to provide DHCP service to the host network."
    fi

    /usr/sbin/in.tftpd --listen --address :69 --secure /tftp
    /usr/sbin/apache2ctl start
    exec $init -- /usr/sbin/dhcpd -4 -f -d --no-pid -cf "$dhcp_dir/dhcpd.conf" -lf "$dhcp_dir/dhcpd.leases" $IFACE
else
    # Run another binary
    exec $init -- "$@"
fi
