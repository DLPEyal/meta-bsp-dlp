DESCRIPTION = "uds2spi service"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=6f2e58f9db926d1d557f69da36ac4b7c"

SRC_URI = "file://uds2spi\
           file://uds2spi.service \
           file://uds2spi.sh"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "uds2spi.service"

RDEPENDS:${PN} = "jsoncpp"


do_install() {

    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/uds2spi ${D}${bindir}/uds2spi
   
    install -d ${D}${bindir}
    install -m 0755 uds2spi.sh ${D}${bindir}/uds2spi.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/uds2spi.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} += "${systemd_system_unitdir}/uds2spi.service"

