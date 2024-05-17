 **Description:**

 Used to generate aviation checklists. Based on the work by https://github.com/freerobby/aviation-checklist
 with the patch https://github.com/freerobby/aviation-checklist/pull/2

 **Running:**

 ```sh
 podman run -d \
   -p 8080:80 \
   --name aviation-checklist \
   cdrage/aviation-checklist
 ```
