#!/bin/sh

CONFIG_FILE="/etc/config.txt"
NETWORK_DIR="/etc/systemd/network"

# Wait until the config file exists
echo "Waiting for $CONFIG_FILE to be created..."
while [ ! -f "$CONFIG_FILE" ]; do
    sleep 1
done

#!/bin/sh



mkdir -p "$NETWORK_DIR"
VALUE=$(cat "$CONFIG_FILE")
NUMBER=$(echo "$VALUE" | grep -oE '^[0-9]+')

if [ -z "$NUMBER" ]; then
    echo "Invalid number in config.txt"
    exit 1
fi

echo "Generating network config for NUMBER=$NUMBER"
rm -f "$NETWORK_DIR"/10-static-eth*.network

if [ "$NUMBER" = "3" ]; then
    # eth0 = 10.0.2.6
    cat > "$NETWORK_DIR/10-static-eth0.network" <<EOF
[Match]
Name=eth0

[Network]
Address=10.0.2.6/24
Gateway=10.0.2.1
IgnoreCarrierLoss=yes
EOF

    # eth1 = 10.0.2.7
    cat > "$NETWORK_DIR/10-static-eth1.network" <<EOF
[Match]
Name=eth1

[Network]
Address=10.0.2.7/24
IgnoreCarrierLoss=yes
EOF

    # eth2 = 10.0.1.6
    cat > "$NETWORK_DIR/10-static-eth2.network" <<EOF
[Match]
Name=eth2

[Network]
Address=10.0.1.6/24
Gateway=10.0.1.1
IgnoreCarrierLoss=yes
EOF

else
    # eth0 = 10.0.1.(3 + number)
    ETH0_IP="10.0.1.$((3 + NUMBER))"
    cat > "$NETWORK_DIR/10-static-eth0.network" <<EOF
[Match]
Name=eth0

[Network]
Address=${ETH0_IP}/24
Gateway=10.0.1.1
IgnoreCarrierLoss=yes
EOF

    # eth1 = 10.0.2.(3 + number)
    ETH1_IP="10.0.2.$((3 + NUMBER))"
    cat > "$NETWORK_DIR/10-static-eth1.network" <<EOF
[Match]
Name=eth1

[Network]
Address=${ETH1_IP}/24
Gateway=10.0.2.1
IgnoreCarrierLoss=yes
EOF
fi

# Restart network
systemctl restart systemd-networkd
sleep 1
ip a
ip r

