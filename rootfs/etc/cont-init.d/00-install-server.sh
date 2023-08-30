#!/usr/bin/env bash
# install the server

cat <<'EOF' >> install.txt
@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
force_install_dir "${SRCDS_FOLDER_NAME}"
login anonymous
app_update "${}"
quit
EOF
