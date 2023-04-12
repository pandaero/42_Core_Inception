# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: pandalaf <pandalaf@student.42wolfsburg.    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/04/07 15:28:47 by pandalaf          #+#    #+#              #
#    Updated: 2023/04/07 15:36:02 by pandalaf         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.16
RUN apk update && apk upgrade && apk add --no-cache nginx
EXPOSE 443
COPY conf/nginx.conf /etc/nginx/nginx.conf
CMD ["nginx", "-g", "daemon off;"]
