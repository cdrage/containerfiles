 **Description:**

 **Source:** https://github.com/arypurnomoz/sensu-client.docker

 This container allows you to run sensu in a container (yay) although there are some caveats.

 This is a basic container with NO checks. This is enough to get you setup and connecting to the sensu master. However, in order to add checks you'd have to pass in a folder of plugins (if you wish to pass them as a volume) or add them HERE to the Dockerfile.

 In my example, I use the docker-api and docker folder since I'll be mounting a -v /checks folder containing a few plugins. This is all optional and you may modify it to your own will.

 You'll also have to modify the checks.json file on the sensu master server in order to make sure you are using the correct plugins in the respective folders.


 **Running:**

 ```sh
 docker run \
  -v /etc/sensu/ssl/cert.pem:/etc/sensu/ssl/cert.pem \
  -v /etc/sensu/ssl/key.pem:/etc/sensu/ssl/key.pem \
  -v /etc/sensu/plugins:/etc/sensu/plugins \
  -e CLIENT_NAME=sensu-client \
  -e CLIENT_ADDRESS=10.0.0.1 \
  -e RABBITMQ_HOST=rabbitmq.local \
  -e RABBITMQ_PORT=5671 \
  -e RABBITMQ_VHOST="/sensu" \
  -e RABBITMQ_USER=sensu \
  -e RABBITMQ_PASS=sensu \
  -e SUB=metrics,check \
  cdrage/sensu-client
 ```

 or use the Makefile provided.
 ex.

 ```sh
 make all SSL=/etc/sensu/ssl IP=10.10.10.1 NAME=sensu SUB=default RABBIT_HOST=10.10.10.10 RABBIT_USERNAME=sensu RABBIT_PASS=sensu
 ```
