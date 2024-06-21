# qBittorrent and OpenVPN
#
# Version 1.8

FROM ubuntu:24.04
MAINTAINER MarkusMcNugen

VOLUME /downloads
VOLUME /config

ENV DEBIAN_FRONTEND noninteractive

RUN usermod -u 99 nobody

# Update packages and install software
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils openssl && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:qbittorrent-team/qbittorrent-stable && \
    apt-get update && \
    apt-get install -y iputils-ping jq traceroute qbittorrent-nox openvpn curl moreutils net-tools dos2unix kmod iptables ipcalc unrar binutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# this file does not exist in all architectures, it wasn't found in arm/v7
# this is a hack... find/ls/stat always return non-zero if the file isn't found; and non-zero causes docker builds to fail
# so this swallows the non-zero return code, which requires a check to see if the file was found or not, hack away with the length of the string
RUN FILE=$(find /usr/lib/x86_64-linux-gnu -name libQt5Core.so.5) || true && size=${#FILE} && if [ "$size" -gt "0" ] ; then strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5 ; fi

# Add configuration and scripts
ADD openvpn/ /etc/openvpn/
ADD qbittorrent/ /etc/qbittorrent/

RUN chmod +x /etc/qbittorrent/*.sh /etc/qbittorrent/*.init /etc/openvpn/*.sh

# Expose ports and run
EXPOSE 8080
EXPOSE 8999
EXPOSE 8999/udp
CMD ["/bin/bash", "/etc/openvpn/start.sh"]
