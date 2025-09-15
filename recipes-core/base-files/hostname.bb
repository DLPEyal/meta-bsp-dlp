DESCRIPTION = "hostname service"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=6f2e58f9db926d1d557f69da36ac4b7c"

SRC_URI = "file://hostname.service \
           file://hostname.sh"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "hostname.service"



do_install() {

    install -d ${D}${bindir}
    install -m 0755 hostname.sh ${D}${bindir}/hostname.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/hostname.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} += "${systemd_system_unitdir}/hostname.service"
