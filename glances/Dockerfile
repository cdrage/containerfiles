# Run glances in a container
# SOURCE: https://github.com/nicolargo/glances
#
# docker run --rm -it \
#	--pid host \
#	--ipc host \
#	--net host \
#	--name glances \
#	charliedrage/glances

FROM debian:sid

RUN apt-get update && apt-get install -y glances

ENTRYPOINT [ "glances" ]
