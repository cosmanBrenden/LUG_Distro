FROM debian:bookworm-slim

LABEL maintainer="LUG Distro Project"
LABEL description="Minimal Debian-based Linux distribution"

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-utils \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        systemd \
        systemd-sysv \
        init \
        dbus \
        sudo \
        vim-tiny \
        nano \
        bash-completion \
        less \
        procps \
        psmisc \
        iproute2 \
        iputils-ping \
        net-tools \
        openssh-server \
        rsyslog \
        cron \
        locales && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8

RUN systemctl mask systemd-networkd-wait-online.service \
                   systemd-networkd.service \
                   systemd-resolved.service \
                   apt-daily.service \
                   apt-daily.timer \
                   apt-daily-upgrade.timer \
                   apt-daily-upgrade.service

RUN useradd -m -s /bin/bash -G sudo luguser && \
    echo "luguser:luguser" | chpasswd && \
    echo "luguser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

WORKDIR /home/luguser

USER luguser

CMD ["/bin/bash"]