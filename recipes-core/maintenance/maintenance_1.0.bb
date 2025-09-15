DESCRIPTION = "Maintenance service"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=6f2e58f9db926d1d557f69da36ac4b7c"

SRC_URI = "file://config.txt\
	   file://maintenance\
	   file://mcutest\
           file://maintenance.service \
           file://maintenance.sh"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "maintenance.service"

RDEPENDS:${PN} = "jsoncpp"


do_install() {

    install -d ${D}/etc
    install -m 0644 ${WORKDIR}/config.txt ${D}/etc/config.txt
    
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/maintenance ${D}${bindir}/maintenance
    
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/mcutest ${D}${bindir}/mcutest

    install -d ${D}${bindir}
    install -m 0755 maintenance.sh ${D}${bindir}/maintenance.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/maintenance.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} += "${systemd_system_unitdir}/maintenance.service"

