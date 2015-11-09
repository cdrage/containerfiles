# docker run -it -p 8888:8888 wikus/peerflix "magnet shit:"

FROM node
RUN npm install -g peerflix

EXPOSE 8888
CMD ["--help"]
ENTRYPOINT ["peerflix"]
