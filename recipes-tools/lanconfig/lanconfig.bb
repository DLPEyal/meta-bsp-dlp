DESCRIPTION = "Place a custom file in /etc"
LICENSE = "CLOSED"

SRC_URI = "file://lan7800.bin"

do_install() {
    # Create the /etc directory in the image if it doesn't already exist
    install -d ${D}/etc

    # Install the file into /etc
    install -m 0644 ${WORKDIR}/lan7800.bin ${D}/etc/lan7800.bin
}

# Explicitly ship the file in the package
FILES_${PN} += "/etc/lan7800.bin"

