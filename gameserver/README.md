 **Description:**

 Very simple "steam server" container checker.
 
 Shows a public join address and queries a Steam-compatible status endpoint.
 
 Runtime configuration:
 - `DISPLAY_PORT`: port shown to users in the join address
 - `QUERY_HOST`: host/IP used for the Steam query check
 - `QUERY_PORT`: port used for the Steam query check
 - `PUBLIC_HOST`: optional public host/IP shown to users; if unset the app tries to detect it
 - `PUBLIC_IP_URL`: optional JSON endpoint for public IP detection when `PUBLIC_HOST` is unset
 - `PUBLIC_IP_CACHE_MS`: optional cache TTL for public IP detection; defaults to 300000 ms
 
 **Running:**

 ```sh
 podman run -d \
    --name gameserver \
    -e DISPLAY_PORT=7777 \
    -e QUERY_HOST=ark \
    -e QUERY_PORT=27015 \
    -p 3000:3000
    ghcr.io/cdrage/gameserver
  ```
