# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: pandalaf <pandalaf@student.42wolfsburg.    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/04/07 15:28:43 by pandalaf          #+#    #+#              #
#    Updated: 2023/04/07 16:59:19 by pandalaf         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Project directories
ROOT	:= /home/inception
REQS	:= $(ROOT)/src/requirements

# Container directories
NGINX		:= $(REQS)/nginx
MARIADB		:= $(REQS)/mariadb
WORDPRESS	:= $(REQS)/wordpress

# Rules
# Build all container images
all: nginx mariadb wordpress

# Build the nginx container image
nginx: $(NGINX)/Dockerfile
	cd $(NGINX) && docker build -t $@ .

# Build the mariadb container image
mariadb: $(MARIADB)/Dockerfile
	cd $(MARIADB) && docker build -t $@ .

# Build the wordpress container image
wordpress: $(WORDPRESS)/Dockerfile
	cd $(WORDPRESS) && docker build -t $@ .

# Remove the containers and their images
clean:
	docker stop nginx mariadb wordpress
	docker rm nginx mariadb wordpress
	docker rmi nginx mariadb wordpress

# Rules not to be mistaken for files
.PHONY: all nginx mariadb wordpress
