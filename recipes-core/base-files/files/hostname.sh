#!/bin/sh

CONFIG_FILE="/etc/config.txt"
DEFAULT_HOSTNAME="orel_default"

# Wait until the config file exists
echo "Waiting for $CONFIG_FILE to be created..."

while [ ! -f "$CONFIG_FILE" ]; do
        sleep 1
done
if [ -f "$CONFIG_FILE" ]; then
    VALUE=$(cat $CONFIG_FILE)
    # Extract number (assuming it's like 123b or 456d)
    NUMBER=$(echo "$VALUE" | grep -oE '^[0-9]+')
    if [ -n "$NUMBER" ]; then
        HOSTNAME="DLP-AR-ARM${NUMBER}"
        echo "$HOSTNAME" > /etc/hostname
        hostname "$HOSTNAME"
    else
        echo "$DEFAULT_HOSTNAME" > /etc/hostname
        hostname "$DEFAULT_HOSTNAME"
    fi
else
    echo "$DEFAULT_HOSTNAME" > /etc/hostname
    hostname "$DEFAULT_HOSTNAME"
fi
ln -s /sys/devices/platform/kratos_station-pm/ /dev/gpio

