FROM debian:bullseye-slim
LABEL maintainer="funczone@pm.me"

ENV PUID=1001
ENV PGID=1001
ENV OVERLAY_ENABLED=0
ENV OVERLAY_LOCATION="garrysmod/"
ENV OVERLAY_REPO="https://github.com/funczone/ttt.git"
ENV SRCDS_APPID=4020
ENV SRCDS_FOLDER_NAME="garrysmod"
ENV SRCDS_START="./${SRCDS_FOLDER_NAME}/launch.sh"
# ...for now. will probably make some "better" env var start params later.

COPY rootfs /

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

EXPOSE 27015

# lets cook
ENTRYPOINT ["/init"]
