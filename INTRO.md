# Dockerfiles

```
                  ##         .
            ## ## ##        ==
         ## ## ## ## ##    ===
     /"""""""""""""""""\___/ ===
~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~
     \______ o           __/
       \    \         __/
        \____\_______/
```

All the Dockerfiles I use.

**Notes:**
  - Each container is a [12 factor application](https://12factor.net). Every container is meant to have maximum portability and replicability. 
  - Containers can be started by using simple variables. 
  - Persistency. When passing in a volume, the data will be PERSISTENT. Thus if you `docker rm` and re-create the container, data is neither lost no ovewritten.
  - Each container is automatically built and pushed to https://hub.docker.com/r/cdrage/ on each commit.
  - You may also `git clone https://github.com/cdrage/dockerfiles` and build it yourself (`docker build -t username/container .`).

**Descriptions:**

Below is a general overview (with instructions) on each Docker container I use. This is automatically generated from the comments that I have left in each `Dockerfile`.
