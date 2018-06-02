FROM ubuntu:xenial

MAINTAINER Vagabondan <strannix.vagabondan@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /app
RUN apt-get -q -y update \
 && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install apt-utils \
 && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" dist-upgrade \
 && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install isc-dhcp-server man \
 && apt-get -q -y -o "DPkg::Options::=--force-confold" -o "DPkg::Options::=--force-confdef" install wget git \
 && apt-get -q -y autoremove \
 && apt-get -q -y clean \
 && rm -rf /var/lib/apt/lists/*

# COPY util/dumb-init_1.2.1_amd64 /usr/bin/dumb-init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 \
 && chmod +x /usr/local/bin/dumb-init \
 && git clone https://github.com/vagabondan/docker-dhcpd.git .
# COPY util/entrypoint.sh /entrypoint.sh
VOLUME ["/data"]
EXPOSE 69/udp
ENTRYPOINT ["/app/util/entrypoint.sh"]
