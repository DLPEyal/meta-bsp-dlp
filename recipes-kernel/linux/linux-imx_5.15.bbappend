SRCBRANCH = "lf-5.15.y"
KERNEL_SRC ?= "git://github.com/nxp-imx/linux-imx.git;protocol=https;branch=${SRCBRANCH}"

#KERNEL_DEVICETREE += "freescale/imx8mp-evk.dtb"
SRC_URI += "file://0001-removed-promisc-check-on-eth1.patch \
     file://0002-named-gpio.patch \
     file://0003-embedded-definitions.patch \
     file://0004-whitelist-usb-support.patch \
     file://0005-usb-whitelist-add-lan-7800-and-7801.patch \
     file://0006-changed-UART-pins-for-UART0.patch \
     file://0007-add-uart-4.patch \
     file://0008-Load-FPGA-gpio-config.patch \
     file://0009-gpio-interrupt-kernel-dts-update.patch \
     file://0010-add-GPT.patch \
     file://0011-support-uart-debug-arm-reset-LAN7800.patch \
     file://0012-load-fpga-ARM-FPGA-Uarts-GPIO-interrupt-Spi-data.patch \
     file://0013-fixed-link-ethernet.patch \
     file://0014-change-UART2-DTE-mode-flash-to-MTP.patch \
     file://0015-fix-the-spidev-problem.patch \
     file://0016-support-2XSRAM-DTS.patch \
     file://0017-add-gpio-support.patch \
     file://0018-add-base-and-decoder-dts.patch \
     file://0019-update-GPIOs-Finish-Drop3.patch \
     file://0020-add-ERASE_STS_OUT-GPIO.patch \
	file://0021-Add-i2c4-and-create-a-seperate-gpio-named.patch \
	file://0022-Separate-DTS-files-GPIO-fixes-Driver-update.patch \
	file://0023-RGMII_RST-change.patch \
	file://0024-Adding-second-MTP-to-dts-basearm1-and-basearm2.patch \
	file://0025-Adding-AT_signal-and-SPI_busy-GPIO.patch \
	file://0026-changes-to-SPI-driver.patch \
	file://0027-SR-check-added.patch \
	file://0028-DTS-modify.patch \
     file://0029-PMIC-pins-fix-ARM1-3.patch \
     file://0030-fix-reg-format-remove-DMA-on-uart-and-audio-ARM1-3.patch \
     file://0033-disable-pcie-on-arm1-3.patch \
     file://0034-clear-can-hdmi-sound-pwm-leftovers-from-ARM1-3-devic.patch \
     file://0035-PHY-reset-changes-removed-eeprom.patch \
     file://0036-Board-type-edited.patch \
     file://0037-updated-arm1-gpio.patch \
     file://0038-default-change-for-arm1-reboot-out-to-high.patch \
     file://kernel_config.cfg"

#KERNEL_CONFIG_FRAGMENTS:append = " ${WORKDIR}/kernel_config.cfg"

do_configure:append() {
     cat ${WORKDIR}/kernel_config.cfg >> ${B}/.config
#     oe_runmake -C ${S} O=${B} olddefconfig
}

FILES:${PN}:remove = "/boot"
# Add fitimage as target 
KERNEL_IMAGETYPES += " fitImage"

# Use RSA-4096 for signing
FIT_SIGN_ALG = "rsa4096"
FIT_SIGN_NUMBITS = "4096"

# Enable fit signing and set keys dir
FIT_SIGN_ENABLE = "1"
FIT_KEY_DIR  = "${SECBOOT_KEYDIR}"

#disable kernel compression
FIT_KERNEL_COMP_ALG = "gzip"
FIT_KERNEL_COMP_ALG_EXTENSION = ".gz"

#set the Yocto helper that builds FIT from Image + DTBs + rootfs using mkimage
inherit kernel-fitimage
