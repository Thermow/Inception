COMPOSE = docker compose

DATA_DIR = /home/tchevall/data

.PHONY: all prepare up down restart build rebuild logs ps config pull clean fclean

all: up


prepare:
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress


up: prepare build
	$(COMPOSE) up -d

build:
	$(COMPOSE) build

down: 
	$(COMPOSE) down

restart:
	$(COMPOSE) restart

rebuild:
	$(COMPOSE) down
	$(COMPOSE) up -d --build

logs:
	$(COMPOSE) logs -f $(SERVICE)

ps:
	$(COMPOSE) ps

config:
	$(COMPOSE) config

pull:
	$(COMPOSE) pull

clean:
	$(COMPOSE) down --remove-orphans

fclean:
	$(COMPOSE) down --remove-orphans --volumes --rmi local
