#!/bin/sh
set -eu

# TODO(sean) should these setup scripts should be baked into the image or
# should they be config and run as start from an init.d/ directory?

configure_persistent_etc_files() {
    dir=/etc-data

    mkdir -p "${dir}"

    for f in passwd group shadow; do
        # if link already configure, skip
        if readlink "/etc/${f}"; then
            continue
        fi
        # otherwise, copy contents and setup link
        cp "/etc/${f}" "${dir}/${f}"
        ln -f -s "${dir}/${f}" "/etc/${f}"
    done
}

configure_beekeeper_user() {
    user=beekeeper

    if ! grep -q "${user}" /etc/passwd; then
        adduser -g '' -D "${user}"
    fi

    if ! grep -q "${user}::" /etc/shadow; then
        passwd -u "${user}"
    fi

    cat > "/etc/sudoers.d/${user}" <<EOF
${user} ALL=NOPASSWD: /usr/sbin/bk-add-user
${user} ALL=NOPASSWD: /usr/sbin/bk-del-user
EOF
}

main() {
    configure_persistent_etc_files
    configure_beekeeper_user
    
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
}

main "$@"
