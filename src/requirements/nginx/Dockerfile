FROM alpine:3.16
RUN apk update && apk upgrade && apk add --no-cache nginx
EXPOSE 443
COPY conf /etc/nginx/nginx.conf
CMD ["nginx", "-g", "daemon off;"]
