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
            file://0015-spl-DLP-multi-DTB-config.patch \
            file://0016-pre-enabling-QSPI-clock-to-balance-disable-commands.patch \
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

# Multi-DTB build pack all three DLP DTBs into U-Boot
# SPL's board_fit_config_name_match() will be able to pack all 3 dtbs
SRC_URI += "file://multi-dtb.cfg"
UBOOT_CONFIG_FRAGMENTS += "multi-dtb.cfg"

# Signature verification settings (only when secure boot is enabled)
SRC_URI += "${@bb.utils.contains('SECURE_BOOT_ENABLE', '1', 'file://secboot.cfg', '', d)}"
UBOOT_CONFIG_FRAGMENTS += "${@bb.utils.contains('SECURE_BOOT_ENABLE', '1', 'secboot.cfg', '', d)}"

# Per-board DTS files and common include
SRC_URI += "file://imx8mp-dlp.dtsi \
            file://imx8mp-dlp-basearm1.dts \
            file://imx8mp-dlp-basearm2.dts \
            file://imx8mp-dlp-decoder.dts \
            "

UBOOT_MKIMAGE_DTCOPTS = "-I dts -O dtb -p 2000"

# do_configure / do_compile must re-run when SECURE_BOOT_ENABLE flips,
# because the conditional patch above changes the source tree.
do_configure[vardeps] += "SECURE_BOOT_ENABLE"
do_compile[vardeps]   += "SECURE_BOOT_ENABLE"

# Single U-Boot build for all three DLP boards.
UBOOT_CONFIG = "dlp"
UBOOT_CONFIG[dlp] = "dlp_defconfig"

UBOOT_DTB_NAME = "imx8mp-dlp-basearm1.dtb"

do_configure:prepend() {
    #Stage our DTS/DTSI files in U-Boot's dts dir.
    # install -m always overwrites; do not depend on cp's behaviour here.
    for f in imx8mp-dlp.dtsi \
             imx8mp-dlp-basearm1.dts imx8mp-dlp-basearm2.dts imx8mp-dlp-decoder.dts; do
        if [ -f "${WORKDIR}/${f}" ]; then
            install -m 0644 "${WORKDIR}/${f}" "${S}/arch/arm/dts/${f}"
        fi
    done

    #Register all three DTBs in U-Boot's dts Makefile so kbuild builds them.
    if ! grep -q "imx8mp-dlp-basearm1" "${S}/arch/arm/dts/Makefile"; then
        sed -i '/imx8mp-evk.dtb/a\\timx8mp-dlp-basearm1.dtb \\\n\timx8mp-dlp-basearm2.dtb \\\n\timx8mp-dlp-decoder.dtb \\' \
            "${S}/arch/arm/dts/Makefile"
    fi

    # 3. Create dlp_defconfig as a copy of imx8mp_evk_defconfig
    if [ ! -f "${S}/configs/dlp_defconfig" ]; then
        cp "${S}/configs/imx8mp_evk_defconfig" "${S}/configs/dlp_defconfig"
    fi

}

do_deploy:append() {
    install -d ${DEPLOYDIR}/${BOOT_TOOLS}

    # Deploy all three board DTBs so imx-boot can assemble a multi-config u-boot.itb.
    for dt_name in imx8mp-dlp-basearm1 imx8mp-dlp-basearm2 imx8mp-dlp-decoder; do
        src="${B}/dlp_defconfig/arch/arm/dts/${dt_name}.dtb"
        if [ -f "${src}" ]; then
            install -m 0644 "${src}" "${DEPLOYDIR}/${BOOT_TOOLS}/${dt_name}.dtb"
            install -m 0644 "${src}" "${DEPLOYDIR}/${dt_name}.dtb"
        fi
    done

    # When signing is disabled, U-Boot still builds a DTB but doesn't deploy it as u-boot.dtb
    # We need to deploy it so imx-boot can use it
    if [ "${UBOOT_SIGN_ENABLE}" != "1" ]; then
        for config in ${UBOOT_MACHINE}; do
            if [ -f "${B}/${config}/arch/arm/dts/imx8mp-dlp-basearm1.dtb" ]; then
                install -m 0644 ${B}/${config}/arch/arm/dts/imx8mp-dlp-basearm1.dtb ${DEPLOYDIR}/u-boot.dtb
                bbnote "Deployed u-boot.dtb from ${B}/${config}/arch/arm/dts/imx8mp-dlp-basearm1.dtb"
                break
            fi
            if [ -f "${B}/${config}/u-boot.dtb" ]; then
                install -m 0644 ${B}/${config}/u-boot.dtb ${DEPLOYDIR}/u-boot.dtb
                bbnote "Deployed u-boot.dtb from ${B}/${config}/u-boot.dtb"
                break
            fi
        done
        # check base build directory in case dtb is not found
        if [ ! -f "${DEPLOYDIR}/u-boot.dtb" ] && [ -f "${B}/u-boot.dtb" ]; then
            install -m 0644 ${B}/u-boot.dtb ${DEPLOYDIR}/u-boot.dtb
            bbnote "Deployed u-boot.dtb from ${B}/u-boot.dtb"
        fi
    fi
}
