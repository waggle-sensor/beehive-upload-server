FROM alpine:3.16
RUN apk add --no-cache openssh-server rsync
COPY entrypoint.sh /usr/sbin/entrypoint.sh
ENTRYPOINT [ "/usr/sbin/entrypoint.sh" ]
