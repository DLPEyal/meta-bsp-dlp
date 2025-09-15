DESCRIPTION = "uds2uart service"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=6f2e58f9db926d1d557f69da36ac4b7c"

SRC_URI = "file://uds2uart\
           file://uds2uart.service \
           file://uds2uart.sh"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "uds2uart.service"

RDEPENDS:${PN} = "jsoncpp"


do_install() {

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/uds2uart ${D}${bindir}/uds2uart
    
    install -d ${D}${bindir}
    install -m 0755 uds2uart.sh ${D}${bindir}/uds2uart.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/uds2uart.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} += "${systemd_system_unitdir}/uds2uart.service"

