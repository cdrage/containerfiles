 **Description:**

 **Source:** https://github.com/treemo/docker-mattermost-desktop/blob/master/Dockerfile

 **Running:**

 ```sh
 podman run \
    -d \
    -e DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $HOME/.config/Mattermost:/home/user/.config/Mattermost \
    --name mattermost-desktop \
    cdrage/mattermost-desktop
 ```
