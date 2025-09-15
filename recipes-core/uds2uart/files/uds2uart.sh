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

# Check if ID equals 3
if [ "$ID" -eq 3 ]; then
    echo "ID is 3 - launching nano..."
    uds2uart
else
    echo "ID is not 3 - exiting."
fi

exit 0

