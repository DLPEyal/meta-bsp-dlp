DESCRIPTION = "Bit Service"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=6f2e58f9db926d1d557f69da36ac4b7c"

SRC_URI = "file://bit.service \
           file://bit.sh \
           file://bit \
           file://config.json"

S = "${WORKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "bit.service"

RDEPENDS:${PN} = "jsoncpp"

do_install() {

    install -d ${D}${sysconfdir}
    install -m 0644 ${S}/config.json ${D}${sysconfdir}/config.json
    
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/bit ${D}${bindir}/bit
    
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/bit.sh ${D}${bindir}/bit.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/bit.service ${D}${systemd_system_unitdir}/
}

FILES:${PN} += "${systemd_system_unitdir}/bit.service"

