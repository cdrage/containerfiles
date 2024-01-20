SSL ?= /etc/sensu/ssl
IP ?= 1.1.1.1
NAME ?= sensu
SUB ?= default
RABBIT_HOST ?= 1.1.1.1
RABBIT_PORT ?= 5671
RABBIT_USERNAME ?= sensu
RABBIT_PASS ?= sensu

all:
	podman run \
	  -v $(SSL)/cert.pem:/etc/sensu/ssl/cert.pem \
	  -v $(SSL)/key.pem:/etc/sensu/ssl/key.pem \
		-e CLIENT_NAME=$(NAME) \
		-e IP=$(IP) \
		-e RABBITMQ_HOST=$(RABBIT_HOST) \
		-e RABBITMQ_PORT=$(RABBIT_PORT) \
		-e RABBITMQ_USER=$(RABBIT_USERNAME) \
		-e RABBITMQ_PASS=$(RABBIT_PASS)\
		-e SUB=$(SUB) \
		--privileged \
		--name sensu-client \
		--restart=always \
		-d \
		$(USER)/sensu-client

build:
	docker build -t $(USER)/sensu-client .
