# ANSI escape sequences for different font styles
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# Print the headline in large font size
echo "${BOLD}Release Notes${NORMAL}"

echo "${BOLD}release 1.0.9.0${NORMAL}"
echo "usb whitelist added"

echo "${BOLD}release 1.0.8.0${NORMAL}"
echo "netsniff-ng added"
echo "tcpdump added"

echo "${BOLD}release 1.0.7.0${NORMAL}"
echo "/sys/class/gpio support added"
echo "named_gpio kernel module added"

echo "${BOLD}release 1.0.4.0${NORMAL}"
echo "ssh login with key automatically supported"

echo "${BOLD}release 1.0.3.0${NORMAL}"
echo "managed modem - auto start service which manage modem connection"
echo "can-FD support"
echo "silent MCU new definitions"


#release 1.0.0.0
# Print the version number in smaller font size
echo "${BOLD}release 1.0.0.0${NORMAL}"

# Print the remaining text in normal font size
echo "cpulimit"
echo "pxz"
echo "version management"
