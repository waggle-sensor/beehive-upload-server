FROM ubuntu:focal
RUN apt update && apt install -y openssh-server rsync
RUN mkdir -p /run/sshd
COPY sshd_config /etc/ssh/sshd_config
CMD [ "/usr/sbin/sshd", "-D", "-e" ]
