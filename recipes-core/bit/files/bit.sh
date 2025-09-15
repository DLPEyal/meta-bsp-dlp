#!/bin/sh

# Call the bit script
echo " Run BIT Server "
sleep 10
bit
exec /etc/bit.sh
