 **Description:**

 **Source:** https://bitbucket.org/xcgd-team/seafile-client

 After a lot of frustation, I've taken the solution from: https://bitbucket.org/xcgd-team/seafile-client
 and fiddled around with it for my needs.

 **Running:**

 ```sh
 mkdir ~/seafile

 docker run \
 -d \
 --name seafile-client \
 -v ~/seafile:/data \
 --restart=always \
 cdrage/seafile-client
 ```

 The seaf-cli is accessible via:

 ```sh
 docker exec seafile-client /usr/bin/seaf-cli
 ```

 In order to "add" a folder, you must sync it via the "sync" command line action

 ```sh
 # change "foobar" to your folder
 # mkdir must be created first in order to create proper permissions
 # Due to issues with python + passing in a password, you must
 # exec into the container to add your initial folder.
 mkdir -p ~/seafile/foobar
 docker exec -it seafile-client bash
 /usr/bin/seaf-cli sync -l YOUR_LIBRARY_ID -s YOUR_SEAFILE_SERVER -d /data/foobar -u YOUR_EMAIL -p YOUR_PASSWORD
 ```

 To check the status:

 ```sh
 docker exec -it seafile-client /usr/bin/seaf-cli status
 ```
