 **Description:**

 Original source: https://github.com/eroji/rtsp2mjpg

 I use this for my WyzeCam to convert to ffmpeg so that OctoPrint can use it

 **Running:**

 ```sh
 docker run -d \
   -p 8090:8090 \
   -v /etc/localtime:/etc/localtime:ro \
   -e RTSP_URL=rtsp://admin:foobar@192.168.1.36/live \
   -e FFMPEG_INPUT_OPTS="-nostats -use_wallclock_as_timestamps 1 -r 15 -thread_queue_size 2048 -probesize 50M -analyzeduration 100M" \
   -e FFMPEG_OUTPUT_OPTS="-vf fps=15 -video_track_timescale 90000 -c:v h264_omx" \
   --restart always \
   --name rtsp2mjpg \
   cdrage/rtsp2mjpg
 ```

 **How to use:**

 Access at http://<ip>:8090/live.jpg and /still.jpg
