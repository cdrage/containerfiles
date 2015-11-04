SSL ?= $(shell bash -c 'read -p "SSL cert folder: " input; echo $$input')
CLIENT_ADDRESS ?= $(shell bash -c 'read -p "Client IP Address: " input; echo $$input')
CLIENT_NAME ?= $(shell bash -c 'read -p "Client Name: " input; echo $$input')
SUB ?= $(shell bash -c 'read -p "Subscriptions? (comma separated): " input; echo $$input')
RABBIT_HOST ?= $(shell bash -c 'read -p "RabbitMQ host: " input; echo $$input')
RABBIT_USERNAME ?= $(shell bash -c 'read -p "RabbitMQ username: " input; echo $$input')
RABBIT_PASS ?= $(shell bash -c 'read -p "RabbitMQ password: " input; echo $$input')

all:
	docker run -v $(SSL):/etc/sensu/ssl \
  -e CLIENT_ADDRESS=$(CLIENT_ADDRESS) \
  -e CLIENT_NAME=$(CLIENT_NAME) \
  -e RABBITMQ_HOST=$(RABBIT_HOST) \
  -e RABBITMQ_PORT=5671 \
  -e RABBITMQ_USER=$(RABBIT_USERNAME) \
  -e RABBITMQ_PASS=$(RABBIT_PASS)\
  -e SUB=$(SUB) \
	sensu-client

build:
	docker build -t sensu-client .
