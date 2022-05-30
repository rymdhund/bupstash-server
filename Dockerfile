FROM rust:1.60-bullseye

RUN apt update && apt install -y libsodium-dev openssh-server && \
    cargo install bupstash && \
    cp /usr/local/cargo/bin/bupstash /usr/bin

RUN mkdir /backup && \
    useradd bu && \
    mkdir -p /home/bu/.ssh && \
    chown -R bu:bu /home/bu && \
    chmod 700 /home/bu/.ssh && \
    mkdir -p /var/run/sshd && \
    chown -R bu:bu /backup && \
    echo '\n\
Match User bu\n\
  AllowTCPForwarding no\n\
  X11Forwarding no\n'\
>> /etc/ssh/sshd_config

COPY resources/* /

EXPOSE 22

ENTRYPOINT /run.sh
