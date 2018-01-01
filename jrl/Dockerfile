# **Description:**
#
# Encrypted journal (for writing your life entries!, not logs!)
#
# In my case, I enter a timestamp each time I open the file and switch to vim insert mode.
# 
# Pass in your encrypted txt file and type in your password.
# It'll then open it up in vim for you to edit and type up your
# latest entry.
#
# Remember, this is aes-256-cbc, so it's like hammering a nail
# with a screwdriver: 
# http://stackoverflow.com/questions/16056135/how-to-use-openssl-to-encrypt-decrypt-files
#
# Public / Private key would be better, but hell, this is just a text file.
#
# **First, encrypt a text file:**
#
# openssl aes-256-cbc -a -md md5 -salt -in foobar.txt -out foobar.enc
# 
# Now run it!
#
# **Running:**
#
# ```sh
# docker run -it --rm \
#   -v ~/txt.enc:/tmp/txt.enc \
#   -v /etc/localtime:/etc/localtime:ro \
#   cdrage/jrl
# ```
# 
# This will ask for your password, decrypt it to a tmp folder and open it in vim.
# Once you :wq the file, it'll save.

FROM debian:stable

RUN apt-get update && apt-get install openssl vim locales -y

RUN locale-gen en_US.UTF-8 ja_JP.UTF-8

RUN touch /etc/default/locale && \
    echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale && \
    echo "LANG=en_US.UTF-8" >> /etc/default/locale && \
    echo "set encoding=utf-8" >> ~/.vimrc


ADD journal.sh journal.sh

CMD ["./journal.sh"]
