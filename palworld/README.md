 **Description:**

 Originally from: https://github.com/thijsvanloef/palworld-server-docker
 
 Used to run the "palworld" game
 
 **Running:**

 ```sh
 podman run -d \
    --name palworld\
    -p 8211:8211 \
    -p 8221:8221 \
    -p 27015:27015 \
    -v <palworld-folder>:/palworld/ \
    -e PLAYERS=16 \
    -e PORT=8211 \
    -e MULTITHREADING=true \
    -e PUBLIC_IP="" \
    -e PUBLIC_PORT="" \
    -e COMMUNITY=true \
    -e SERVER_NAME="My Palworld Server" \
    -e SERVER_PASSWORD="supersecret" \
    -e ADMIN_PASSWORD="supersecret" \
    -e UPDATE_ON_BOOT=true \
    --restart unless-stopped \
    thijsvanloef/palworld-server-docker
 ```
