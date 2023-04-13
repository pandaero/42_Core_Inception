ARG dbname=NAME
ARG dbuser=USER
ARG dbpass=PASS
FROM alpine:3.16
RUN apk update && apk upgrade && apk add --no-cache mariadb mariadb-client
RUN /etc/init.d/mariadb setup
COPY /tools/sql.sh /usr/mariadb/
COPY /conf/my.cnf /etc/
RUN /usr/mariadb/sql.sh $dbname $dbuser $dbpass
EXPOSE 3036
CMD ["/usr/bin/mariadbd-safe"]
