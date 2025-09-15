SUMMARY = "Systemd service for configuring ethtool settings on eth0"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
SRC_URI = "file://ethtool.service"

inherit systemd

SYSTEMD_SERVICE:${PN} = "ethtool.service"

do_install() {
    install -d ${D}${systemd_system_unitdir}
    install -m 644 ${WORKDIR}/ethtool.service ${D}${systemd_system_unitdir}
}

FILES:${PN} = "${systemd_system_unitdir}/ethtool.service"

pkg_postinst_${PN}() {
    if [ -z "$D" ]; then
        systemctl enable ethtool.service
    fi
}
