# Containerfiles

```
           +--------------+
          /|             /|
         / |            / |
        *--+-----------*  |
        |  |           |  |
        |  |           |  |
        |  |           |  |
        |  +-----------+--+
        | /            | /
        |/             |/
        *--------------*
```


All the Containerfiles I use.

**Notes:**
  - Pushed to [`ghcr.io/`](https://ghcr.io) GitHub image registry, EXCEPT for `bootc-` directories.
  - `bootc` directories are special and are not pushed, they use [Fedora bootc](https://docs.fedoraproject.org/en-US/bootc/getting-started/)
  - `kasm` directories are "typical desktop software ran through VNC". Some are custom.
  - Scroll down on how to run it.
  - Containers can be started by using simple variables. 
  - You may also `git clone https://github.com/cdrage/containerfiles` and build it yourself (`podman build -t username/container .` or `docker build -t username/container`). 

**Descriptions:**
Below is a general overview (with instructions) on each Docker container I use. This is automatically generated from the comments that I have left in each `Containerfile`.