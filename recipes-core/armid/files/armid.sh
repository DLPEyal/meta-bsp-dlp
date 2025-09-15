#!/bin/sh

# Define GPIO numbers
GPIO_A=44
GPIO_B=48
GPIO_MODE=47  # New GPIO for mode (B or D)

# Export GPIOs if not already exported
for GPIO in $GPIO_A $GPIO_B $GPIO_MODE; do
    if [ ! -e /sys/class/gpio/gpio$GPIO ]; then
        echo $GPIO > /sys/class/gpio/export
    fi
    echo "in" > /sys/class/gpio/gpio$GPIO/direction
done

# Read values
VAL_A=$(cat /sys/class/gpio/gpio$GPIO_A/value)
VAL_B=$(cat /sys/class/gpio/gpio$GPIO_B/value)
VAL_MODE=$(cat /sys/class/gpio/gpio$GPIO_MODE/value)

# Convert to binary (A=LSB, B=MSB)
ID=$(( ($VAL_B << 1) | $VAL_A ))

# Determine mode character
if [ "$VAL_MODE" == "1" ]; then
    MODE="d"
else
    MODE="b"
fi

# Output to console
echo "GPIO $GPIO_B:$VAL_B, GPIO $GPIO_A:$VAL_A, GPIO $GPIO_MODE:$VAL_MODE => ID = $ID, MODE = $MODE"

# Write to config file
echo "$ID,$MODE" > /etc/config.txt

exit 0

