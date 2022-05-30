#!/bin/bash

set -ex

if [ -f "/authorized_keys" ]; then
  cp "/authorized_keys" "/home/bu/.ssh/authorized_keys"
  chmod 600 "/home/bu/.ssh/authorized_keys"
  chown "bu:bu" "/home/bu/.ssh/authorized_keys"
fi

/usr/sbin/sshd -D -e
