# Encrypted journal (for writing your life entries!, not logs!)
# 
# Pass in your encrypted txt file and type in your password.
# It'll then open it up in vim for you to edit and type up your
# latest entry.
#
# Remember, this is aes-256-cbc, so it's like hammering a nail
# with a screwdriver: 
# http://stackoverflow.com/questions/16056135/how-to-use-openssl-to-encrypt-decrypt-files
#
# Public / Private key would be better, but hell, this is just a txt file.
# 
# Now run it!
#
# docker run -it --rm -v /bin/txt.aes:/txt.aes jrl

FROM debian:jessie

RUN apt-get update && apt-get install openssl vim -y

ADD journal.sh journal.sh

CMD ["./journal.sh"]

