# command

edit config files under /files/ then build

```bash
docker build -t sensu/sensu .
docker run --name sensu -d -p 10022:22 -p 3000:3000 -p 4567:4567 -p 5671:5671 -p 15672:15672 sensu/sensu
```

# notes
after deployment, install plugins:
  ssh sensu@localhost -p 1022
  /opt/embedded/sensu/gem install pony

view /var/log/sensu/sensu-server

