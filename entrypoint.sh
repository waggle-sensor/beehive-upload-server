#!/bin/sh

SSH_CA_PUBKEY="${SSH_CA_PUBKEY:-/etc/waggle/ca.pub}"
SSH_HOST_KEY="${SSH_HOST_KEY:-/etc/waggle/ssh-host-key}"
SSH_HOST_CERT="${SSH_HOST_CERT:-/etc/waggle/ssh-host-key-cert.pub}"

echo "using credentials"
echo "ssh ca pubkey: ${SSH_CA_PUBKEY}"
echo "ssh host key: ${SSH_HOST_KEY}"
echo "ssh host cert: ${SSH_HOST_CERT}"

cat > /etc/ssh/sshd_config <<EOF
Port 22
ListenAddress 0.0.0.0
ListenAddress ::

TrustedUserCAKeys ${SSH_CA_PUBKEY}
HostKey ${SSH_HOST_KEY}
HostCertificate ${SSH_HOST_CERT}

LogLevel VERBOSE

LoginGraceTime 60
PermitRootLogin prohibit-password
StrictModes yes
MaxAuthTries 3
MaxSessions 3

PubkeyAuthentication yes
AuthorizedKeysFile	.ssh/authorized_keys
AuthorizedPrincipalsFile none

PasswordAuthentication no
ChallengeResponseAuthentication no

AllowAgentForwarding no
AllowTcpForwarding no
GatewayPorts no
X11Forwarding no
PermitTTY no
PrintMotd no
TCPKeepAlive yes
PermitUserEnvironment no
#Compression delayed
#ClientAliveInterval 0
#ClientAliveCountMax 3
UseDNS no
PidFile /var/run/sshd.pid
#MaxStartups 10:30:100
PermitTunnel no
AcceptEnv LANG LC_*
EOF

mkdir -p /run/sshd
exec /usr/sbin/sshd -D -e
