# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: pandalaf <pandalaf@student.42wolfsburg.    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/04/07 15:28:43 by pandalaf          #+#    #+#              #
#    Updated: 2023/04/24 00:35:02 by pandalaf         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Project directories
SRCDIR	:= ./src
REQS	:= $(SRCDIR)/requirements

# Container directories
NGINX		:= $(REQS)/nginx
MARIADB		:= $(REQS)/mariadb
WORDPRESS	:= $(REQS)/wordpress

# Environment variable file
ENV			:= $(SRCDIR)/.env

# Docker Compose Config
COMPOSE		:= $(SRCDIR)/docker-compose.yml

# SSL Certificate Script
SSL			:= $(NGINX)/tools/ssl.sh

# Data (Volume) Directory Script
DIRS		:= $(WORDPRESS)/tools/data-dirs.sh

# Rules
# Build and run configuration
all: directories ssl $(NGINX)/tools/pandalaf.42.fr.key $(NGINX)/tools/pandalaf.42.fr.crt
	@docker-compose -f $(COMPOSE) --env-file $(ENV) up -d

directories:
	sh $(DIRS)

$(NGINX)/tools/pandalaf.42.fr.crt: ssl

$(NGINX)/tools/pandalaf.42.fr.key: ssl

# Make a certificate pair
ssl:
	sh $(SSL)

# Build the docker configuration
build:
	@docker-compose -f $(COMPOSE) --env-file $(ENV) up -d --build

# Stop the docker configuration
down:
	@docker-compose -f $(COMPOSE) --env-file $(ENV) down

# Rebuild the docker configuration
re: down build

# Stop configuration and clean configuration-created files
clean: down
	@docker system prune -a
	@sudo rm -rf ~/data/wordpress/*
	@sudo rm -rf  ~/data/mariadb/*

# Stop configuration and clean all files
fclean:
	@docker stop $$(docker ps -qa)
	@docker system prune -a -f --volumes
	@docker network prune -f
	@docker volume prune -f
	@sudo rm -rf ~/data/wordpress/*
	@sudo rm -rf  ~/data/mariadb/*

# Rules not to be considered files
.PHONY: all directories ssl build down clean fclean re
