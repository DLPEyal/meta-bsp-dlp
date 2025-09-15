#!/bin/sh
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
    	echo "Load FPGA Ver 1.0"

	# Check if /dev/spidev2.1 exists with a timeout of 5 seconds
	timeout=10
	elapsed=0
	while [ ! -e /dev/spidev2.1 ]; do
	  if [ $elapsed -ge $timeout ]; then
	    echo "Error: /dev/spidev2.1 not found after $timeout seconds."
	    exit 1
	  fi
	  sleep 1
	  elapsed=$((elapsed + 1))
	done

	# Load FPGA binary
	loadfpga -c /dev/spidev2.1 -p /etc/decoderfpga.bin
	if [ $? -ne 0 ]; then
	  echo "Error: Failed to load FPGA binary."
	  exit 1
	fi

	# Bring up the eth1 interface
	ifconfig eth1 up
	if [ $? -ne 0 ]; then
	  echo "Error: Failed to bring up eth1 interface."
	  exit 1
	fi

	echo "Done"
    
else
    echo "ID is not 3 - exiting."
fi

exit 0








