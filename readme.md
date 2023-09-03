# docker_srcds
Run a source dedicated server in a docker container. This dockerfile contains some extra functionality that assists with server hosting;
- **Repo overlay:** Overlay a git repo on top of your server. Useful for larger-scale server hosting.

## Configuration
### Environment Variables
| Variable | Description | Default |
| -------- | ----------- | ------- |
| `PUID` | UID to be applied to server files. | `1001` |
| `PGID` | GID to be applied to server files. | `1001` |
| `OVERLAY_ENABLED` | Whether to overlay a git repo on top of the server. | `0` |
| `OVERLAY_LOCATION` | Where to overlay the git repo inside of the server volume. | `./garrysmod/` |
| `OVERLAY_REPO` | The repo to clone. | `https://github.com/funczone/ttt.git` |
| `OVERLAY_BRANCH` | The branch of the aforementioned repo. | `` |
| `STEAM_USERNAME` | The username to log into steamcmd with. | `` |
| `STEAM_PASSWORD` | The password to log into steamcmd with. | `` |
| `SERVER_APPID` | The ID of the app to install via SteamCMD. | `4020` |
| `SERVER_LOGIN_TOKEN` | Login token for servers. TODO: unimplimented, maybe unnecessary | `` |
| `SERVER_PRELAUNCH_COMMAND` | A command or script to run *before* the server is launched. | `` |
| `SERVER_LAUNCH_COMMAND` | A command to launch the server. | `` |

### Volumes
| Volume | Description |
| ------ | ----------- |
| `/your/config/path/:/server` | All of the server contents. |

## Notes
- Nothing is stopping you from installing another piece of server software using this. Not sure how successful it'll be, haven't tried a lot of things.
- I (mechabubba) wrote this, so your mileage may vary. First dockerfile, too!
  - insecure. lmao. dunno how docker handles secrets

## License
This is licensed under the Unlicense.

