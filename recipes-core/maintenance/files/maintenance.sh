#!/bin/sh

CONFIG_FILE="/etc/config.txt"

# Wait until the config file exists
echo "Waiting for $CONFIG_FILE to be created..."
while [ ! -f "$CONFIG_FILE" ]; do
    sleep 1
done

echo "File found. Reading..."

# Read the line from the config file
LINE=`cat "$CONFIG_FILE"`

# Extract ID and MODE from the line
ID=`echo "$LINE" | cut -d',' -f1`
MODE=`echo "$LINE" | cut -d',' -f2`

# Print the extracted values
echo "Found ID=$ID, MODE=$MODE"

# Check if MODE is Decoder stand alone

if [ "$ID" -eq 3 ] && [ "$MODE" = "d" ]; then
echo "Decoder Stand alone - Waiting for Eth"
IPS="10.0.1.6"

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



# Check if ID equals 2
elif [ "$ID" -eq 2 ]; then
    echo "ID is 2 - Waiting for Eth"

# IPs to check
IPS="10.0.1.5"

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

else
	echo "ID is not 2 - Running maintenance."
	maintenance
fi

