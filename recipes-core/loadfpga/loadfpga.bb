DESCRIPTION = "LoadFpga service"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=6f2e58f9db926d1d557f69da36ac4b7c"

SRC_URI = "file://decoderfpga.bin \
           file://loadfpga\
           file://loadfpga.service \
           file://loadfpga.sh"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "loadfpga.service"

RDEPENDS:${PN} = "jsoncpp"


do_install() {

    install -d ${D}/etc
    install -m 0644 ${WORKDIR}/decoderfpga.bin ${D}/etc/decoderfpga.bin
    
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/loadfpga ${D}${bindir}/loadfpga

    install -d ${D}${bindir}
    install -m 0755 loadfpga.sh ${D}${bindir}/loadfpga.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/loadfpga.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} += "${systemd_system_unitdir}/loadfpga.service"

