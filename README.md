# Beehive Upload Server

ssh+rsync based upload server for training data.

## Configuration

The follow environment variables are used:

* `SSH_CA_PUBKEY`. Location of CA pub key. Default is `/etc/waggle/ca.pub`.
* `SSH_HOST_KEY`. Location of upload server host key. Defalut is `/etc/waggle/ssh-host-key`.
* `SSH_HOST_CERT`. Location of upload server host cert. Default is `/etc/waggle/ssh-host-key-cert.pub`.
