 **Description:**

 A terminal interface for Mattermost via the client Matterhorn
 https://github.com/matterhorn-chat/matterhorn

 To run, simply supply a username, hostname and (additionally) a port number.
 For example:
 
 **Running:**

 ```sh
 docker run -it --rm \
  -e MM_USER=foobar@domain.com \
  -e MM_PASS=foobar \
  -e MM_HOST=gitlab.mattermost.com \
  -e MM_PORT=443 \
  --name matterhorn \
  cdrage/matterhorn
 ```
