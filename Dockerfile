FROM ubuntu:xenial

MAINTAINER Vagabondan <strannix.vagabondan@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /app
RUN apt-get -q -y update \
 && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install apt-utils \
 && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" dist-upgrade \
 && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install isc-dhcp-server man \
 && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install wget git \
 && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install tftpd-hpa \
 && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install apache2
 && apt-get -q -y autoremove \
 && apt-get -q -y clean \
 && rm -rf /var/lib/apt/lists/*
 

# using dumb-init instead of original init to orchestrate children
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 \
 && chmod +x /usr/local/bin/dumb-init \
 && git clone https://github.com/vagabondan/docker-dhcpd.git .

# centos7
# RUN wget -O /var/lib/tftpboot/centos7/initrd.img http://mirror.centos.org/centos/7/os/x86_64/images/pxeboot/initrd.img \
#  && wget -O /var/lib/tftpboot/centos7/vmlinuz http://mirror.centos.org/centos/7/os/x86_64/images/pxeboot/vmlinuz

# For debug. Delete in release
COPY . .


VOLUME ["/data"]
ENTRYPOINT ["/app/util/entrypoint.sh"]
