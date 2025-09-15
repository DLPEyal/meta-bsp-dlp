DESCRIPTION = "Script to start and stop network bridge"
SECTION = "network"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=6f2e58f9db926d1d557f69da36ac4b7c"

SRC_URI = "file://bridgeactivation.sh \
           file://bridgeactivation.service"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "bridgeactivation.service"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/bridgeactivation.sh ${D}${bindir}/bridgeactivation.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/bridgeactivation.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} += "${systemd_system_unitdir}/bridgeactivation.service"

SYSTEMD_AUTO_ENABLE = "disable"
