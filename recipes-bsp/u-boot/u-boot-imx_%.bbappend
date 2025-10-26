FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-update-read-status-register.patch \
            file://0002-Update-SF-PROTECT.patch \
            file://0003-Decoder-PCB-Intial-BringUP.patch \
            file://0004-fix-size-LPDDR-TO-1GB.patch \
            file://0005-change-UART2-TO-DTE.patch \
            file://0006-Support-Base-SPL-UBoot.patch \
            file://0007-add-support-of-marvell-1512.patch \
            file://0008-merge-and-update-u-boot-spl-to-support-full-DLP.patch \
            file://0009-add-phy-delay-reset.patch \
            file://0010-Adding-second-MTP.patch \
            "

SRC_URI += "file://defconfig.cfg"

do_configure:append() {
    cat ${WORKDIR}/defconfig.cfg >> ${B}/.config
}
