# Docker Moodle LMS
This is the Docker Image for The Moodle LMS
Using this makes it really easy to setup a moodle installation without setting up the apache server and MySQL databases all this is done through docker.

To get the latest version of moodle head over to [MOODLE_29_STABLE](https://github.com/moodle/moodle/tree/MOODLE_29_STABLE) and download the zip file. Then unzip this file to a folder and replace all `/path/to/moodle` with the location to this moodle source code folder.

Download or clone this repo and then within its folder run this command to build the docker image
### Step 1: Build the image
```bash
docker build --tag="playlyfe/moodle:latest" .
```
This will build the latest playlyfe/moodle docker image

### Step 2: Run the Container
```bash
docker run -d --name moodle -p 3000:3000 -p 3306:3306 -v /path/to/moodle:/var/www/html playlyfe/moodle
```
The apache server listens on port 3000 so we bind that to the port 3000 on the host machine. And the mysql database listens on port 3306 and we bind that to the host port 3306.
This will start a moodle instance with the moodle absolute source path which you provided as `/path/to/moodle`.
Once its setup you can try  
`docker ps` to see if your moodle container is up  
`docker logs moodle` to see if whether moodle has started.

### Step 3: Configure Read/Write/Execute permissions to your moodle folder
Set permissions for all files in your moodle directory using
```bash
chmod -R 755 /path/to/moodle
```
This will then allow the moodle installation script to run and configure
your files accordingly. After this you can change your permissions back
(TODO:!Need to change this)

### Step 4: Installation
Then headover to http://localhost:3000 and there you should see the moodle installation page. The Moodle installation might ask you for some details regarding your server and database. The details for the configuration is given below

**Moodle**
```
moodle_path: /var/www/html
moodle_data_path: /var/www/moodledata
```

**Apache Server**
```
host: localhost:3000
```

**MySQL Database**
```
host: localhost
port: 3306
user: moodleuser
password: moodle
```

**Container**
```sh
docker exec -it moodle bash # To enter the container so that you can access the database through the `mysql` command
docker start moodle # To start your moodle instance
docker stop moodle # To stop your moodle instance
docker rm moodle # To delete your moodle instance container. Warning this will delete all your data also.
```

At the end of the installation this is how your `config.php` should look like, You can ignore the open shift stuff
```php
<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mysqli';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'localhost';
$CFG->dbname    = 'moodle';
$CFG->dbuser    = 'moodleuser';
$CFG->dbpass    = 'moodle';
// For openshift
// $CFG->dbhost    = $_ENV['OPENSHIFT_MYSQL_DB_HOST'];
// $CFG->dbname    = $_ENV['OPENSHIFT_APP_NAME'];
// $CFG->dbuser    = $_ENV['OPENSHIFT_MYSQL_DB_USERNAME'];
// $CFG->dbpass    = $_ENV['OPENSHIFT_MYSQL_DB_PASSWORD'];
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => 3306,
  'dbsocket' => '',
);

// $CFG->dboptions = array (
//   'dbpersist' => 0,
//   'dbport' => $_ENV['OPENSHIFT_MYSQL_DB_PORT'],
//   'dbsocket' => '',
// );

$CFG->wwwroot   = 'http://localhost:3000';
$CFG->dataroot  = '/var/www/moodledata';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 0777;

require_once(dirname(__FILE__) . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!

```
