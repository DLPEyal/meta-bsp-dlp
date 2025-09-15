SUMMARY = "Load imx-sdma module at boot"
DESCRIPTION = "A configuration file to ensure the imx-sdma module is loaded at boot."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://imx-sdma.conf"

inherit allarch

do_install() {
    install -d ${D}${sysconfdir}/modules-load.d
    install -m 0644 ${WORKDIR}/imx-sdma.conf ${D}${sysconfdir}/modules-load.d/
}

FILES_${PN} += "${sysconfdir}/modules-load.d/imx-sdma.conf"

