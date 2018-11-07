FROM phusion/baseimage:0.11
ARG DEBIAN_FRONTEND=noninteractive

ENV BITCOIND_VERSION 0.17.0.1
ENV BITCOIND_SHA256 6ccc675ee91522eee5785457e922d8a155e4eb7d5524bd130eb0ef0f0c4a6008

ENV BITCOIND_PATH /opt/bitcoind
ENV DAEMON_USER bitcoind

# Update & install dependencies and do cleanup
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
        libzmq3-dev \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and install bitcoind release
RUN curl --silent -L "https://bitcoin.org/bin/bitcoin-core-$BITCOIND_VERSION/bitcoin-$BITCOIND_VERSION-x86_64-linux-gnu.tar.gz" -o /tmp/bitcoin.tar.gz && \
    mkdir $BITCOIND_PATH && \
    cd /tmp && \
    echo "$BITCOIND_SHA256 *bitcoin.tar.gz" | sha256sum -c - && \
    tar xzf /tmp/bitcoin.tar.gz -C $BITCOIND_PATH --strip 1 && \
    rm /tmp/bitcoin.tar.gz


# Add bitcoind system user
RUN useradd -m -r -d $BITCOIND_PATH -s /bin/bash $DAEMON_USER

USER root

# Add our daemon config
COPY bitcoind.conf /etc/bitcoind.conf

RUN chown -R bitcoind:bitcoind /opt/bitcoind && \
    mkdir /data && \
    chown -R bitcoind:bitcoind /data

# Add our daemon startup script
RUN mkdir /etc/service/bitcoind
COPY bitcoind.sh /etc/service/bitcoind/run
RUN chmod +x /etc/service/bitcoind/run

EXPOSE 28332 8332
VOLUME ["/data"]
CMD ["/sbin/my_init"]