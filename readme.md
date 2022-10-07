# Bupstash docker image

This image uses two levels of access control:

- Bupstash encryption keys for encrypting and decrypting the actual data.
- ssh keys for determining what bupstash commands you are able to run. You might for want some ssh keys to only be able to append data to the repo and not read or delete data.


## ssh

This docker image exposes an ssh server with one user called `bu` on it. Add an authorized_keys file for this user in `conf/authorized_keys`

For example:

```
command="/bupstash-append.sh",restrict ssh-ed25519 AAAA...n/l putkey
command="/bupstash-get.sh",restrict ssh-ed25519 AAAA...owL getkey
```

The first key will only be allowed to append to the repo and the second key will only be allowed to get from the repo, for example for syncing.


## Bupstash Keys

Bupstash keys are used for the encryption of the actual data. You can create keys that are only able to encrypt but not to decrypt and so on. These keys are not used for actual authentication, we use ssh for that.

For example:

```
bupstash new-key -o backup-master.key
bupstash new-sub-key -k backup-master.key -o backup-list.key --list
bupstash new-sub-key -k backup-master.key -o backup-put.key --put
```


## Client

On a client that wants to push backups, add its ssh key to authorized_keys as above and do something like:

```
export BUPSTASH_REPOSITORY=ssh://bu@172.18.0.2/backup/repo
bupstash put --key backup-put.key stuff
```


## How to run tests

To test that the docker image behaves as expected:

```
docker compose -f docker-compose.test.yml run sut
```
