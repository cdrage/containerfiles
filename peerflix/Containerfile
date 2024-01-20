# **Description:**
#
# Stream from a magnet torrent
# 
# **Running:**
#
# ```sh
# docker run -it -p 8888:8888 cdrage/peerflix $MAGNET_URL
# ```
#
# Then open up VLC and use localhost:8888 to view

FROM node
RUN npm install -g peerflix

EXPOSE 8888
CMD ["--help"]
ENTRYPOINT ["peerflix"]
