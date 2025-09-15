SUMMARY = "Load kratos_station-pm module at boot"
DESCRIPTION = "A configuration file to ensure the kratos_station-pm module is loaded at boot."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://kratos_station-pm.conf"

inherit allarch

do_install() {
    install -d ${D}${sysconfdir}/modules-load.d
    install -m 0644 ${WORKDIR}/kratos_station-pm.conf ${D}${sysconfdir}/modules-load.d/
}

FILES_${PN} += "${sysconfdir}/modules-load.d/kratos_station-pm.conf"

