FROM alpine:3.16
RUN apk update && apk upgrade && apk add --no-cache mariadb mariadb-client
RUN mysql_install_db --basedir=/usr --user=mysql --datadir=/var/lib/mysql
COPY /tools/create.sh /usr/mariadb/
COPY /conf/my.cnf /etc/
ARG dbname=NAME
ARG dbuser=USER
ARG dbpass=PASS
RUN sh /usr/mariadb/create.sh $dbname $dbuser $dbpass
RUN mariadb < /usr/mariadb/create.sql
EXPOSE 3306
CMD ["/usr/bin/mariadbd-safe", "--skip-log-error"]
