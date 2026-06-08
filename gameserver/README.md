 **Description:**

 Very simple "steam server" container checker.
 
 Checks to see if there is a game server running on port 27015 LOCALLY (same IP as actual server)
 meant to be ran alongside the steam server container.
 
 **Running:**

 ```sh
 podman run -d \
    --name gameserver \
    -p 3000:3000
    ghcr.io/cdrage/gameserver
 ```
