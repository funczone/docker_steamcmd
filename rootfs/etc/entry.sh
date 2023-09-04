#!/bin/bash
export GIT_TERMINAL_PROMPT=0 # for git clone. @TODO potentially unnecessary

echo_info()  { echo -e "\e[1;32m[INFO]\e[0m  $*"; }
echo_debug() { [ $DEBUG ] && echo -e "\e[1;35m[DEBUG]\e[0m $*"; }
echo_err()   { echo -e "\e[1;31m[ERROR]\e[0m $*"; }

set -e;
handle_err() {
    echo_err "Error occured ($(caller)).";
    rm /server/update_server.txt;
}
trap handle_err ERR;

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
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -;
chown -R "${PUID}:${PGID}" "./";

# if a username is provided, assume a username password pair has been provided.
USER=$([ "$STEAM_USERNAME" ] && echo "$STEAM_USERNAME $STEAM_PASSWORD" || echo "anonymous");
echo_debug "login: ${USER}";

if [[ ! -e "/server/update_server.txt" ]] || [[ $FORCE_INSTALL ]]; then
    # if we're really forcing a reinstall, delete everything.
    if [[ -e "/server/update_server.txt" ]]; then
        rm -r "/server/";
    fi
    chown -R "${PUID}:${PGID}" "/server";
    echo_info "Installing server..."

    # create install script
    cat << EOF > /server/update_server.txt
@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
force_install_dir /server/
login ${USER}
app_update ${SERVER_APPID} validate
quit
EOF
    sudo -iu steam eval "./steamcmd.sh +runscript /server/update_server.txt";

    # overlay git repo
    if [ "$OVERLAY_ENABLED" ]; then
        # @TODO this could be more efficient probably
        echo_info "Overlaying repo..."

        mkdir "/server/${OVERLAY_LOCATION}/.gittmp" && pushd "$_" || exit;
        git clone "${OVERLAY_REPO}" ".";
        if [ "$OVERLAY_BRANCH" ]; then
            git checkout "$OVERLAY_BRANCH";
        fi
        \cp -rf ./* ../;
        cd .. && rm -r ./.gittmp;

        popd;
    fi

    chown -R ${PUID}:${PGID} ./;
fi
cd "/server";

# do pre-launch stuff
if [[ -n "$SERVER_PRELAUNCH_COMMAND" ]]; then
    echo_info "Running prelaunch tasks...";
    eval "$SERVER_PRELAUNCH_COMMAND";
fi

# launch
if [[ ! $DONT_LAUNCH ]] && [[ -n "$SERVER_LAUNCH_COMMAND" ]]; then
    echo_info "Launching...";
    echo_debug "sudo -iu steam eval \"echo \$PWD; $SERVER_LAUNCH_COMMAND '$@'\"";
    sudo -u steam eval "$SERVER_LAUNCH_COMMAND '$@'";
fi

