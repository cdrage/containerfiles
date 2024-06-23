 **Description:**
 My Hugo file for hosting my personal wiki / journal / etc.

 **Running:**
 podman run -d \
   -p 1313:1313 \
   --name hugo \
   -v /path/to/hugo:/src \
   -v /path/to/hugo/public:/dest \
   ghcr.io/cdrage/hugo
