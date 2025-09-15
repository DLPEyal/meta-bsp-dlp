DESCRIPTION = "static-ip-config service"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=6f2e58f9db926d1d557f69da36ac4b7c"

SRC_URI = "file://static-ip-config.service \
           file://static-ip-config.sh"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "static-ip-config.service"



do_install() {

   
    install -d ${D}${bindir}
    install -m 0755 static-ip-config.sh ${D}${bindir}/static-ip-config.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/static-ip-config.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} += "${systemd_system_unitdir}/static-ip-config.service"

