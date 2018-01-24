  **Description:**

  **Source:** https://github.com/playlyfe/docker-moodle

  **Setup:**

  First, grab moodle and extract.

  ```sh
  wget https://github.com/moodle/moodle/archive/v3.0.0.tar.gz
  tar -xvf v3.0.0.tar.gz
  mkdir /var/www
  mv moodle-3.0.0 /var/www/html
  ```
  

  TODO: SSL stuffs

  **Running:**

 ```sh
  docker run -d \
   -p 80:80 \
   -p 443:443 \
   -p 3306:3306 \
   -v /var/www/html:/var/www/html \
   --name moodle \
   moodle
 ```

  **Setup after running:**

  Setup permissions once running (with the moodle configuration inside):

  Head over to localhost:80 and proceed through the installation (remember to create the config.php file too during install!)

  ```sh
  MySQL username: moodleuser
  password: moodle
  ```

  All other values default :)

  chmod -R 777 /var/www/html #yolo
