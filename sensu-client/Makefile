SSLCERT ?= $(shell bash -c 'read -p "Folder containing cert.pem: " input; echo $$input')
SSLKEY ?= $(shell bash -c 'read -p "Folder containing cert.pem: " input; echo $$input')
CLIENT_ADDRESS ?= $(shell bash -c 'read -p "Client IP Address: " input; echo $$input')
CLIENT_NAME ?= $(shell bash -c 'read -p "Client Name: " input; echo $$input')
SUB ?= $(shell bash -c 'read -p "Subscriptions? (comma separated): " input; echo $$input')
RABBIT_HOST ?= $(shell bash -c 'read -p "RabbitMQ host: " input; echo $$input')
RABBIT_USERNAME ?= $(shell bash -c 'read -p "RabbitMQ username: " input; echo $$input')
RABBIT_PASS ?= $(shell bash -c 'read -p "RabbitMQ password: " input; echo $$input')

all: build
	docker run \
	  -v $(SSLCERT)/cert.pem:/etc/sensu/ssl/cert.pem \
	  -v $(SSLKEY)/key.pem:/etc/sensu/ssl/key.pem \
		-e CLIENT_NAME=$(CLIENT_NAME) \
		-e CLIENT_ADDRESS=$(CLIENT_ADDRESS) \
		-e RABBITMQ_HOST=$(RABBIT_HOST) \
		-e RABBITMQ_PORT=5671 \
		-e RABBITMQ_USER=$(RABBIT_USERNAME) \
		-e RABBITMQ_PASS=$(RABBIT_PASS)\
		-e SUB=$(SUB) \
		$(USER)/sensu-client

build:
	docker build -t $(USER)/sensu-client .
