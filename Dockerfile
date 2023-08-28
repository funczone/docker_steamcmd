FROM debian:bullseye-slim
LABEL maintainer="funczone@pm.me"

ENV STEAM_APPID=4020
ENV STEAM_FOLDER="garrysmod"
ENV UID=1001

SHELL ["/bin/bash", "-c"]

# https://developer.valvesoftware.com/wiki/SteamCMD
# https://stackoverflow.com/a/33439625
RUN echo $'\n\
deb http://deb.debian.org/debian bullseye main contrib non-free \n\
deb-src http://deb.debian.org/debian bullseye main contrib non-free \n\
deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free \n\
deb-src http://deb.debian.org/debian-security/ bullseye-security main contrib non-free \n\
deb http://deb.debian.org/debian bullseye-updates main contrib non-free \n\
deb-src http://deb.debian.org/debian bullseye-updates main contrib non-free' >> /etc/apt/sources.list
RUN dpkg --add-architecture i386

RUN apt-get update && \
    apt-get install \
        curl \
        lib32gcc-s1 \
        software-properties-common \
        steamcmd

# create steam acc, match to uid
# @todo good way of doing this?
RUN useradd -U ${UID} steam

USER steam

# a lot of this is heavily stolen from...
# https://github.com/CM2Walki/TF2/blob/master/bullseye/Dockerfile

