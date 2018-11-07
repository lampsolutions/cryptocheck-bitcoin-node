#!/bin/sh

exec /sbin/setuser $DAEMON_USER $BITCOIND_PATH/bin/bitcoind -conf=/etc/bitcoind.conf >> /var/log/bitcoind.log 2>&1