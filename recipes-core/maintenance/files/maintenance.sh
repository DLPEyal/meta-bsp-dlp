#!/bin/sh

# IPs to check
IPS="10.0.1.6 10.0.1.5 10.0.1.4"

echo "Waiting for network availability..."

while true; do
    for IP in $IPS; do
        if ping -c 1 -W 1 $IP > /dev/null 2>&1; then
            echo "Active IP found: $IP"
            echo "Run Maintenance Process"
            maintenance
            exit 0
        fi
    done
    sleep 1  # Wait 1 seconds before checking again
done

