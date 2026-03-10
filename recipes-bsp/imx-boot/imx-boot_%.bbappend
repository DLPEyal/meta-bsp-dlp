UBOOT_DTB_NAME = "u-boot.dtb"
do_compile[depends] += "u-boot:do_deploy"

# Copy u-boot.dtb to boot tools
# - When secure boot enabled: DTB contains public keys for signature verification
# - When secure boot disabled: DTB is plain (no keys)
do_compile:prepend() {
    if [ -f "${DEPLOY_DIR_IMAGE}/${UBOOT_DTB_NAME}" ]; then
        cp ${DEPLOY_DIR_IMAGE}/${UBOOT_DTB_NAME} ${DEPLOY_DIR_IMAGE}/${BOOT_TOOLS}/
    fi
}
do_image_complete:append() {
    # Ensure clean state
    rm -f "${DEPLOYDIR}/OTP.bin"

    # Copy the correct image
    if [ -f "${DEPLOYDIR}/imx-boot-tagged" ]; then
        install -m 0644 "${DEPLOYDIR}/imx-boot-tagged" "${DEPLOYDIR}/OTP.bin"
        echo "✅ OTP.bin created from imx-boot-tagged"
    else
        bbwarn "⚠️ imx-boot-tagged not found in DEPLOYDIR, OTP.bin not created"
    fi
}