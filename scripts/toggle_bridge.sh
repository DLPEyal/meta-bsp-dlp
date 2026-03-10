#!/bin/sh

BRIDGE="br0"
IFACE1="eth0"
IFACE2="eth1"



bridge_exists() {
    ip link show "$BRIDGE" >/dev/null 2>&1
}



case "$1" in

    start)
        echo "Creating bridge $BRIDGE"

	# Create bridge if missing

        if ! bridge_exists; then
            ip link add name $BRIDGE type bridge
        fi

        # Bring interfaces down before enslaving

        ip link set $IFACE1 down
        ip link set $IFACE2 down

        # Attach interfaces to bridge

        ip link set $IFACE1 master $BRIDGE
        ip link set $IFACE2 master $BRIDGE

        # Bring everything up

        ip link set $IFACE1 up
        ip link set $IFACE2 up
        ip link set $BRIDGE up

        echo "Bridge $BRIDGE started"

        ;;

    stop)

        echo "Removing bridge $BRIDGE"

        # Detach interfaces

        ip link set $IFACE1 nomaster 2>/dev/null
        ip link set $IFACE2 nomaster 2>/dev/null

        # Bring bridge down and delete

        ip link set $BRIDGE down 2>/dev/null
        ip link del $BRIDGE 2>/dev/null

        # Bring interfaces back up

        ip link set $IFACE1 up
        ip link set $IFACE2 up

        echo "Bridge $BRIDGE removed"

        ;;

    status)

        ip -d link show type bridge

	;;

    *)

        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;

esac

