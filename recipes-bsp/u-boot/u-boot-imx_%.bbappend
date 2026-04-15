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
            file://0011-SF-changes-for-protect.patch \
            file://0012-optee-reserve-memory.patch \
            file://0014-PHY-reset-changes.patch \
            "

# Conditional secure boot mandatory signature verification
# Enable by default, set SECURE_BOOT_ENABLE= "0" in machine conf to disable
SECURE_BOOT_ENABLE ??= "1"
SRC_URI += "${@bb.utils.contains('SECURE_BOOT_ENABLE', '1', 'file://0013-secboot-mandatory-signature-verification.patch', '', d)}"

SRC_URI += "file://defconfig.cfg"
UBOOT_CONFIG_FRAGMENTS += "defconfig.cfg"

# FIT image support (always enabled)
SRC_URI += "file://fit.cfg"
UBOOT_CONFIG_FRAGMENTS += "fit.cfg"

# Signature verification settings (only when secure boot is enabled)
SRC_URI += "${@bb.utils.contains('SECURE_BOOT_ENABLE', '1', 'file://secboot.cfg', '', d)}"
UBOOT_CONFIG_FRAGMENTS += "${@bb.utils.contains('SECURE_BOOT_ENABLE', '1', 'secboot.cfg', '', d)}"
#parameters for u-boot mkimage
UBOOT_MKIMAGE_DTCOPTS = "-I dts -O dtb -p 2000"

# When signing is disabled, U-Boot still builds a DTB but doesn't deploy it as u-boot.dtb
# We need to deploy it so imx-boot can use it
do_deploy:append() {
    if [ "${UBOOT_SIGN_ENABLE}" != "1" ]; then
        # Find and deploy the U-Boot DTB (without signing keys) when signing is disabled
        # For UBOOT_CONFIG builds, the DTB is in a config-specific subdirectory
        for config in ${UBOOT_MACHINE}; do
            if [ -f "${B}/${config}/u-boot.dtb" ]; then
                install -m 0644 ${B}/${config}/u-boot.dtb ${DEPLOYDIR}/u-boot.dtb
                bbnote "Deployed u-boot.dtb from ${B}/${config}/u-boot.dtb"
                break
            fi
        done
        # Fallback: check base build directory
        if [ ! -f "${DEPLOYDIR}/u-boot.dtb" ] && [ -f "${B}/u-boot.dtb" ]; then
            install -m 0644 ${B}/u-boot.dtb ${DEPLOYDIR}/u-boot.dtb
            bbnote "Deployed u-boot.dtb from ${B}/u-boot.dtb"
        fi
    fi
}


