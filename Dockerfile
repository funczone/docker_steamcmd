FROM debian:bullseye-slim
LABEL maintainer="funczone@pm.me"

ENV PUID=1000 \
    PGID=1000 \
    OVERLAY_ENABLED=0 \
    OVERLAY_LOCATION="./garrysmod/" \
    OVERLAY_REPO="https://github.com/funczone/ttt.git" \
    OVERLAY_BRANCH="" \
    STEAM_USERNAME="" \
    STEAM_PASSWORD="" \
    SERVER_APPID=4020 \
    SERVER_LOGIN_TOKEN="" \
    SERVER_PRELAUNCH_COMMAND="" \
    SERVER_LAUNCH_COMMAND="./launch.sh"

COPY rootfs /

#SHELL ["/bin/bash"]

RUN apt-get update && \
    apt-get install -y \
        curl \
        git \
        lib32gcc-s1 \
        lib32stdc++6 \
        sudo \
        tar
RUN useradd -m -u ${PUID} steam 

EXPOSE 27015

# lets cook
RUN chmod +x /etc/entry.sh
ENTRYPOINT ["/etc/entry.sh"]

