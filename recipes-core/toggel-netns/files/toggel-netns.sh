#!/bin/sh

# Variables
netns=arbitrary1
dev1=eth0
dev2=eth1

case "$1" in
    on)
        echo "Setting up network namespace..."
        # Create the network namespace
        ip netns add "$netns"

        # Bring down the network interfaces
        ip link set dev "$dev1" down
        ip link set dev "$dev2" down

        # Move the second interface to the network namespace
        ip link set dev "$dev2" netns "$netns"

        # Assign IP addresses to the interfaces
        ip address add 10.0.2.6/24 dev "$dev1"
        ip netns exec "$netns" ip address add 10.0.2.7/24 dev "$dev2"

        # Show the IP addresses in the namespace
        ip netns exec "$netns" ip address show

        # Bring up the network interfaces
        ip link set dev "$dev1" up
        ip netns exec "$netns" ip link set dev "$dev2" up
        ip netns exec "$netns" ip link set dev lo up
        echo "Network namespace setup completed."
        ;;
    off)
        echo "Disabling network namespace..."
        # Bring down the network interfaces
        ip link set dev "$dev1" down
        ip netns exec "$netns" ip link set dev "$dev2" down

        # Remove IP addresses
        ip address del 10.0.2.6/24 dev "$dev1"
        ip netns exec "$netns" ip address del 10.0.2.7/24 dev "$dev2"

        # Move the interface back to the default namespace
        ip netns exec "$netns" ip link set dev "$dev2" netns 1

        # Delete the network namespace
        ip netns del "$netns"

        # Bring up the network interfaces
        ip link set dev "$dev1" up
        ip address add 10.0.2.6/24 dev "$dev1"
        ip link set dev "$dev2" up
        echo "Network namespace disabled."
        ;;
    *)
        echo "Usage: $0 {on|off}"
        exit 1
        ;;
esac

