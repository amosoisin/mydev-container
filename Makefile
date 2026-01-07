UNAME := $(shell whoami)
UID := $(shell id -u $(UID))
GID := $(shell id -g $(UID))

HTTP_PROXY := $(http_proxy)
HTTPS_PROXY := $(https_proxy)
NO_PROXY := $(no_proxy)

TERM := screen-256color
LANG := C.UTF-8
HOST_DOCKER_GID := $(shell grep "^docker" /etc/group | cut -d ":" -f 3)

DATA_DIR := $(HOME)/data
CONFIG_DIR := ./config
MNT_DIR := /mnt
DOCKER_SOCK := /var/run/docker.sock
DOCKER_OVERRIDE_CONF := /etc/systemd/system/docker.service.d/override.conf

GIT_USER := $(shell git config --global user.name)
GIT_EMAIL := $(shell git config --global user.email)

ENV_LIST = \
	UNAME \
	UID \
	GID \
	HTTP_PROXY \
	HTTPS_PROXY \
	NO_PROXY \
	TERM \
	LANG \
	HOST_DOCKER_GID \
	DATA_DIR \
	CONFIG_DIR \
	MNT_DIR \
	DOCKER_SOCK \
	DOCKER_OVERRIDE_CONF \
	GIT_USER \
	GIT_EMAIL

define env_line
	echo "$(1)=$(value $(1))" >> $(2);
endef

all: up

up: prepare
	docker compose up -d

prepare: .env

.env:
	touch $@
	@$(foreach env, \
		$(ENV_LIST), \
		$(call env_line,$(env),$@))

clean-env:
	-rm -f .env
