#!/bin/bash

echo ${DHCPD_DOMAIN_NAME:="my.lan"}
echo ${DHCPD_DNS:=172.16.2.1}
echo ${DHCPD_DEFAULT_LEASE_TIME:=3600}
echo ${DHCPD_MAX_LEASE_TIME:=7200}
echo ${DHCPD_SUBNET:=172.16.2.0}
echo ${DHCPD_NETMASK:=255.255.255.0}
echo ${DHCPD_ROUTER:=172.16.2.1}
echo ${DHCPD_SUBNETMASK:=255.255.255.0}
echo ${DHCPD_DOMAIN_NAME:="my.lan"}
echo ${DHCPD_DNS:=172.16.2.1}
echo ${DHCPD_RANGE:="172.16.2.162 172.16.2.182"}
echo ${DHCPD_PXE_SERVER:=172.16.2.161}
echo ${PXE_HTTP_SERVER:=172.16.2.161}


substitute_variables_in_file(){
  prefix=$1
  file=$2
  if [[ -e $file ]]; then
    cp ${file}.template ${file}
    eval 'vars=${!'"$prefix"'@}'
    for v in $vars ; do
      eval 'value=${'$v'}'
      echo $v=$value
      sed -i "s/\${$v}/${value}/g" $file
    done
  fi
}

# prepare dhcpd.conf and launch DHCP server
substitute_variables_in_file $1 $2
