FROM alpine:3.16
RUN apk update && apk upgrade && apk add --no-cache mariadb mariadb-client mariadb-server-utils
ADD run.sh /scripts/
RUN mkdir /docker-entrypoint-initdb.d && mkdir /scripts/pre-exec.d && mkdir /scripts/pre-init.d && chmod -R 755 /scripts
EXPOSE 3306
VOLUME ["/var/lib/mysql"]
ENTRYPOINT ["/scripts/run.sh"]
