#!/bin/bash

set -euo pipefail

mkdir -p /root/.ssh
cp /test/ssh-config /root/.ssh/config
chmod 700 /root/.ssh
chmod 600 /root/.ssh/config

bupstash new-key -o /tmp/backup-master.key
bupstash new-sub-key -k /tmp/backup-master.key -o /tmp/backup-put.key --put
bupstash new-sub-key -k /tmp/backup-master.key -o /tmp/backup-list.key --list

mkdir /tmp/stuff
echo "abc" > /tmp/stuff/file.txt

# test backup

# Backup our file
id=$(bupstash put -r ssh://backup-put/backup/repo --key /tmp/backup-put.key /tmp/stuff)

# Check that list works as expected
bupstash list -r ssh://backup-list/backup/repo --key /tmp/backup-list.key >&2

# Check that restore works
mkdir /tmp/restore
bupstash get -r ssh://backup-get/backup/repo --key /tmp/backup-master.key id=$id | tar -C /tmp/restore -xvf -

if ! diff -q /tmp/restore/file.txt /tmp/stuff/file.txt; then
  echo "Original and restored files differ!" >&2
  exit 1
fi

# We shouldn't be able to decrypt stuff with "put" or "list" keys
echo "get with put key" >&2
if bupstash get -r ssh://backup-get/backup/repo --key /tmp/backup-put.key id=$id; then
  echo "Decrypted with put key" >&2
  exit 1
fi

echo "get with list key" >&2
if bupstash get -r ssh://backup-get/backup/repo --key /tmp/backup-list.key id=$id; then
  echo "Decrypted with put key" >&2
  exit 1
fi

# We shouldn't be able to run remove with append-only account
echo "remove with put account" >&2
if bupstash remove -r ssh://backup-put/backup/repo id=$id; then
  echo "Deleted with append only account" >&2
  exit 1
fi


echo "All good" >&2
