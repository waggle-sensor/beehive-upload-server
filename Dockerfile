FROM alpine:3.16
RUN apk add --no-cache \
    openssh-server \
    rsync \
    sudo
COPY sbin /usr/sbin
ENTRYPOINT [ "/usr/sbin/entrypoint.sh" ]
