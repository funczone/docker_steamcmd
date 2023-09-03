#!/bin/bash
export GIT_TERMINAL_PROMPT=0 # for git clone. @TODO potentially unnecessary

# handle params passed in from entrypoint
while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do
    case $1 in
        -f | --force-install)
            FORCE_INSTALL=1
            ;;
        -d | --dont-launch)
            DONT_LAUNCH=1
            ;;
    esac;
    shift;
done;
if [[ $1 == "--" ]]; then shift; fi

# install the server
cd /home/steam || exit;
wget -q "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -;

# if a username is provided, assume a username password pair has been provided.
USER=$([ "$STEAM_USERNAME" ] && echo "$STEAM_USERNAME $STEAM_PASSWORD" || echo "anonymous");

if [[ ! -e "/server/update_server.txt" ]] || [[ $FORCE_INSTALL ]]; then
    # if we're really forcing a reinstall, delete everything.
    if [[ -e "/server/update_server.txt" ]]; then
        rm -r "/server/";
    fi

    # create install script
    cat << EOF > /server/update_server.txt
@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
force_install_dir /server/
login ${USER}
app_update ${SRCDS_APPID} validate
quit
EOF
    cd /server || exit;
    ./steamcmd.sh +runscript ./update_server.txt;

    # overlay git repo
    if [ "$OVERLAY_ENABLED" ]; then
        # @TODO this could be more efficient probably
        mkdir "/server/${OVERLAY_LOCATION}/.gittmp" && pushd "$_" || exit;
        git clone "${OVERLAY_REPO}" ".";
        if [ "$OVERLAY_BRANCH" ]; then
            git checkout "$OVERLAY_BRANCH";
        fi
        \cp -rf ./* ../;
        cd .. && rm -r ./.gittmp;

        popd;
    fi
fi

cd /server;
chown -R ${PUID}:${PGID} ./;

# do pre-launch stuff
if [[ -n "$SERVER_PRELAUNCH_COMMAND" ]]; then
    eval "$SERVER_PRELAUNCH_COMMAND";
fi

# launch
if [[ $DONT_LAUNCH ]] || [[ -n "$SERVER_LAUNCH_COMMAND" ]]; then
    sudo -iu steam eval "$SERVER_LAUNCH_COMMAND";
fi

