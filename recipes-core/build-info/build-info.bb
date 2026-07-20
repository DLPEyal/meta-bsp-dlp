SUMMARY = "Build information"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit allarch

do_install() {
    install -d ${D}${sysconfdir}
    echo "VERSION=2.9.0" > ${D}${sysconfdir}/build-info

}

FILES:${PN} += "${sysconfdir}/build-info"

